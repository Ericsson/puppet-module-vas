# == Class: qas::linux
#
class qas::linux inherits qas {
  
  $package_ensure = $package_version ? {
    'UNSET' => installed,
    default => $package_version,
  }

  $qasver = regsubst($package_version, '-', '.')
  if ($::qas_version and $qasver > $::qas_version and $package_version != 'UNSET') {
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

  #No vasgpd service in QAS 4
  if $::qas_version =~ /^3/ and $upgrade == false {
    service { 'vasgpd':
      ensure    => running,
      enable    => true,
      subscribe => Exec['vasinst'],
    }
  }
}
