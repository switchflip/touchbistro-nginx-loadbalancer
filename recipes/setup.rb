#
# Cookbook Name:: touchbistro-nginx-loadbalancer
# Recipe:: default
#
# Copyright (C) 2014
#
# All rights reserved - Do Not Redistribute

loadbalancer_node = node[:touchbistro_nginx_loadbalancer]
deploy = node[:deploy][loadbalancer_node[:deploy]]

packages = [
  "build-essential",
  "htop",
  "ncdu",
  "vim",
  "language-pack-en",
  "mosh"
]

packages.each { |p| package p }

recipes = ['nginx::source', 'ssl-crt']

user_account 'nginx' do
  ssh_keygen     true
  create_group   true
  ignore_failure true
end

recipes.each { |r| include_recipe r }

ssl_crt File.join(loadbalancer_node[:ssl_crt_directory], "#{loadbalancer_node[:domain_name]}.crt" ) do
  owner 'nginx'
  group 'nginx'
  crt    deploy[:ssl_certificate]
  key    deploy[:ssl_certificate_key]
end

file '/etc/nginx/nginx.conf' do
  action :delete
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  owner  'root'
  group  'root'
  mode   '0744'
  variables :user => loadbalancer_node[:nginx_user], :worker => node[:cpu][:total]
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