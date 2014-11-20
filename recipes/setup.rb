#
# Cookbook Name:: touchbistro-nginx-loadbalancer
# Recipe:: default
#
# Copyright (C) 2014
#
# All rights reserved - Do Not Redistribute

recipes       = ['nginx::source', 'ssl-crt']

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
  variables :servers => node[:upstream]
  action    :create
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  variables :user => node[:nginx_user]
end

service 'nginx' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action   [:enable, :restart]
end