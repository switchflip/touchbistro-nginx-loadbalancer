require 'sinatra/base'
require 'serverspec'
require 'rest-client'
require 'net/https'

set :backend, :exec

describe service('nginx') do
  it { should be_enabled }
  it { should be_running.under('upstart') }
  let :rest_client do
    RestClient::Resource.new('https://127.0.0.1',
      verify_ssl: OpenSSL::SSL::VERIFY_NONE
    )
  end

  # before :each do
  #   @sinatra_enabled = true
  # end

  # after :each do
  #   @sinatra_enabled = true
  # end

  # get '/' do
  #   status @sinatra_enabled ? 200 : 500
  #   body @sinatra_enabled ? "it's sinatra!" : "fubar"
  # end


  describe 'when running' do
    it "should respond with 200" do
      resp = rest_client.get
      expect(resp.code).to eq 200
    end
    it 'should return content from yahoo or amazon' do
      resp = rest_client.get
      expect(resp.body).to include('facebook').or include('amazon')
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
    it 'should respawn and respond with 200' do
      pid = `pidof -s nginx`
      `kill #{pid}`
      sleep 0.1
      nginx_pids = `pidof nginx`.split(' ')
      expect(nginx_pids.length).to eq 2 
      resp = rest_client.get
      expect(resp.code).to eq 200
    end
  end

  describe 'when both workers are killed' do
    before :each do
      nginx_pids = `pidof nginx`.split(' ')
      nginx_pids.each { |pid| `kill #{pid}` }
      sleep 0.1
    end
    it 'both workers should respawn' do
      new_pids = `pidof nginx`.split(' ')
      expect(new_pids.length).to eq 2
    end
    it 'should respond with 200' do
      resp = rest_client.get
      expect(resp.code).to eq 200
    end
  end

  describe 'when master is killed' do
    it 'should respawn master and worker and respond with 200' do
      original_pids = `pidof nginx`.split(' ')
      resp = rest_client.get

      `pkill -f 'nginx: master process'`
      sleep(0.1)
      new_pids = `pidof nginx`.split(' ')
      expect(new_pids.length).to eq 2
      expect(new_pids).not_to eq original_pids
      expect(resp.code).to eq 200
    end
  end

end