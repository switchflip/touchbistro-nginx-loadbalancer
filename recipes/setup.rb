#
# Cookbook Name:: touchbistro-nginx-loadbalancer
# Recipe:: default
#
# Copyright (C) 2014
#
# All rights reserved - Do Not Redistribute
#

# rails_deploy = node[:deploy][node[:touchbistro_rails][:deploy]]

include_recipe "nginx::source"

template '/etc/nginx/sites-enabled/default' do
	source    'default.erb'
	owner     'root'
  group     'root'
  mode      '0755'
  variables :servers => node[:upstream]
  action    :create
end

# Creating the ssl directory, cert and key
# ssl_crt "/shared/ssl/server.crt" do
#   crt rails_deploy[:ssl_certificate]
#   key rails_deploy[:ssl_certificate_key]
# end

# no rails sample application, just nginx

# figure out best practive on when to put ssl certs

# figure out how to get nginx to work on https

# template "/etc/nginx/nginx.conf" do
#   source "nginx.conf.erb"
#   mode "0644"
#   owner "nginx"
#   group "nginx"
#   # variables :deploy_to => rails_deploy
# end