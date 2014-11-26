require 'serverspec'
set :backend, :exec

describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

# Users testing
non_root_users = ['vagrant','nginx']

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