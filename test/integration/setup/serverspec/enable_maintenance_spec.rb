require 'serverspec'
require 'rest-client'
require 'webrick/https'
require 'net/https'

set :backend, :exec

describe service('nginx') do
  before :all do
    remove_setup_from_runlist
  end

  before :each do
    maintenance_page(true)
    run_deploy
  end

  after :each do
    maintenance_page(false)
    run_deploy
  end

  def remove_setup_from_runlist
    if !File.exist?('/tmp/kitchen/test.json')
      `cp /tmp/kitchen/dna.json /tmp/kitchen/test.json`
    end

    file = File.read("/tmp/kitchen/test.json")
    deploy_run_list = JSON.parse(file)
    deploy_run_list['run_list'].reject! do |item| 
      item == 'touchbistro-nginx-loadbalancer::setup'
    end
    deploy_run_list = deploy_run_list.to_json
    File.write('/tmp/kitchen/test.json', deploy_run_list)
  end

  # accetps either true or false to enable or disable maintenance page
  def maintenance_page(status)
    path     = "/tmp/kitchen/test.json"
    file     = File.read(path)
    run_list = JSON.parse(file)
    run_list['enable_maintenance_page'] = status
    run_list = run_list.to_json
    File.write(path, run_list)
  end

  def run_deploy
    Dir.chdir "/tmp/kitchen"
    `sudo chef-solo -c solo.rb -j test.json`
  end

  def run_setup_and_deploy
    Dir.chdir "/tmp/kitchen"
    `sudo chef-solo -c solo.rb -j dna.json`
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

  describe 'maintenance page is enabled' do
    it "should not respond with 500 over http or https" do
      maintenance_page(true)
      run_deploy

      resp      = get
      resp_http = http_get
      expect(resp.code.to_s[0]).not_to eq "5"
      expect(resp_http.to_s[0]).not_to eq "5"

      maintenance_page(false)
      run_deploy
    end
    
    it 'should return content from touchbistro maintenance page' do
      maintenance_page(true)
      run_deploy

      resp = get
      expect(resp.body).to include('TouchBistro')

      maintenance_page(false)
      run_deploy
    end
  end

  describe 'maintenance page is disabled' do
    it "should not respond with 500 over http or https" do
      resp      = get
      resp_http = http_get
      expect(resp.code.to_s[0]).not_to eq "5"
      expect(resp_http.to_s[0]).not_to eq "5"
    end
    
    it 'should return content from either Amazon or Yahoo' do
      run_setup_and_deploy

      resp      = get
      resp_http = http_get
      expect(resp.body).to include('yahoo').or include('google')
      expect(resp_http.body).to include('yahoo').or include('google')
    end
  end

end