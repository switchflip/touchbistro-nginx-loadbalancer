require 'serverspec'
require 'rest-client'
require 'webrick/https'
require 'net/https'

set :backend, :exec

describe service('nginx') do

  before :all do
    `cd /tmp/busser/suites/serverspec/&&/opt/chef/embedded/bin/bundle install`
  end

  before :each do
    @conf_path      = '/etc/nginx/nginx.conf'
    @contents       = File.read(@conf_path)
    @failing_server = "server 127.0.0.1:23234"
    @working_server = "server amazon.ca:443"
  end

  def get(server="127.0.0.1")
    rest_client = RestClient::Resource.new("https://#{server}",
      verify_ssl: OpenSSL::SSL::VERIFY_NONE
    ) {|response, request, result| response }
    rest_client.get
  end

  def http_get(server="127.0.0.1")
    rest_client = RestClient::Resource.new(
      "http://#{server}"
    ) {|response, request, result| response }
    rest_client.get
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
    10.times do
      resp = get
      expect(resp.code.to_s[0]).not_to eq "5"
    end
  end

  def self.it_should_failover_successfully
    it("should failover and respond successfully") { expect_successful_failover }
  end

  it { should be_enabled }
  it { should be_running.under('upstart') }

  describe 'when running' do
    it "should not respond with 500 over http or https" do
      resp      = get
      resp_http = http_get
      expect(resp.code.to_s[0]).not_to eq "5"
      expect(resp_http.to_s[0]).not_to eq "5"
    end
    it 'should return content from yahoo or amazon' do
      resp = get
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
      expect{get}.to raise_error(Errno::ECONNREFUSED)
    end
  end
  
  describe 'when the worker is killed' do
    it 'should respawn and not respond with a status of 500' do
      pid = `pidof -s nginx`
      `kill #{pid}`
      sleep 0.1
      nginx_pids = `pidof nginx`.split(' ')
      expect(nginx_pids.length).to eq 2 
      resp = get
      expect(resp.code.to_s[0]).not_to eq "5"
    end
  end

  describe 'when master and worker are killed' do
    before :each do
      nginx_pids = `pidof nginx`.split(' ')
      nginx_pids.each { |pid| `kill #{pid}` }
      sleep(0.1)
    end
    it 'master and worker should respawn' do
      new_pids = `pidof nginx`.split(' ')
      expect(new_pids.length).to eq 2
    end
    it 'should not respond with 500' do
      resp = get
      expect(resp.code.to_s[0]).not_to eq "5"
    end
  end

  describe 'when master is killed' do
    it 'should respawn master and worker and not respond with 500' do
      original_pids = `pidof nginx`.split(' ')
      resp = get

      `pkill -f 'nginx: master process'`
      sleep(0.1)
      new_pids = `pidof nginx`.split(' ')
      expect(new_pids.length).to eq 2
      expect(new_pids).not_to eq original_pids
      expect(resp.code.to_s[0]).not_to eq "5"
    end
  end

  describe 'when one backend server is not responding' do
    before(:each) {break_backend}
    after(:each)  {unbreak_backend}

    it_should_failover_successfully
  end

  [500, 503, 504].each do |error_code|
    describe "when one backend server is responding with #{error_code} http errors" do

      let(:sinatra_server) {"127.0.0.1:3092"}

      after :each do
        `kill -9 #{@pid}`
        gsub_nginx_conf "server #{sinatra_server}", @working_server
        `sudo service nginx stop`
        sleep(1)
        `sudo service nginx start`
        sleep(1)
      end

      it "should failover and respond successfully" do
        # test that the server fails as expected
        @pid = Process.spawn(
          "/opt/chef/embedded/bin/ruby /tmp/busser/suites/serverspec/sinatra_server.rb #{error_code}",
          out: "/dev/null",
          err: "/dev/null"
        )
        gsub_nginx_conf @working_server, "server #{sinatra_server}"
        `sudo service nginx stop`
        sleep(1)
        `sudo service nginx start`
        sleep(1)
        expect(get(sinatra_server).code).to eq error_code
        expect_successful_failover
      end
    end
  end
end