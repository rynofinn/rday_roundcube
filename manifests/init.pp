# roundcube class

class rday_roundcube {
  $cube = hiera('cube')

  service { 'httpd':
    ensure => running,
    enable => true,
  }

  package { 'roundcubemail':
    ensure => 'installed',
  }
  package { 'httpd':
    ensure => 'installed',
  }
  package { 'php-mysql':
    ensure => 'installed',
  }
  package { 'php-mcrypt':
    ensure => 'installed',
  }

  file { '/var/lib/roundcubemail':
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
    mode   => '0755',
  }

  file { '/var/log/roundcubemail':
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
    mode   => '0755',
  }

  file { '/etc/roundcubemail/config.inc.php':
    ensure => file,
    owner  => 'root',
    group  => 'apache',
    mode   => '0640',
    content => template('rday_roundcube/config.inc.php.erb'),
    require => Package['roundcubemail'],
    notify => Service['httpd'],
  }

  file { '/etc/httpd/conf.d/roundcubemail.conf':
    ensure => file,
    owner  => 'root',
    group  => 'apache',
    mode   => '0644',
    content => template('rday_roundcube/roundcubemail.conf.erb'),
    require => [
      Package['roundcubemail'],
      Package['httpd'],
    ],
    notify => Service['httpd'],
  }

  file { '/etc/php.d/50-timezone.ini':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    content => template('rday_roundcube/50-timezone.ini.erb'),
    require => [
      Package['httpd'],
    ],
    notify => Service['httpd'],
  }

  file { 'server_cert':
    ensure => file,
    path   => "/etc/ssl/certs/${cube[server_cert]}",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/rday_roundcube/${cube[server_cert]}",
  }

  selboolean { 'httpd_can_network_connect':
      value      => on,
      persistent => true,
  }

}
