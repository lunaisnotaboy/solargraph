describe Solargraph::Diagnostics::Rubocop do
  before :each do
    @source = Solargraph::Source.new(%(
      class Foo
        def bar
        end
      end
      foo = Foo.new
    ), 'file.rb')

    @api_map = Solargraph::ApiMap.new
    @api_map.map @source
  end

  it "diagnoses input" do
    rubocop = Solargraph::Diagnostics::Rubocop.new
    result = rubocop.diagnose(@source, @api_map)
    expect(result).to be_a(Array)
  end

  it "handles validation errors" do
    file = File.realpath(File.join('spec', 'fixtures', 'rubocop-validation-error', 'app.rb'))
    source = Solargraph::Source.load(file)
    rubocop = Solargraph::Diagnostics::Rubocop.new
    expect {
      rubocop.diagnose(source, nil)
    }.to raise_error(Solargraph::DiagnosticsError)
  end
end
