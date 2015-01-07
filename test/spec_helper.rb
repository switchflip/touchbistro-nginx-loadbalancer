require 'chefspec'
require 'fauxhai'
require 'chefspec'
require 'chefspec/berkshelf'
require 'awesome_print'
require 'rspec/core/shared_context'

AwesomePrint.defaults = {
  indent: -2
}

ChefRoot = File.join File.dirname(__FILE__), ".."