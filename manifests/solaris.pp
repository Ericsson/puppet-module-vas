# == Class: vas::solaris
#
class vas::solaris inherits vas {

  case $::kernelrelease {
    default: {
      fail("Vas supports Solaris 10 (kernelrelease 5.10). Detected kernelrelease is <${::kernelrelease}>")
    }

    '5.10': {
      $deps = ['rpc/rstat', 'rpc/keyserv']

      file { '/tmp/generic-pkg-response':
        content => 'CLASSES= run\n',
      }

      package { 'vasclnt':
        ensure       => installed,
        source       => $vas::solaris_vasclntpath,
        adminfile    => $vas::solaris_adminpath,
        responsefile => "${vas::solaris_responsepattern}.vasclnt",
      }

      package { 'vasyp':
        ensure       => installed,
        source       => $vas::solaris_vasyppath,
        adminfile    => $vas::solaris_adminpath,
        responsefile => "${vas::solaris_responsepattern}.vasyp",
      }

      package { 'vasgp':
        ensure       => installed,
        source       => $vas::solaris_vasgppath,
        adminfile    => $vas::solaris_adminpath,
        responsefile => "${vas::solaris_responsepattern}.vasgp",
      }

      service { $deps:
        ensure    => running,
        enable    => true,
        subscribe => Exec['vasinst'],
        require   => Service['vasypd'],
      }

      # No vasgpd service in VAS 4
      if $::vas_version =~ /^3/ {
        service { 'vasgpd':
          ensure    => running,
          enable    => true,
          provider  => init,
          subscribe => Exec['vasinst'],
        }
      }

      # GH: wtf?
      exec { 'deps':
        command     => '/bin/true',
        refreshonly => true,
        notify      => Service[$deps],
      }
    }
  }
}
