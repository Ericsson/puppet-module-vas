# == Class: vas
#
# Puppet module to manage VAS - Quest Authentication Services
#
class vas (
  $package_version                                      = undef,
  $enable_group_policies                                = true,
  $users_allow_entries                                  = ['UNSET'],
  $users_allow_hiera_merge                              = false,
  $users_deny_entries                                   = ['UNSET'],
  $users_deny_hiera_merge                               = false,
  $user_override_entries                                = ['UNSET'],
  $group_override_entries                               = ['UNSET'],
  $username                                             = 'username',
  $keytab_path                                          = '/etc/vasinst.key',
  $keytab_source                                        = undef,
  $keytab_owner                                         = 'root',
  $keytab_group                                         = 'root',
  $keytab_mode                                          = '0400',
  $vas_fqdn                                             = $::fqdn,
  $computers_ou                                         = 'ou=computers,dc=example,dc=com',
  $users_ou                                             = 'ou=users,dc=example,dc=com',
  $nismaps_ou                                           = 'ou=nismaps,dc=example,dc=com',
  $nisdomainname                                        = undef,
  $realm                                                = 'realm.example.com',
  $sitenameoverride                                     = 'UNSET',
  $vas_conf_client_addrs                                = 'UNSET',
  $vas_conf_full_update_interval                        = 'UNSET',
  $vas_conf_disabled_user_pwhash                        = undef,
  $vas_conf_locked_out_pwhash                           = undef,
  $vas_conf_preload_nested_memberships                  = 'UNSET',
  $vas_conf_update_process                              = '/opt/quest/libexec/vas/mapupdate_2307',
  $vas_conf_upm_computerou_attr                         = 'department',
  $vas_conf_vasd_update_interval                        = '600',
  $vas_conf_vasd_auto_ticket_renew_interval             = '32400',
  $vas_conf_vasd_lazy_cache_update_interval             = '10',
  $vas_conf_vasd_timesync_interval                      = 'USE_DEFAULTS',
  $vas_conf_vasd_cross_domain_user_groups_member_search = 'UNSET',
  $vas_conf_vasd_password_change_script                 = 'UNSET',
  $vas_conf_vasd_password_change_script_timelimit       = 'UNSET',
  $vas_conf_vasd_workstation_mode                       = false,
  $vas_conf_vasd_workstation_mode_users_preload         = 'UNSET',
  $vas_conf_vasd_workstation_mode_group_do_member       = false,
  $vas_conf_vasd_workstation_mode_groups_skip_update    = false,
  $vas_conf_vasd_ws_resolve_uid                         = false,
  $vas_conf_vasd_deluser_check_timelimit                = 'UNSET',
  $vas_conf_vasd_delusercheck_interval                  = 'UNSET',
  $vas_conf_vasd_delusercheck_script                    = 'UNSET',
  $vas_conf_prompt_vas_ad_pw                            = '"Enter Windows password: "',
  $vas_conf_pam_vas_prompt_ad_lockout_msg               = 'UNSET',
  $vas_conf_libdefaults_forwardable                     = true,
  $vas_conf_vas_auth_uid_check_limit                    = 'UNSET',
  $vas_conf_libvas_vascache_ipc_timeout                 = 15,
  $vas_conf_libvas_use_server_referrals                 = true,
  $vas_conf_libvas_auth_helper_timeout                  = 10,
  $vas_conf_libvas_mscldap_timeout                      = 1,
  $vas_conf_libvas_site_only_servers                    = false,
  $vas_conf_libvas_use_dns_srv                          = true,
  $vas_conf_libvas_use_tcp_only                         = true,
  $vas_config_path                                      = '/etc/opt/quest/vas/vas.conf',
  $vas_config_owner                                     = 'root',
  $vas_config_group                                     = 'root',
  $vas_config_mode                                      = '0644',
  $vas_user_override_path                               = 'UNSET',
  $vas_user_override_owner                              = 'root',
  $vas_user_override_group                              = 'root',
  $vas_user_override_mode                               = '0644',
  $vas_group_override_path                              = 'UNSET',
  $vas_group_override_owner                             = 'root',
  $vas_group_override_group                             = 'root',
  $vas_group_override_mode                              = '0644',
  $vas_users_allow_path                                 = 'UNSET',
  $vas_users_allow_owner                                = 'root',
  $vas_users_allow_group                                = 'root',
  $vas_users_allow_mode                                 = '0644',
  $vas_users_deny_path                                  = 'UNSET',
  $vas_users_deny_owner                                 = 'root',
  $vas_users_deny_group                                 = 'root',
  $vas_users_deny_mode                                  = '0644',
  $vasjoin_logfile                                      = '/var/tmp/vasjoin.log',
  $solaris_vasclntpath                                  = 'UNSET',
  $solaris_vasyppath                                    = 'UNSET',
  $solaris_vasgppath                                    = 'UNSET',
  $solaris_adminpath                                    = 'UNSET',
  $solaris_responsepattern                              = 'UNSET',
  $vastool_binary                                       = '/opt/quest/bin/vastool',
  $symlink_vastool_binary_target                        = '/usr/bin/vastool',
  $symlink_vastool_binary                               = false,
  $license_files                                        = undef,
) {

  $_vas_users_allow_path_default = '/etc/opt/quest/vas/users.allow'
  $_vas_users_deny_path_default = '/etc/opt/quest/vas/users.deny'
  $_vas_user_override_path_default = '/etc/opt/quest/vas/user-override'
  $_vas_group_override_path_default = '/etc/opt/quest/vas/group-override'

  # validate params
  validate_re($vas_conf_vasd_auto_ticket_renew_interval, '^\d+$', "vas::vas_conf_vasd_auto_ticket_renew_interval must be an integer. Detected value is <${vas_conf_vasd_auto_ticket_renew_interval}>.")
  validate_re($vas_conf_vasd_update_interval, '^\d+$', "vas::vas_conf_vasd_update_interval must be an integer. Detected value is <${vas_conf_vasd_update_interval}>.")
  if $vas_conf_vasd_deluser_check_timelimit != 'UNSET' {
    validate_re($vas_conf_vasd_deluser_check_timelimit, '^\d+$', "vas::vas_conf_vasd_deluser_check_timelimit must be an integer. Detected value is <${vas_conf_vasd_deluser_check_timelimit}>.")
  }
  if $vas_conf_vasd_delusercheck_interval != 'UNSET' {
    validate_re($vas_conf_vasd_delusercheck_interval, '^\d+$', "vas::vas_conf_vasd_delusercheck_interval must be an integer. Detected value is <${vas_conf_vasd_delusercheck_interval}>.")
  }
  validate_re($vas_conf_libvas_vascache_ipc_timeout, '^\d+$', "vas::vas_conf_libvas_vascache_ipc_timeout must be an integer. Detected value is <${vas_conf_libvas_vascache_ipc_timeout}>.")
  validate_re($vas_conf_libvas_auth_helper_timeout, '^\d+$', "vas::vas_conf_libvas_auth_helper_timeout must be an integer. Detected value is <${vas_conf_libvas_auth_helper_timeout}>.")
  validate_string($vas_conf_prompt_vas_ad_pw)

  validate_absolute_path($vas_config_path)
  if $vas_conf_vasd_delusercheck_script != 'UNSET' {
    validate_absolute_path($vas_conf_vasd_delusercheck_script)
  }
  if $vas_users_allow_path != 'UNSET' {
    validate_absolute_path($vas_users_allow_path)
  }
  if $vas_users_deny_path != 'UNSET' {
    validate_absolute_path($vas_users_deny_path)
  }
  if $vas_user_override_path != 'UNSET' {
    validate_absolute_path($vas_user_override_path)
  }
  if $vas_group_override_path != 'UNSET' {
    validate_absolute_path($vas_group_override_path)
  }

  if $vas_conf_disabled_user_pwhash != undef {
    validate_string($vas_conf_disabled_user_pwhash)
  }

  if $vas_conf_locked_out_pwhash != undef {
    validate_string($vas_conf_locked_out_pwhash)
  }

  if $license_files != undef {
    validate_hash($license_files)

    $license_files_defaults = {
      'ensure' => 'file',
      'path' => '/etc/opt/quest/vas/.licenses/VAS_license',
      'require' => Package['vasclnt'],
    }

    create_resources(file, $license_files, $license_files_defaults)
  }

  if !is_domain_name($vas_fqdn) {
    fail("vas::vas_fqdn is not a valid FQDN. Detected value is <${vas_fqdn}>.")
  }

  if is_string($users_allow_hiera_merge) {
    $users_allow_hiera_merge_real = str2bool($users_allow_hiera_merge)
  } else {
    $users_allow_hiera_merge_real = $users_allow_hiera_merge
  }
  validate_bool($users_allow_hiera_merge_real)

  if is_string($users_deny_hiera_merge) {
    $users_deny_hiera_merge_real = str2bool($users_deny_hiera_merge)
  } else {
    $users_deny_hiera_merge_real = $users_deny_hiera_merge
  }
  validate_bool($users_deny_hiera_merge_real)

  if is_string($vas_conf_libdefaults_forwardable) {
    $vas_conf_libdefaults_forwardable_real = str2bool($vas_conf_libdefaults_forwardable)
  } else {
    $vas_conf_libdefaults_forwardable_real = $vas_conf_libdefaults_forwardable
  }

  if is_string($vas_conf_libvas_use_server_referrals) {
    $vas_conf_libvas_use_server_referrals_real = str2bool($vas_conf_libvas_use_server_referrals)
  } else {
    $vas_conf_libvas_use_server_referrals_real = $vas_conf_libvas_use_server_referrals
  }

  if is_string($vas_conf_libvas_use_dns_srv) {
    $vas_conf_libvas_use_dns_srv_real = str2bool($vas_conf_libvas_use_dns_srv)
  } else {
    $vas_conf_libvas_use_dns_srv_real = $vas_conf_libvas_use_dns_srv
  }

  if is_string($vas_conf_libvas_use_tcp_only) {
    $vas_conf_libvas_use_tcp_only_real = str2bool($vas_conf_libvas_use_tcp_only)
  } else {
    $vas_conf_libvas_use_tcp_only_real = $vas_conf_libvas_use_tcp_only
  }

  if is_string($vas_conf_libvas_site_only_servers) {
    $vas_conf_libvas_site_only_servers_real = str2bool($vas_conf_libvas_site_only_servers)
  } else {
    $vas_conf_libvas_site_only_servers_real = $vas_conf_libvas_site_only_servers
  }

  if is_string($vas_conf_vasd_workstation_mode) {
    $vas_conf_vasd_workstation_mode_real = str2bool($vas_conf_vasd_workstation_mode)
  } else {
    $vas_conf_vasd_workstation_mode_real = $vas_conf_vasd_workstation_mode
  }

  if is_string($vas_conf_vasd_workstation_mode_group_do_member) {
    $vas_conf_vasd_workstation_mode_group_do_member_real = str2bool($vas_conf_vasd_workstation_mode_group_do_member)
  } else {
    $vas_conf_vasd_workstation_mode_group_do_member_real = $vas_conf_vasd_workstation_mode_group_do_member
  }

  if is_string($vas_conf_vasd_workstation_mode_groups_skip_update) {
    $vas_conf_vasd_workstation_mode_groups_skip_update_real = str2bool($vas_conf_vasd_workstation_mode_groups_skip_update)
  } else {
    $vas_conf_vasd_workstation_mode_groups_skip_update_real = $vas_conf_vasd_workstation_mode_groups_skip_update
  }
  if is_string($vas_conf_vasd_ws_resolve_uid) {
    $vas_conf_vasd_ws_resolve_uid_real = str2bool($vas_conf_vasd_ws_resolve_uid)
  } else {
    $vas_conf_vasd_ws_resolve_uid_real = $vas_conf_vasd_ws_resolve_uid
  }

  if is_string($enable_group_policies) {
    $enable_group_policies_real = str2bool($enable_group_policies)
  } else {
    $enable_group_policies_real = $enable_group_policies
  }

  case $::virtual {
    'zone': {
      $default_vas_conf_vasd_timesync_interval = 0
    }
    default: {
      $default_vas_conf_vasd_timesync_interval = 'UNSET'
    }
  }

  # Use defaults if a value was not specified in Hiera.
  if $vas_conf_vasd_timesync_interval == 'USE_DEFAULTS' {
    $vas_conf_vasd_timesync_interval_real = $default_vas_conf_vasd_timesync_interval
  } else {
    $vas_conf_vasd_timesync_interval_real = $vas_conf_vasd_timesync_interval
  }

  case $::kernel {
    'Linux': {
      case $::osfamily {
        'Debian','Suse','RedHat': { }
        default: {
          fail("Vas supports Debian, Suse, and RedHat. Detected osfamily is <${::osfamily}>")
        }
      }
    }
    'SunOS': {
      case $::kernelrelease {
        '5.9': {
          $service_deps = ['rpc']
          $service_deps_hasstatus = false
        }
        '5.10','5.11': {
          $service_deps = ['rpc/bind']
          $service_deps_hasstatus = true
        }
        default: {
          fail("Vas supports Solaris kernelrelease 5.9, 5.10 and 5.11. Detected kernelrelease is <${::kernelrelease}>")
        }
      }
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
    if $::kernel == 'SunOS' {
      $package_ensure = 'installed'
    } else {
      $package_ensure = $package_version
    }

    $vasver = regsubst($package_version, '-', '.')
    if ($::vas_version and $vasver > $::vas_version and $package_version) {
      $upgrade = true
    } else {
      $upgrade = false
    }
  }

  if $enable_group_policies_real == true {
    $gp_package_ensure = $package_ensure
  } else {
    $gp_package_ensure = 'absent'
  }

  if $users_allow_hiera_merge_real == true {
    $users_allow_entries_real = hiera_array('vas::users_allow_entries')
  } else {
    $users_allow_entries_real = $users_allow_entries
  }

  if $users_deny_hiera_merge_real == true {
    $users_deny_entries_real = hiera_array('vas::users_deny_entries')
  } else {
    $users_deny_entries_real = $users_deny_entries
  }

  package { 'vasclnt':
    ensure => $package_ensure,
  }

  package { 'vasyp':
    ensure => $package_ensure,
  }

  package { 'vasgp':
    ensure => $gp_package_ensure,
  }

  if $::kernel == 'SunOS' {
    file { '/tmp/generic-pkg-response':
      content => 'CLASSES= run\n',
    }

    Package['vasclnt'] {
      source       => $solaris_vasclntpath,
      adminfile    => $solaris_adminpath,
      responsefile => "${solaris_responsepattern}.vasclnt",
      provider     => 'sun',
    }

    Package['vasyp'] {
      source       => $solaris_vasyppath,
      adminfile    => $solaris_adminpath,
      responsefile => "${solaris_responsepattern}.vasyp",
      provider     => 'sun',
    }

    Package['vasgp'] {
      source       => $solaris_vasgppath,
      adminfile    => $solaris_adminpath,
      responsefile => "${solaris_responsepattern}.vasgp",
      provider     => 'sun',
    }
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

  $_vas_users_allow_path = $vas_users_allow_path ? {
    'UNSET' => $_vas_users_allow_path_default,
    default => $vas_users_allow_path,
  }
  file { 'vas_users_allow':
    ensure  => present,
    path    => $_vas_users_allow_path,
    owner   => $vas_users_allow_owner,
    group   => $vas_users_allow_group,
    mode    => $vas_users_allow_mode,
    content => template('vas/users.allow.erb'),
    require => Package['vasclnt','vasyp','vasgp'],
  }

  $_vas_users_deny_path = $vas_users_deny_path ? {
    'UNSET' => $_vas_users_deny_path_default,
    default => $vas_users_deny_path,
  }
  file { 'vas_users_deny':
    ensure  => present,
    path    => $_vas_users_deny_path,
    owner   => $vas_users_deny_owner,
    group   => $vas_users_deny_group,
    mode    => $vas_users_deny_mode,
    content => template('vas/users.deny.erb'),
    require => Package['vasclnt','vasyp','vasgp'],
  }

  $_vas_user_override_path = $vas_user_override_path ? {
    'UNSET' => $_vas_user_override_path_default,
    default => $vas_user_override_path,
  }
  file { 'vas_user_override':
    ensure  => present,
    path    => $_vas_user_override_path,
    owner   => $vas_user_override_owner,
    group   => $vas_user_override_group,
    mode    => $vas_user_override_mode,
    content => template('vas/user-override.erb'),
    require => Package['vasclnt','vasyp','vasgp'],
    before  => Service['vasd','vasypd'],
  }

  $_vas_group_override_path = $vas_group_override_path ? {
    'UNSET' => $_vas_group_override_path_default,
    default => $vas_group_override_path,
  }
  file { 'vas_group_override':
    ensure  => present,
    path    => $_vas_group_override_path,
    owner   => $vas_group_override_owner,
    group   => $vas_group_override_group,
    mode    => $vas_group_override_mode,
    content => template('vas/group-override.erb'),
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

  if $::kernel == 'SunOS' {
    service { 'vas_deps':
      ensure    => 'running',
      name      => $service_deps,
      enable    => true,
      hasstatus => $service_deps_hasstatus,
      notify    => Service['vasypd'],
    }
  }

  # No vasgpd service in VAS 4
  if $::vas_version =~ /^3/ and $upgrade == false {
    service { 'vasgpd':
      ensure   => 'running',
      enable   => true,
      require  => Service['vasd'],
    }
    if $::kernel == 'SunOS' {
      Service['vasgpd'] {
        provider => 'init',
      }
    }
  }

  if $sitenameoverride == 'UNSET' {
    $s_opts = ''
  } else {
    $s_opts = "-s ${sitenameoverride}"
  }

  if $vas_conf_vasd_workstation_mode_real == true {
    $workstation_flag = "-w"
  } else {
    $workstation_flag = ""
  }

  $once_file = '/etc/opt/quest/vas/puppet_joined'

  exec { 'vasinst':
    command => "${vastool_binary} -u ${username} -k ${keytab_path} -d3 join -f ${workstation_flag} -c ${computers_ou} -p ${users_ou} -n ${vas_fqdn} ${s_opts} ${realm} > ${vasjoin_logfile} 2>&1 && touch ${once_file}",
    path    => '/bin:/usr/bin:/opt/quest/bin',
    timeout => 1800,
    creates => $once_file,
    require => [Package['vasclnt','vasyp','vasgp'],File['keytab']],
  }

  if is_string($symlink_vastool_binary) {
    $symlink_vastool_binary_bool = str2bool($symlink_vastool_binary)
  } else {
    $symlink_vastool_binary_bool = $symlink_vastool_binary
  }
  validate_bool($symlink_vastool_binary_bool)

  # optionally create symlinks to vastool binary
  if $symlink_vastool_binary_bool == true {
    # validate params
    validate_absolute_path($symlink_vastool_binary_target)
    validate_absolute_path($vastool_binary)

    file { 'vastool_symlink':
      ensure => link,
      path   => $symlink_vastool_binary_target,
      target => $vastool_binary,
    }
  }
}
