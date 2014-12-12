require_relative '../../spec_helper'

describe 'touchbistro-nginx-loadbalancer::setup' do

  it 'includes nginx recipe' do
    expect(runner).to include_recipe('nginx::source')
  end

  it 'include ssl-crt recipe' do
    expect(runner).to include_recipe('ssl-crt')
  end

  it 'creates ssl directory' do
    expect(runner).to create_directory(
      node[:touchbistro_nginx_loadbalancer][:ssl_crt_directory]
    )
  end

  it 'deletes file /etc/nginx/nginx.conf' do
    expect(runner).to delete_file('/etc/nginx/nginx.conf')
  end

  it 'create nginx.conf template' do
    expect(runner).to create_template('/etc/nginx/nginx.conf').with(
      user:  'root',
      group: 'root',
      mode:  '0744',
      variables: {
        :user => node[:touchbistro_nginx_loadbalancer][:nginx_user],
        :worker => node[:cpu][:total]
      }
    )
  end

  it 'create DH params file and sets permissions for root' do
    expect(runner).to run_bash('create DH param key').with(
      user:  'root',
      group: 'root'
      )
  end

  it 'sets up OCSP stapling' do
    expect(runner).to run_bash('setup OCSP stapling').with(
      user:  'root',
      group: 'root'
      )
  end
end