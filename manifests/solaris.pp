# == Class: vas::solaris
#
class vas::solaris inherits vas {

  case $::kernelrelease {
    default: {
      fail("Vas supports Solaris kernelrelease 5.9, 5.10 and 5.11. Detected kernelrelease is <${::kernelrelease}>")
    }

    '5.9': {
      $deps = ['rpc']
      $hasstatus = false
    }

    '5.10','5.11': {
      $deps = ['rpc/bind']
      $hasstatus = true
    }

  }

      file { '/tmp/generic-pkg-response':
        content => 'CLASSES= run\n',
      }

      Package['vasclnt'] {
        ensure       => 'installed',
        source       => $vas::solaris_vasclntpath,
        adminfile    => $vas::solaris_adminpath,
        responsefile => "${vas::solaris_responsepattern}.vasclnt",
        provider     => 'sun',
      }

      Package['vasyp'] {
        ensure       => 'installed',
        source       => $vas::solaris_vasyppath,
        adminfile    => $vas::solaris_adminpath,
        responsefile => "${vas::solaris_responsepattern}.vasyp",
        provider     => 'sun',
      }

      Package['vasgp'] {
        ensure       => 'installed',
        source       => $vas::solaris_vasgppath,
        adminfile    => $vas::solaris_adminpath,
        responsefile => "${vas::solaris_responsepattern}.vasgp",
        provider     => 'sun',
      }

      service { 'vas_deps':
        ensure    => 'running',
        name      => $deps,
        enable    => true,
        hasstatus => $hasstatus,
        notify    => Service['vasypd'],
      }

      # No vasgpd service in VAS 4
      if $::vas_version =~ /^3/ {
        service { 'vasgpd':
          ensure   => 'running',
          enable   => true,
          provider => 'init',
          require  => Service['vasd'],
        }
      }
}
