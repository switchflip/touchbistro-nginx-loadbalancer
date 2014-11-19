require 'chefspec'
require 'fauxhai'
require 'chefspec'
require 'chefspec/berkshelf'
require "awesome_print"
require "rspec/core/shared_context"
require_relative "./support/chef_spec_initializer.rb"

AwesomePrint.defaults = {
  indent: -2
}

ChefRoot = File.join File.dirname(__FILE__), ".."

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