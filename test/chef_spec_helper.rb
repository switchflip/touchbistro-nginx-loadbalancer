module ChefSpecInitializer
  extend RSpec::Core::SharedContext

  let(:runner) { @runner }
  let(:node)   { @runner.node }

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

RSpec.configure do |config|
  # Specify the path for Chef Solo to find cookbooks (default: [inferred from
  # the location of the calling spec file])
  # config.cookbook_path = '/var/cookbooks'

  # Specify the path for Chef Solo to find roles (default: [ascending search])
  # config.role_path = '/var/roles'

  # Specify the Chef log_level (default: :warn)
  # config.log_level = :debug

  # Specify the path to a local JSON file with Ohai data (default: nil)
  # config.path = 'ohai.json'

  # Specify the operating platform to mock Ohai data from (default: nil)
  config.platform = 'ubuntu'

  # Specify the operating version to mock Ohai data from (default: nil)
  config.version = '14.04'

  config.include ChefSpecInitializer

end

at_exit { ChefSpec::Coverage.report! } 
