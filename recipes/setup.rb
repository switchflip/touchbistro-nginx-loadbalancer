#
# Cookbook Name:: touchbistro-nginx-loadbalancer
# Recipe:: default
#
# Copyright (C) 2014
#
# All rights reserved - Do Not Redistribute

recipes = ['nginx::source', 'ssl-crt', 'vim']

user_account 'nginx' do
  ssh_keygen     true
  create_group   true
  ignore_failure true
end

recipes.each { |r| include_recipe r }

ssl_crt File.join(node[:ssl_crt_directory], node[:domain_name] + '.crt' ) do
  owner 'nginx'
  group 'nginx'
  crt    node[:ssl_certificate]
  key    node[:ssl_certificate_key]
end

file '/etc/nginx/nginx.conf' do
  action :delete
end

template '/etc/nginx/sites-enabled/default' do
  source    'default.erb'
  owner     'root'
  group     'root'
  mode      '0744'
  variables :servers => node[:upstream], 
            :directory => node[:ssl_crt_directory],
            :file_name => node[:domain_name]
  action    :create
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  owner  'root'
  group  'root'
  mode   '0744'
  variables :user => node[:nginx_user], :worker => node[:cpu][:total]
end

bash 'create DH param key' do
  cwd   '/etc/nginx/ssl'
  user  'root'
  group 'root'
  code  'openssl dhparam 2048 -out /etc/nginx/ssl/dhparam.pem'
end

bash 'setup OCSP stapling' do
  cwd   '/etc/ssl/private'
  user  'root'
  group 'root'
  code <<-EOH
    wget -O - https://www.startssl.com/certs/ca.pem https://www.startssl.com/certs/sub.class1.server.ca.pem | tee -a ca-certs.pem> /dev/null
    chmod 600 ca-certs.pem 
   EOH
end

service 'nginx' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action   [:enable, :restart]
end