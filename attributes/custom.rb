# === Nginx General Configuration ===

# Reload nginx::source attributes with our updated version
node.from_file(run_context.resolve_attribute('nginx', 'source'))


normal['nginx']['install_method']             = 'source'
normal['nginx']['init_style']                 = 'upstart'
normal['nginx']['default_site_enabled']       = false
normal['nginx']['upstart']['foreground']      = false
normal['nginx']['source']['modules']          = [
  'nginx::http_ssl_module',
  'nginx::http_stub_status_module',
  'nginx::http_ssl_module',
  'nginx::http_spdy_module'
]

default['touchbistro_nginx_loadbalancer']['nginx_user']        = "nginx"
default['touchbistro_nginx_loadbalancer']['ssl_crt_directory'] = "/etc/nginx/ssl"

# New Relic System Monitoring Required Attributes
deployment_name = node[:touchbistro_nginx_loadbalancer][:deploy]
key             = node[:custom_env][deployment_name][:NEW_RELIC_LICENSE_KEY]

normal["newrelic-sysmond"]["license_key"]              = key
normal["newrelic-sysmond"]["ssl_ca_path"]              = "/etc/ssl/certs/"

normal["touchbsistro_nginx_loadbalancer"]["enable_newrelic_sysmond"] = true