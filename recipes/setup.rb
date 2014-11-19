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
	source 'default.erb'
	owner 'root'
  group 'root'
  mode  '0755'
  action :create
  # pass in an array of servers
  variables({
     :server1 => node[:upstream][:server1],
     :server2 => node[:upstream][:server2],
     :server3 => node[:upstream][:server3]
  })
end


# figure out best practive on when to put ssl certs

# Creating the ssl directory, cert and key
# ssl_crt "/shared/ssl/server.crt" do
#   crt rails_deploy[:ssl_certificate]
#   key rails_deploy[:ssl_certificate_key]
# end


# template "/etc/nginx/nginx.conf" do
#   source "nginx.conf.erb"
#   mode "0644"
#   owner "root"
#   group "root"
#   # variables :deploy_to => rails_deploy
# end