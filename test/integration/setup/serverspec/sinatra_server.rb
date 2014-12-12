require 'bundler/setup'

require 'sinatra/base'
require 'webrick'
require 'webrick/https'
require 'openssl'

class SinatraServer  < Sinatra::Base
    get '/' do
      status ARGV[0]
    end
end

CERT_PATH = "/etc/nginx/ssl"

webrick_options = {
  :Port               => 3092,
  :SSLEnable          => true,
  :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
  :SSLCertificate     => OpenSSL::X509::Certificate.new(  File.open(File.join(CERT_PATH, "nginx-test.crt")).read),
  :SSLPrivateKey      => OpenSSL::PKey::RSA.new(          File.open(File.join(CERT_PATH, "nginx-test.key")).read),
  :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ],
  :app                => SinatraServer
}

Rack::Server.start webrick_options