require_relative '../../spec_helper'

describe 'touchbistro-nginx-loadbalancer::setup' do

  it 'includes nginx recipe' do
    expect(runner).to include_recipe('nginx::source')
  end

  it 'include ssl-crt recipe' do
    expect(runner).to include_recipe('ssl-crt')
  end

  it 'creates ssl directory' do
    expect(runner).to create_directory node[:ssl_crt_directory]
  end

  it 'deletes file /etc/nginx/nginx.conf' do
    expect(runner).to delete_file('/etc/nginx/nginx.conf')
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

  it 'create nginx.conf template' do
    expect(runner).to create_template('/etc/nginx/nginx.conf').with(
      user:  'root',
      group: 'root',
      variables: {
        :user => node[:nginx_user]
      }
    )
  end

  it 'enables and restarts nginx' do
    expect(runner).to enable_service('nginx')
    expect(runner).to restart_service('nginx')
  end
end