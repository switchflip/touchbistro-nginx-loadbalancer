require 'serverspec'
require 'rest-client'
require 'net/https'

def break_backend
  content = File.read('/etc/nginx/sites-enabled/default')
  new_contents = content.gsub("server amazon.ca:443", "server 127.0.0.1:23234")
  puts new_contents
  File.open('/etc/nginx/sites-enabled/default', 'w') {|file| file.puts new_contents }
end

def unbreak_backend
  content = File.read('/etc/nginx/sites-enabled/default')
  new_contents = content.gsub("server 127.0.0.1:23234", "server amazon.ca:443")
  puts new_contents
  File.open('/etc/nginx/sites-enabled/default', 'w') {|file| file.puts new_contents }
end

set :backend, :exec

describe service('nginx') do
  it { should be_enabled }
  it { should be_running.under('upstart') }
  let :rest_client do
    RestClient::Resource.new('https://127.0.0.1',
      verify_ssl: OpenSSL::SSL::VERIFY_NONE
    ) {|response, request, result| response }
  end

  describe 'when running' do
    it "should not respond with 500" do
      resp = rest_client.get
      expect(resp.code).not_to eq 500
    end
    it 'should return content from shopify or amazon' do
      resp = rest_client.get
      expect(resp.body).to include('yahoo').or include('google')
    end
  end

  describe "when stopped" do
    before :each do
      `sudo service nginx stop`
    end
    after :each do
      `sudo service nginx start`
    end
    it { should be_enabled }
    it { should_not be_running.under('upstart') }
    it "should fail to respond to https requests" do
      expect{rest_client.get}.to raise_error(Errno::ECONNREFUSED)
    end
  end
  
  describe 'when one worker is killed' do
    it 'should respawn and respond without 500' do
      pid = `pidof -s nginx`
      `kill #{pid}`
      sleep 0.1
      nginx_pids = `pidof nginx`.split(' ')
      expect(nginx_pids.length).to eq 2 
      resp = rest_client.get
      expect(resp.code).not_to eq 500
    end
  end

  describe 'when both workers are killed' do
    before :each do
      nginx_pids = `pidof nginx`.split(' ')
      nginx_pids.each { |pid| `kill #{pid}` }
      sleep(0.1)
    end
    it 'both workers should respawn' do
      new_pids = `pidof nginx`.split(' ')
      expect(new_pids.length).to eq 2
    end
    it 'should not respond with 500' do
      resp = rest_client.get
      expect(resp.code).to eq 404
    end
  end

  describe 'when master is killed' do
    it 'should respawn master and worker and not respond with 500' do
      original_pids = `pidof nginx`.split(' ')
      resp = rest_client.get

      `pkill -f 'nginx: master process'`
      sleep(0.1)
      new_pids = `pidof nginx`.split(' ')
      expect(new_pids.length).to eq 2
      expect(new_pids).not_to eq original_pids
      expect(resp.code).not_to eq 500
    end
  end

  describe 'when one backend server is killed' do
    before :each do
      `sudo service nginx stop`
      sleep(0.1)
      break_backend
      `sudo service nginx start`
      sleep(0.1)
    end

    after :each do
      `sudo service nginx stop`
      sleep(0.1)
      unbreak_backend
      `sudo service nginx start`
      sleep(0.1)
    end

    it 'should only response from an online backends' do
      resp = rest_client.get
      expect(resp.code.to_s[0]).not_to eq "5"
    end
  end

end