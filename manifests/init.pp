# == Class: vas
#
# Puppet module to manage VAS - Quest Authentication Services
#
class vas (
  $package_version                     = undef,
  $users_allow_entries                 = ['UNSET'],
  $user_override_entries               = ['UNSET'],
  $username                            = 'username',
  $keytab_path                         = '/etc/vasinst.key',
  $keytab_source                       = undef,
  $keytab_owner                        = 'root',
  $keytab_group                        = 'root',
  $keytab_mode                         = '0400',
  $computers_ou                        = 'ou=computers,dc=example,dc=com',
  $users_ou                            = 'ou=users,dc=example,dc=com',
  $nismaps_ou                          = 'ou=nismaps,dc=example,dc=com',
  $nisdomainname                       = undef,
  $realm                               = 'realm.example.com',
  $sitenameoverride                    = 'UNSET',
  $vas_conf_client_addrs               = 'UNSET',
  $vas_conf_preload_nested_memberships = 'UNSET',
  $vas_conf_update_process             = '/opt/quest/libexec/vas/mapupdate_2307',
  $vas_conf_upm_computerou_attr        = 'department',
  $vas_config_path                     = '/etc/opt/quest/vas/vas.conf',
  $vas_config_owner                    = 'root',
  $vas_config_group                    = 'root',
  $vas_config_mode                     = '0644',
  $vas_user_override_path              = '/etc/opt/quest/vas/user-override',
  $vas_user_override_owner             = 'root',
  $vas_user_override_group             = 'root',
  $vas_user_override_mode              = '0644',
  $vas_users_allow_path                = '/etc/opt/quest/vas/users.allow',
  $vas_users_allow_owner               = 'root',
  $vas_users_allow_group               = 'root',
  $vas_users_allow_mode                = '0644',
  $vasjoin_logfile                     = '/var/tmp/vasjoin.log',
  $solaris_vasclntpath                 = 'UNSET',
  $solaris_vasyppath                   = 'UNSET',
  $solaris_vasgppath                   = 'UNSET',
  $solaris_adminpath                   = 'UNSET',
  $solaris_responsepattern             = 'UNSET',
) {

  case $::kernel {
    'Linux': {
      include vas::linux
    }
    'SunOS': {
      include vas::solaris
    }
    default: {
      fail("Vas module support Linux and SunOS kernels. Detected kernel is <${::kernel}>")
    }
  }

  include nisclient
  include nsswitch
  include pam

  # Use nisdomainname is supplied. If not, use nisclient::domainname if it
  # exists, last resort fall back to domain fact
  if $nisdomainname == undef {
    if $nisclient::domainname != undef {
      $my_nisdomainname = $nisclient::domainname
    } else {
      $my_nisdomainname = $::domain
    }
  } else {
    $my_nisdomainname = $nisdomainname
  }

  if $package_version == undef {
    $package_ensure = 'installed'
  } else {
    $package_ensure = $package_version
  }

  package { 'vasclnt':
    ensure => $package_ensure,
  }

  package { 'vasyp':
    ensure => $package_ensure,
  }

  package { 'vasgp':
    ensure => $package_ensure,
  }

  file { 'vas_config':
    ensure  => present,
    path    => $vas_config_path,
    owner   => $vas_config_owner,
    group   => $vas_config_group,
    mode    => $vas_config_mode,
    content => template('vas/vas.conf.erb'),
    require => Package['vasclnt','vasyp','vasgp'],
  }

  file { 'vas_users_allow':
    ensure  => present,
    path    => $vas_users_allow_path,
    owner   => $vas_users_allow_owner,
    group   => $vas_users_allow_group,
    mode    => $vas_users_allow_mode,
    content => template('vas/users.allow.erb'),
    require => Package['vasclnt','vasyp','vasgp'],
  }

  file { 'vas_user_override':
    ensure  => present,
    path    => $vas_user_override_path,
    owner   => $vas_user_override_owner,
    group   => $vas_user_override_group,
    mode    => $vas_user_override_mode,
    content => template('vas/user-override.erb'),
    require => Package['vasclnt','vasyp','vasgp'],
    before  => Service['vasd','vasypd'],
  }

  file { 'keytab':
    ensure  => 'present',
    name    => $keytab_path,
    source  => $keytab_source,
    owner   => $keytab_owner,
    group   => $keytab_group,
    mode    => $keytab_mode,
  }

  service { 'vasd':
    ensure  => 'running',
    enable  => true,
    require => Exec['vasinst'],
  }

  service { 'vasypd':
    ensure  => 'running',
    enable  => true,
    require => Service['vasd'],
    before  => Class['nisclient'],
  }

  if $sitenameoverride == 'UNSET' {
    $s_opts = ''
  } else {
    $s_opts = "-s ${sitenameoverride}"
  }

  $once_file = '/etc/opt/quest/vas/puppet_joined'

  exec { 'vasinst':
    command => "vastool -u ${username} -k ${keytab_path} -d3 join -f -c ${computers_ou} -p ${users_ou} -n ${::fqdn} ${s_opts} ${realm} > ${vasjoin_logfile} 2>&1 && touch ${once_file}",
    path    => '/bin:/usr/bin:/opt/quest/bin',
    timeout => 1800,
    creates => $once_file,
    require => [Package['vasclnt','vasyp','vasgp'],File['keytab']],
  }
}
