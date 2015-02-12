#
# Cookbook Name:: touchbistro-nginx-loadbalancer
# Recipe:: default
#
# Copyright (C) 2014
#
# All rights reserved - Do Not Redistribute

loadbalancer_node = node[:touchbistro_nginx_loadbalancer]
deploy = node[:deploy][loadbalancer_node[:deploy]]
root  = loadbalancer_node[:ocsp_urls][:root]
inter = loadbalancer_node[:ocsp_urls][:intermediate]

packages = [
  "build-essential",
  "htop",
  "ncdu",
  "vim",
  "language-pack-en",
  "mosh",
  "logrotate",
  "apt"
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
    wget -O - #{root} #{inter} | tee -a ca-certs.pem> /dev/null
    chmod 600 ca-certs.pem 
   EOH
end

logrotate_app "nginx" do
  path "/var/log/nginx/error.log"
  frequency "daily"
  rotate 30
  maxsize 52428800
  create "644 root root"
  postrotate <<-EOF
     [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
  EOF
end

# NewRelic Sysmond
if node[:touchbsistro_nginx_loadbalancer][:enable_newrelic_sysmond]
  include_recipe "newrelic-sysmond"
end