require 'chefspec'
require 'fauxhai'
require 'chefspec'
require 'faraday'
require 'chefspec/berkshelf'
require 'awesome_print'
require 'rspec/core/shared_context'

if ENV["SPEC_TYPE"] != "serverspec"
  require_relative './chef_spec_helper.rb'
end

AwesomePrint.defaults = {
  indent: -2
}

ChefRoot = File.join File.dirname(__FILE__), ".."
