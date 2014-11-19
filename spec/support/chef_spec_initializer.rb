module ChefSpecInitializer
  extend RSpec::Core::SharedContext

  let(:runner) { @runner }
  let(:node)   {@runner.node}

  before do
    Fauxhai.mock(platform: 'ubuntu', version: '14.04')
    @runner = ChefSpec::SoloRunner.new do |node|
      file_path = File.join ChefRoot, ".kitchen.yml"
      yaml_attributes = YAML.load_file(file_path)['suites'][0]['attributes']
      yaml_attributes.each do |k, v| 
        node.set[k.to_sym] = v 
      end

    end.converge(described_recipe)
  end

end