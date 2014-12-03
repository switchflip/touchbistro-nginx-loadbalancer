require 'serverspec'
require 'rest-client'
require 'net/https'

set :backend, :exec

describe service('nginx') do
  before :each do
    @conf_path      = '/etc/nginx/sites-enabled/default'
    @contents       = File.read(@conf_path)
    @failing_server = "server 127.0.0.1:23234"
    @working_server = "server amazon.ca:443"
  end

  let :rest_client do
    RestClient::Resource.new('https://127.0.0.1',
      verify_ssl: OpenSSL::SSL::VERIFY_NONE
    ) {|response, request, result| response }
  end

  def gsub_nginx_conf(target, replacement)
    `sudo service nginx stop`
    sleep(0.1)
    new_contents = @contents.gsub(target, replacement)
    File.open(@conf_path, 'w') {|file| file.puts new_contents }
    `sudo service nginx start`
    sleep(0.1)
  end

  def break_backend
    gsub_nginx_conf @working_server, @failing_server
  end

  def unbreak_backend
    gsub_nginx_conf @failing_server, @working_server
  end

  def expect_successful_failover
    4.times do
      resp = rest_client.get
      expect(resp.code.to_s[0]).not_to eq "5"
    end
  end

  def self.it_should_failover_successfully
    it("should failover and respond successfully") { expect_successful_failover }
  end

  it { should be_enabled }
  it { should be_running.under('upstart') }

  describe 'when running' do
    it "should not respond with 500" do
      resp = rest_client.get
      expect(resp.code.to_s[0]).not_to eq "5"
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
  
  describe 'when the worker is killed' do
    it 'should respawn and not respond with a status of 500' do
      pid = `pidof -s nginx`
      `kill #{pid}`
      sleep 0.1
      nginx_pids = `pidof nginx`.split(' ')
      expect(nginx_pids.length).to eq 2 
      resp = rest_client.get
      expect(resp.code.to_s[0]).not_to eq "5"
    end
  end

  describe 'when both master and worker are killed' do
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
      expect(resp.code.to_s[0]).not_to eq "5"
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
      expect(resp.code.to_s[0]).not_to eq "5"
    end
  end

  describe 'when one backend server is down' do
    before(:each) {break_backend}
    after(:each)  {unbreak_backend}

    it_should_failover_successfully
  end

  # [500, 503, 504].each do |error_code|
  #   describe "when one backend server is responding with #{error_code} http errors" do

  #     before :each do
  #       failing_server = "https://127.0.0.1:3242"
        
  #       # TODO: setup a server here, responsds with whatever status code we tell it to
  #       # 
  #       # file_name.rb (port, status_code)
  #       `./sinatra_server.rb 3242 #{status_code}`


  #       # test that the server fails as expected
  #       failing_server_rest_client = RestClient::Resource.new(failing_server,
  #         verify_ssl: OpenSSL::SSL::VERIFY_NONE
  #       ) {|response, request, result| response }
  #       expect(failing_server_rest_client.get.code).to eq error_code
  #     end

  #     after :each do
  #       # TODO: tare down the server here
  #     end

  #     it_should_failover_successfully
  #   end
  # end
end