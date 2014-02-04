# == Class: vas::linux
#
class vas::linux inherits vas {

  case $::osfamily {
    default: {
      fail("Vas supports Debian, Suse, and RedHat. Detected osfamily is <${::osfamily}>")
    }

    'Debian','Suse','RedHat': {
      $vasver = regsubst($vas::package_version, '-', '.')
      if ($::vas_version and $vasver > $::vas_version and $vas::package_version != 'UNSET') {
        $upgrade = true
      } else {
        $upgrade = false
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
