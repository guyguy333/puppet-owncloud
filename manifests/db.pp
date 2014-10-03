class owncloud::db (
  $create_db,
  $create_db_user,
  $db_name,
  $db_host,
  $db_user,
  $db_password,
) {
  validate_bool($create_db,$create_db_user)
  validate_string($db_name,$db_host,$db_user,$db_password)

  if $create_db {
    mysql_database { $db_name:
      charset => 'utf8',
      require => Class['owncloud::app'],
    }
  }
  if $create_db_user {
    mysql_user { "${db_user}@${db_host}":
      password_hash => mysql_password($db_password),
      require       => Class['owncloud::app'],
    }
    mysql_grant { "${db_user}@${db_host}/${db_name}.*":
      table      => "${db_name}.*",
      user       => "${db_user}@${db_host}",
      privileges => ['ALL'],
      require    => Class['owncloud::app'],
    }
  }

}