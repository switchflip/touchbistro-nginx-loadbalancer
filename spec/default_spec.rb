require 'chefspec'
require 'chefspec/berkshelf'

describe 'touchbistro-nginx-loadbalancer::setup' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'create test direcory' do
    expect(chef_run).to create_directory('/etc/init/test')
  end

end