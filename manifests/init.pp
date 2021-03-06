class owncloud (
    $nginx = false,
    $domains = undef,
    $ssl = false,
    $ssl_cert = undef,
    $ssl_key = undef,
    $max_upload_size = '1G',
    $ipv6_enable = false,
    $ipv6_listen_ip = undef,
    $ipv6_listen_options = undef,
    $mysql = false,
    $create_db = true,
    $create_db_user = true,
    $db_user = 'owncloud',
    $db_password = 'owncloud',
    $db_host = "localhost",
    $db_name = "owncloud",
    $force_ssl = false,
    $overwritehost = undef,
    $theme = undef,
    $default_app = "files",
    $appstoreenabled = true,
    $mail_domain = "example.com",
    $mail_smtpdebug = false,
    $mail_smtpmode = "sendmail",
    $mail_smtphost = "127.0.0.1",
    $trashbin_retention_obligation = 30,
    $trashbin_auto_expire = true,
    $allow_user_to_change_display_name = true,
    $logfile = undef,
    $loglevel = undef,
    $logtimezone = "Europe/Paris",
    $debug = false,
    $directory = undef,
    $adminlogin = 'root',
    $adminpass = 'root',
    $trusted_domains = $domains,
    $datadirectory = "/var/www/owncloud/data/",
    $maintenance = false,
    $default_language = 'en',
    $instanceid = undef,
    $version = '6.0.3-0',
    $passwordsalt = undef,
    $ldap_local_home = false,
    $defaultapp = 'files',
){
    anchor { 'owncloud::begin': }
    -> class { 'owncloud::app':
      db_name              => $db_name,
      db_host              => $db_host,
      db_user              => $db_user,
      db_password          => $db_password,
      ldap_local_home       => ldap_local_home,
      install_dir          => "/var/www/owncloud",
      version              => $version,
    }
    -> class { 'owncloud::db':
      create_db           => $create_db,
      create_db_user      => $create_db_user,
      db_name             => $db_name,
      db_host             => $db_host,
      db_user             => $db_user,
      db_password         => $db_password,
    }
    -> class { 'owncloud::nginx':
      nginx                 => $nginx,
      domains               => $domains,
      install_dir           => "/var/www/owncloud",
      max_upload_size       => $max_upload_size,
      ssl                   => $ssl,
      ssl_cert              => $ssl_cert,
      ssl_key               => $ssl_key,
      ipv6_enable           => $ipv6_enable,
      ipv6_listen_ip        => $ipv6_listen_ip,
      ipv6_listen_options   => $ipv6_listen_options,
    }
    -> anchor { 'owncloud::end': }
}