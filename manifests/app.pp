class owncloud::app (
  $db_name,
  $db_host,
  $db_user,
  $db_password,
  $ldap_local_home,
  $install_dir,
  $version,
) {
  validate_string($db_name,$db_host,$db_user,$db_password)

  apt::key { 'owncloud':
      key        => 'BA684223',
      key_source => 'http://download.opensuse.org/repositories/isv:ownCloud:community/Debian_7.0/Release.key',
  }
  
  apt::source { 'owncloud':
      location    => 'http://download.opensuse.org/repositories/isv:ownCloud:community/Debian_7.0/',
      repos       => '',
      release     => '/',
      include_src => false,
      require     => Apt::Key['owncloud'],
  }
  
  package { 'owncloud':
      ensure       => $version,
      require      => Apt::Source['owncloud'],
  }
  -> exec {"check_owncloud_update":
      command => '/bin/true',
      refreshonly => true,
  }
  
  file {"/var/www/owncloud/config/autoconfig.php": 
        ensure => file,
        path    => '/var/www/owncloud/config/autoconfig.php',
        owner => 'www-data',
        group => 'www-data',
        mode => '0640',
        content => template('owncloud/autoconfig.php.erb'),
        require => [Package["owncloud"], Exec["check_owncloud_update"]],
  }
  
  if $ldap_local_home {
      file {"${install_dir}/apps/user_ldap/user_ldap.php":
          ensure => file,
          path    => "${install_dir}/apps/user_ldap/user_ldap.php",
          owner => 'root',
          group => 'root',
          mode => '0644',
          content => template('owncloud/user_ldap.php.erb'),
          require => Package["owncloud"]
      }  
  }
  
  file {"/var/www/owncloud/config/config.php":
      ensure => file,
      path    => '/var/www/owncloud/config/config.php',
      owner => 'www-data',
      group => 'www-data',
      mode => '0640',
      content => template('owncloud/config.php.erb'),
      require => Package["owncloud"]
  }
  
  
}
