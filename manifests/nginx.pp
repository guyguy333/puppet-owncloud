class owncloud::nginx (
  $nginx,
  $domains,
  $install_dir,
  $max_upload_size,
  $ssl,
  $ssl_cert,
  $ssl_key,
  $ipv6_enable,
  $ipv6_listen_ip,
  $ipv6_listen_options,
) {
    validate_bool($nginx,$ssl,$ipv6_enable)
    validate_string($domains,$path,$max_upload_size,$ssl_cert,$ssl_key,$ipv6_listen_ip,$ipv6_listen_options)
    
    if $nginx {
        nginx::resource::vhost { $domains:
            www_root		      => $install_dir,
            ensure       	      => present,
            listen_port		      => "80",
            client_max_body_size  => $max_upload_size,
            ipv6_enable           => $ipv6_enable,
            ipv6_listen_ip        => $ipv6_listen_ip,
            ipv6_listen_options   => $ipv6_listen_options,
            ssl				      => $ssl,
            index_files  	      => ['index.php'],
            ssl_cert 		      => $ssl_cert,
            ssl_key  		      => $ssl_key,
            rewrite_to_https      => true,
            vhost_cfg_append      => {
                'fastcgi_buffers' => "64 4K",
                'rewrite'         => ["^/caldav(.*)$ /remote.php/caldav$1 redirect",
                                      "^/carddav(.*)$ /remote.php/carddav$1 redirect",
                                      "^/webdav(.*)$ /remote.php/webdav$1 redirect"],
                'error_page'      => ["403 /core/templates/403.php",
                                      "404 /core/templates/404.php"],
            },
            location_cfg_append   => { 
                'try_files'       => '$uri $uri/ index.php',
                'rewrite'         => ["^/.well-known/host-meta /public.php?service=host-meta last", 
                                      "^/.well-known/host-meta.json /public.php?service=host-meta-json last", 
                                      "^/.well-known/carddav /remote.php/carddav/ redirect", 
                                      "^/.well-known/caldav /remote.php/caldav/ redirect", 
                                      '^(/core/doc/[^\/]+/)$ $1/index.html'],         
            },
        }
        
        nginx::resource::location { "${domains}_robots":
            ensure                  => present, 
            vhost                   => $domains,
            www_root		        => $install_dir,
            location                => '= /robots.txt',
            ssl                     => $ssl,
            location_allow          => ['all'],
            location_cfg_append     => {
                'log_not_found'     => 'off',
                'access_log'        => 'off',
            }
        } 
         
        nginx::resource::location { "${domains}_specials":
            ensure          => present, 
            vhost           => $domains,
            www_root		=> $install_dir,
            location        => '~ ^/(data|config|\.ht|db_structure\.xml|README)',
            ssl             => $ssl,
            location_deny   => ['all'],
        }
    
        nginx::resource::location { "${domains}_php":
            ensure          => present, 
            vhost           => $domains,
            www_root        => $install_dir,
            location        => '~ ^(.+?\.php)(/.*)?$',
            ssl				=> $ssl,
            fastcgi         => "unix:/var/run/php5-fpm.sock",
            location_cfg_append => { 
                fastcgi_connect_timeout => '3m',
                fastcgi_read_timeout    => '3m',
                fastcgi_send_timeout    => '3m',
                fastcgi_param           => ['SCRIPT_FILENAME $document_root$1',
                                            'PATH_INFO $2',
                                            'HTTPS on',
                                            "PHP_VALUE \"upload_max_filesize=$max_upload_size 
                                                         post_max_size=$max_upload_size\"",
                                            ],
                try_files               => '$1 = 404', 
            }
        } 
    }
}