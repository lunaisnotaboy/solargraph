$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"

require 'date'
require 'solargraph/version'

Gem::Specification.new do |s|
  s.name = 'solargraph'
  s.version = Solargraph::VERSION
  s.date = Date.today.strftime('%Y-%m-%d')
  s.summary = 'A Ruby language server'
  s.description = 'IDE tools for code completion, inline documentation, and static analysis'
  s.authors = ['Fred Snyder', 'Luna Nova']
  s.email = 'her@mint.lgbt'
  s.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r[^(test|spec|features)/]) }
  end
  s.homepage = 'https://solargraph.org'
  s.license = 'MIT'
  s.executables = ['solargraph']

  s.required_ruby_version = '>= 2.1'

  s.add_runtime_dependency 'backport', '~> 1.2'
  s.add_runtime_dependency 'benchmark', '~> 0.2.0'
  s.add_runtime_dependency 'bundler', '>= 1.17.3'
  s.add_runtime_dependency 'diff-lcs', '~> 1.5'
  s.add_runtime_dependency 'e2mmap', '~> 0.1.0'
  s.add_runtime_dependency 'jaro_winkler', '~> 1.5', '>= 1.5.4'
  s.add_runtime_dependency 'kramdown', '~> 1.17'
  s.add_runtime_dependency 'parser', '~> 3.1', '>= 3.1.2.1'
  s.add_runtime_dependency 'reverse_markdown', '~> 2.1', '>= 2.1.1'
  s.add_runtime_dependency 'rubocop', '~> 0.57.2'
  s.add_runtime_dependency 'thor', '~> 1.2', '>= 1.2.1'
  s.add_runtime_dependency 'tilt', '~> 2.0', '>= 2.0.11'
  s.add_runtime_dependency 'yard', '~> 0.9.26'

  s.add_development_dependency 'pry', '~> 0.14.1'
  s.add_development_dependency 'public_suffix', '~> 3.1', '>= 3.1.1'
  s.add_development_dependency 'rspec', '~> 3.12'
  s.add_development_dependency 'simplecov', '~> 0.17.1'
  s.add_development_dependency 'webmock', '~> 3.16', '>= 3.16.2'
end
