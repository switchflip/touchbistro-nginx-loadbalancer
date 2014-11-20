#
# Cookbook Name:: touchbistro-nginx-loadbalancer
# Recipe:: default
#
# Copyright (C) 2014
#
# All rights reserved - Do Not Redistribute
#

###########
# Globals #
###########

delete_files  = ['/etc/init/nginx.conf', '/etc/nginx/nginx.conf']
recipes       = ['nginx::source', 'ssl-crt']
templates     = {
  '/etc/init/nginx.conf'  => 'nginx-init.conf.erb',
  '/etc/nginx/nginx.conf' => 'nginx.conf.erb'
}

###########
# Recipe  #
###########

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

delete_files.each do |f| 
  file f do
    action :delete
  end
end

template '/etc/nginx/sites-enabled/default' do
  source    'default.erb'
  owner     'nginx'
  group     'nginx'
  mode      '0744'
  variables :servers => node[:upstream]
  action    :create
end

templates.each do |t, l|
  template t do
    source l
    owner  'nginx'
    group  'nginx'
    mode   '0744'
    variables :user => node[:nginx_user]
    action :create
  end
end

service 'nginx' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action   [:enable, :restart]
end