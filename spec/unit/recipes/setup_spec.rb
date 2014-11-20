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

  it 'deletes files /etc/init/nginx.conf and /etc/nginx/nginx.conf' do
    ['/etc/init/nginx.conf', '/etc/nginx/nginx.conf'].each do |file|
      expect(runner).to delete_file(file)
    end
  end

  it 'creates a template with these attributes' do
    expect(runner).to create_template('/etc/nginx/sites-enabled/default').with(
      user:  'nginx',
      group: 'nginx',
      variables: {
        :servers => node[:upstream]
      }
    )
  end

  it 'create /etc/init/nginx.conf' do
    expect(runner).to create_template('/etc/init/nginx.conf').with(
      user:  'nginx',
      group: 'nginx',
      variables: {
        :user => node[:nginx_user]
      }
    )
  end

  it 'create nginx.conf template' do
    expect(runner).to create_template('/etc/nginx/nginx.conf').with(
      user:  'nginx',
      group: 'nginx',
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