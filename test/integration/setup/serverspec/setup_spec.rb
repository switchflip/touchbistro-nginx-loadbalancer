require 'serverspec'
set :backend, :exec

packages       = ['tar', 'vim']
non_root_users = ['vagrant','nginx']
ssl_keys       = ['nginx-test.crt', 'nginx-test.key']

non_root_users.each do |u|
  describe user(u) do
    it { should exist }
    it { should belong_to_group u }
    it { should have_home_directory "home/#{u}"}
  end
end

describe user('root') do
  it { should exist }
  it { should belong_to_group 'root' }
  it { should have_uid 0 }
  it { should have_home_directory '/root' }
  it { should have_login_shell '/bin/bash' }
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
end


describe file('/etc/nginx/ssl') do
  it { should be_directory }
  it { should be_mode 700 }
  it { should be_owned_by 'nginx' }
end

ssl_keys.each do |k| 
  describe file("/etc/nginx/ssl/#{k}") do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'nginx' }
  end
end


# LAST
describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

describe port(8443) do
  it { should_not be_listening }
end