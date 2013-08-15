# == Class: vas::linux
#
class vas::linux inherits vas {

  $package_ensure = $package_version ? {
    'UNSET' => installed,
    default => $package_version,
  }

  $vasver = regsubst($package_version, '-', '.')
  if ($::vas_version and $vasver > $::vas_version and $package_version != 'UNSET') {
    $upgrade = true
  } else {
    $upgrade = false
  }

  package { ['vasclnt', 'vasyp', 'vasgp'] :
    ensure => $package_ensure,
  }

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
