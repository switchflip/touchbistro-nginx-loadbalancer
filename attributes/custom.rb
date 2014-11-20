
# === Nginx General Configuration ===


# normal['nginx']['user']                       = 'nginx'
# normal['nginx']['group']                      = 'nginx'

# # PID= /var/run/nginx.pid
# normal['nginx']['pid']                        = '/var/run/nginx.pid'

# # CONFIG= /etc/nginx/nginx.conf
# normal['nginx']['dir']                        = '/etc/nginx'

# # logs /opt/nginx-1.4.4/logs/error.log
# normal['nginx']['log_dir']                    = '/opt/nginx-1.4.4/logs/error.log'

normal['nginx']['install_method']             = 'source'
normal['nginx']['init_style']                 = 'upstart'
normal['nginx']['default_site_enabled']       = false
normal['nginx']['upstart']['foreground']      = false
normal['nginx']['source']['modules']          = [
  'nginx::http_ssl_module',
  'nginx::http_stub_status_module'
]