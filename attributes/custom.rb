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
