# == Class: qas
#
# Puppet module to manage Quest Authentication Services
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class qas(
  $ensure                       = 'present',
  $package_version              = 'UNSET',
  $users_allow_entries          = ['UNSET'],
  $user_override_entries        = ['UNSET'],
  $username                     = 'username',
  $keytab_source                = 'UNSET',
  $keytab_target                = '/etc/vasinst.key',
  $computers_ou                 = 'ou=computers,ou=ericsson,ou=se',
  $users_ou                     = 'ou=users,ou=ericsson,ou=se',
  $nismaps_ou                   = 'ou=nismaps,ou=ericsson,ou=se',
  $realm                        = 'rnd.ericsson.se',
  $sitenameoverride             = 'UNSET',
  $vas_conf_update_process      = '/opt/quest/libexec/vas/mapupdate_2307',
  $vas_conf_upm_computerou_attr = 'department',
  $vas_conf_client_addrs        = 'UNSET',
  
  $solaris_vasclntpath          = 'UNSET',
  $solaris_vasyppath            = 'UNSET',
  $solaris_vasgppath            = 'UNSET',
  $solaris_adminpath            = 'UNSET',
  $solaris_responsepattern      = 'UNSET',

) {

  case $::osfamily {
    /Suse|RedHat|Debian/: {
      include qas::linux
    }
    /Solaris/: {
      fail("Module ${module_name} has not been tested on ${::osfamily}")
      #include qas::solaris
    }
    default: {
      fail("Module ${module_name} not supported on osfamily <${::osfamily}>")
    }
  }

  include nisclient
  #include nsswitch
  #include pam

  $nisdomainname = $nisclient::domainname

  Package['vasclnt'] -> Package['vasyp'] -> Package['vasgp'] -> Exec['vasinst']

  file { '/etc/opt/quest/vas/vas.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template('qas/vas.conf.erb'),
    require => Package['vasgp'],
  }

  file { '/etc/opt/quest/vas/users.allow':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template('qas/users.allow.erb'),
    require => Package['vasclnt','vasyp','vasgp'],
  }

  file { '/etc/opt/quest/vas/user-override':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template('qas/user-override.erb'),
    require => Package['vasclnt','vasyp','vasgp'],
    before  => Service['vasd','vasypd'],
  }

  file { $keytab_target:
    ensure => present,
    owner  => root,
    group  => root,
    mode   => 0400,
    source => "puppet:///${keytab_source}",
  }
  
  service { ['vasd','vasypd']:
    ensure    => running,
    enable    => true,
    subscribe => Exec['vasinst'],
    notify    => Service[$nisclient::service_name],
  }
  
  $s_opts = $sitenameoverride ? {
    'UNSET' => '',
    default => "-s ${sitenameoverride}",
  }
  
  $once_file = '/etc/opt/quest/vas/puppet_joined'

  exec { 'vasinst':
    path    => '/bin:/usr/bin',
    command => "/opt/quest/bin/vastool -u ${username} -k ${keytab_target} -d3 join -f -c ${computers_ou} -p ${users_ou} -n ${::fqdn} ${s_opts} ${realm} >/var/tmp/vasjoin.log 2>&1 && touch ${once_file}",
    timeout => 1200,
    creates => $once_file,
    require => File[$keytab_target],
    notify  => Exec['deps'],
  }

}
