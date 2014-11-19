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
        :servers => node[:upstream]
      }
    )
  end
end