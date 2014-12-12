loadbalancer_node = node[:touchbistro_nginx_loadbalancer]
deploy = node[:deploy][loadbalancer_node[:deploy]]

template '/etc/nginx/sites-enabled/default' do
  source    'default.erb'
  owner     'root'
  group     'root'
  mode      '0744'
  variables :servers => loadbalancer_node[:upstream], 
            :directory => loadbalancer_node[:ssl_crt_directory],
            :file_name => loadbalancer_node[:domain_name]
  action    :create
end

service 'nginx' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action   [:enable, :restart]
end