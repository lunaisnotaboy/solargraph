require 'thor'
require 'json'
require 'fileutils'
require 'rubygems/package'
require 'zlib'
require 'backport'

module Solargraph
  class Shell < Thor
    include Solargraph::ServerMethods

    map %w[--version -v] => :version

    desc "--version, -v", "Print the version"
    def version
      puts Solargraph::VERSION
    end

    desc 'socket', 'Run a Solargraph socket server'
    option :host, type: :string, aliases: :h, desc: 'The server host', default: '127.0.0.1'
    option :port, type: :numeric, aliases: :p, desc: 'The server port', default: 7658
    def socket
      port = options[:port]
      port = available_port if port.zero?
      Backport.run do
        Signal.trap("INT") do
          Backport.stop
        end
        Signal.trap("TERM") do
          Backport.stop
        end
        Backport.prepare_tcp_server host: options[:host], port: port, adapter: Solargraph::LanguageServer::Transport::Adapter
        STDERR.puts "Solargraph is listening PORT=#{port} PID=#{Process.pid}"
      end
    end

    desc 'stdio', 'Run a Solargraph stdio server'
    def stdio
      Backport.run do
        Signal.trap("INT") do
          Backport.stop
        end
        Signal.trap("TERM") do
          Backport.stop
        end
        Backport.prepare_stdio_server adapter: Solargraph::LanguageServer::Transport::Adapter
        STDERR.puts "Solargraph is listening on stdio PID=#{Process.pid}"
      end
    end

    desc 'config [DIRECTORY]', 'Create or overwrite a default configuration file'
    option :extensions, type: :boolean, aliases: :e, desc: 'Add installed extensions', default: true
    def config(directory = '.')
      matches = []
      if options[:extensions]
        Gem::Specification.each do |g|
          if g.name.match(/^solargraph\-[A-Za-z0-9_\-]*?\-ext/)
            require g.name
            matches.push g.name
          end
        end
      end
      conf = Solargraph::Workspace::Config.new.raw_data
      unless matches.empty?
        matches.each do |m|
          conf['extensions'].push m
        end
      end
      File.open(File.join(directory, '.solargraph.yml'), 'w') do |file|
        file.puts conf.to_yaml
      end
      STDOUT.puts "Configuration file initialized."
    end

    desc 'download-core [VERSION]', 'Download core documentation'
    def download_core version = nil
      ver = version || Solargraph::YardMap::CoreDocs.best_download
      puts "Downloading docs for #{ver}..."
      Solargraph::YardMap::CoreDocs.download ver
    rescue ArgumentError => e
      STDERR.puts "ERROR: #{e.message}"
      STDERR.puts "Run `solargraph available-cores` for a list."
      exit 1
    end

    desc 'list-cores', 'List the local documentation versions'
    def list_cores
      puts Solargraph::YardMap::CoreDocs.versions.join("\n")
    end

    desc 'available-cores', 'List available documentation versions'
    def available_cores
      puts Solargraph::YardMap::CoreDocs.available.join("\n")
    end

    desc 'clear-cores', 'Clear the cached core documentation'
    def clear_cores
      Solargraph::YardMap::CoreDocs.clear
    end

    desc 'reporters', 'Get a list of diagnostics reporters'
    def reporters
      puts Solargraph::Diagnostics.reporters
    end

    desc 'typecheck', 'Run the type checker'
    option :strict, type: :boolean, aliases: :strict, desc: 'Use strict typing', default: false
    def typecheck
      api_map = Solargraph::ApiMap.load('.')
      files = api_map.source_maps.map(&:filename)
      probcount = 0
      filecount = 0
      files.each do |file|
        checker = TypeChecker.new(file, api_map: api_map)
        problems = checker.param_types + checker.return_types
        problems.concat checker.strict_types if options[:strict]
        next if problems.empty?
        problems.sort! { |a, b| a.location.range.start.line <=> b.location.range.start.line }
        puts problems.map { |prob| "#{prob.location.filename}:#{prob.location.range.start.line + 1} - #{prob.message}" }.join("\n")
        filecount += 1
        probcount += problems.length
      end
      puts "#{probcount} problems found in #{filecount} of #{files.length} files."
    end
  end
end
