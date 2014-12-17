require_relative '../../spec_helper'

describe 'touchbistro-nginx-loadbalancer::deploy' do


  it 'creates a template with these attributes' do
    loadbalancer_node = node[:touchbistro_nginx_loadbalancer]
    deploy = node[:deploy][loadbalancer_node[:deploy]]
    expect(runner).to create_template('/etc/nginx/sites-enabled/default').with(
      user:  'root',
      group: 'root',
      mode:  '0744',
      variables: {
        :servers => node[:touchbistro_nginx_loadbalancer][:upstream],
        :directory => loadbalancer_node[:ssl_crt_directory],
        :file_name => loadbalancer_node[:domain_name]
      }
    )
  end

  it 'enables and restarts nginx' do
    expect(runner).to enable_service('nginx')
    expect(runner).to restart_service('nginx')
  end
end