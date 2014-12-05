# === Nginx General Configuration ===
override['nginx']['version']            = '1.6.2'
override['nginx']['source']['checksum'] = 'b5608c2959d3e7ad09b20fc8f9e5bd4bc87b3bc8ba5936a513c04ed8f1391a18'


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