# == Class: vas::linux
#
class vas::linux inherits vas {

  case $::osfamily {
    default: {
      fail("Vas supports Debian, Suse, and RedHat. Detected osfamily is <${::osfamily}>")
    }

    'Debian','Suse','RedHat': {
      $package_ensure = $vas::package_version ? {
        'UNSET' => installed,
        default => $vas::package_version,
      }

      $vasver = regsubst($vas::package_version, '-', '.')
      if ($::vas_version and $vasver > $::vas_version and $vas::package_version != 'UNSET') {
        $upgrade = true
      } else {
        $upgrade = false
      }

      package { ['vasclnt', 'vasyp', 'vasgp'] :
        ensure => $package_ensure,
      }

      # GH: wtf?
      exec { 'deps' :
        command     => '/bin/true',
        refreshonly => true,
      }

      # No vasgpd service in VAS 4
      if $::vas_version =~ /^3/ and $upgrade == false {
        service { 'vasgpd':
          ensure    => running,
          enable    => true,
          subscribe => Exec['vasinst'],
        }
      }
    }
  }
}
