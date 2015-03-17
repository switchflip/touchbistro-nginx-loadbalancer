loadbalancer_node = node[:touchbistro_nginx_loadbalancer]
deploy            = node[:deploy][loadbalancer_node[:deploy]]
maintenance       = node[:enable_maintenance_page]
maintenance_page_paths = %w[
  /var/www 
  /var/www/cloud.touchbistro.com 
  /var/www/cloud.touchbistro.com/maintenance/
  ]

maintenance_page_paths.each do |path|
  directory path do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

template '/var/www/cloud.touchbistro.com/maintenance/index.html' do
  action  :create
  source  'maintenance_page.html'
  owner   'root'
  group   'root'
  mode    '0744'
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  owner  'root'
  group  'root'
  mode   '0744'
  variables :directory => loadbalancer_node[:ssl_crt_directory],
            :file_name => loadbalancer_node[:domain_name],
            :user => loadbalancer_node[:nginx_user], 
            :worker => node[:cpu][:total],
            :servers => loadbalancer_node[:upstream]
end

service 'nginx' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action   [:enable, :restart]
end