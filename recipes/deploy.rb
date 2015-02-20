loadbalancer_node = node[:touchbistro_nginx_loadbalancer]
deploy            = node[:deploy][loadbalancer_node[:deploy]]
maintenance       = node[:enable_maintenance_page]
maintenance_page_paths = %w[
  /var/www 
  /var/www/cloud.touchbistro.com 
  /var/www/cloud.touchbistro.com/public_html/
  ]


if node[:enable_maintenance_page]
  # Enable the maintenance page
  file "/etc/nginx/nginx.conf" do
    action :delete
  end

  template '/etc/nginx/nginx.conf' do
    source 'maintenance.conf.erb'
    owner  'root'
    group  'root'
    mode   '0744'
    variables :directory => loadbalancer_node[:ssl_crt_directory],
              :file_name => loadbalancer_node[:domain_name],
              :user => loadbalancer_node[:nginx_user], 
              :worker => node[:cpu][:total]
  end

  maintenance_page_paths.each do |path|
    directory path do
      owner 'root'
      group 'root'
      mode '0755'
    end
  end

  template '/var/www/cloud.touchbistro.com/public_html/index.html' do
    action  :create
    source  'maintenance_page.html'
    owner   'root'
    group   'root'
    mode    '0744'
  end

else
  # Use the default nginx configuration for normal operations
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

  if File.exists?("/var/www/cloud.touchbistro.com/public_html/index.html")
    file '/var/www/cloud.touchbistro.com/public_html/index.html' do
      action :delete
    end
  end

  maintenance_page_paths.reverse.each do |path|
    if File.exists?(path)
      directory path do
        action :delete
      end
    end
  end

end

service 'nginx' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action   [:enable, :restart]
end