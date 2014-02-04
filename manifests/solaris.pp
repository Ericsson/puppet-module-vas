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

      Package['vasclnt'] {
        ensure       => 'installed',
        source       => $vas::solaris_vasclntpath,
        adminfile    => $vas::solaris_adminpath,
        responsefile => "${vas::solaris_responsepattern}.vasclnt",
      }

      Package['vasyp'] {
        ensure       => 'installed',
        source       => $vas::solaris_vasyppath,
        adminfile    => $vas::solaris_adminpath,
        responsefile => "${vas::solaris_responsepattern}.vasyp",
      }

      Package['vasgp'] {
        ensure       => 'installed',
        source       => $vas::solaris_vasgppath,
        adminfile    => $vas::solaris_adminpath,
        responsefile => "${vas::solaris_responsepattern}.vasgp",
      }

      service { 'vas_deps':
        ensure    => 'running',
        name      => $deps,
        enable    => true,
        require   => Service['vasypd'],
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
  }
}
