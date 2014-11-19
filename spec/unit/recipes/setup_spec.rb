require_relative '../../spec_helper'

describe 'touchbistro-nginx-loadbalancer::setup' do

  it 'includes nginx recipe' do
    expect(runner).to include_recipe('nginx::source')
  end

  it 'creates a template with these attributes' do
    expect(runner).to create_template('/etc/nginx/sites-enabled/default').with(
      user:  'root',
      group: 'root',
      variables: {
        :server1 => node[:upstream][:server1],
        :server2 => node[:upstream][:server2],
        :server3 => node[:upstream][:server3]
      }
    )
  end
end