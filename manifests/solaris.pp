# == Class: qas::solaris
#
class qas::solaris inherits qas {

  $deps = ['rpc/rstat', 'rpc/keyserv']

  file { '/tmp/generic-pkg-response':
    content => 'CLASSES= run\n',
  }

  package { 'vasclnt':
    ensure       => installed,
    source       => $solaris_vasclntpath,
    adminfile    => $solaris_adminpath,
    responsefile => "${solaris_responsepattern}.vasclnt",
  }
  package { 'vasyp':
    ensure       => installed,
    source       => $solaris_vasyppath,
    adminfile    => $solaris_adminpath,
    responsefile => "${solaris_responsepattern}.vasyp",
  }
  package { 'vasgp':
    ensure       => installed,
    source       => $solaris_vasgppath,
    adminfile    => $solaris_adminpath,
    responsefile => "${solaris_responsepattern}.vasgp",
  }

  service { $deps:
    ensure    => running,
    enable    => true, 
    subscribe => Exec['vasinst'],
    require   => Service['vasypd'],
  }

  #No vasgpd service in QAS 4
  if $::qas_version =~ /^3/ {
    service { 'vasgpd':
      ensure    => running,
      enable    => true,
      provider  => init,
      subscribe => Exec['vasinst'],
    }
  }

  exec { 'deps':
    command     => '/bin/true',
    refreshonly => true,
    notify      => Service[$deps],
  }

}
