# === Nginx General Configuration ===
override['nginx']['version'] = '1.6.1'
override['nginx']['source']['checksum'] = '943ad757a1c3e8b3df2d5c4ddacc508861922e36fa10ea6f8e3a348fc9abfc1a'

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