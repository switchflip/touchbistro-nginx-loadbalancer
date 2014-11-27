require 'serverspec'
require 'faraday'

set :backend, :exec

packages       = ['tar', 'vim']
non_root_users = ['nginx']
ssl_keys       = ['nginx-test.crt', 'nginx-test.key']
nginx_confs    = ['/etc/nginx/sites-enabled/default', '/etc/nginx/nginx.conf']

non_root_users.each do |u|
  describe user(u) do
    it { should exist }
    it { should belong_to_group u }
    it { should have_home_directory "home/#{u}"}
  end
end

packages.each do |p| 
  describe package p do
    it { should be_installed }
  end
end

describe file('/etc/nginx') do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/etc/nginx/ssl') do
  it { should be_directory }
  it { should be_mode 700 }
  it { should be_owned_by 'nginx' }
  it { should be_grouped_into 'nginx' }
end

ssl_keys.each do |k| 
  describe file("/etc/nginx/ssl/#{k}") do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'nginx' }
    it { should be_grouped_into 'nginx' }
  end
end

nginx_confs.each do |conf| 
  describe file conf do
    it { should be_file }
    it { should be_mode 744 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end

describe file '/etc/nginx/ssl/dhparam.pem' do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/etc/ssl/private') do
  it { should be_directory }
  it { should be_mode 700}
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root'}
end 

describe file('/etc/ssl/private/ca-certs.pem') do
  it { should be_file}
  it { should be_mode '600' }
  it { should be_owned_by 'root'}
  it { should be_grouped_into 'root'}
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_running.under('upstart') }
end

describe port(443) do
  it { should be_listening }
end

# Test that the content you are receiving is from the upstreams servers

conn = Faraday.new


# Change one the upstreams to be a url that doesn't work, and verify you don't get a response




