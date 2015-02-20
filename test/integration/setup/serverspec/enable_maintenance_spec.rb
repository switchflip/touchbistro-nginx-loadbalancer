require 'serverspec'

set :backend, :exec

describe service('nginx') do
  let(:node) { JSON.parse(IO.read('/tmp/kitchen/dna.json')) }

  before :all do
    @enable_maintenance = node[:enable_maintenance_page]
  end

# re deploy with enable_maitenance to true

# re deploy yet again with maitenance set to false

  def set_true(file)
    f        = File.read(file)
    run_list = JSON.parse(f)
    #  set enable_maintenance_page to true
    run_list = 
    File.write(f)
  end

  def set_false(file)
    f        = File.read(file)
    run_list = JSON.parse(f)
    #  set enable_maintenance_page to true
    File.write(f)
  end

  describe 'after a deployment' do
    if !File.exist?('/tmp/kitchen/test.json')
      `cp /tmp/kitchen/dna.json /tmp/kitchen/test.json`
    end

    f = File.read("/tmp/kitchen/test.json")
    deploy_run_list = JSON.parse(f)
    deploy_run_list['run_list'].reject! { |item| item == 'touchbistro-rails::setup' }
    deploy_run_list = deploy_run_list.to_json
    File.write('/tmp/kitchen/test.json', deploy_run_list)

    Dir.chdir "/tmp/kitchen"
    `sudo chef-solo -c solo.rb -j test.json`

    unicorn_running
  end

end