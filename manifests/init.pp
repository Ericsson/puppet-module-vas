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
  $user_override_hiera_merge                            = false,
  $group_override_entries                               = ['UNSET'],
  $group_override_hiera_merge                           = false,
  $username                                             = 'username',
  $keytab_path                                          = '/etc/vasinst.key',
  $keytab_source                                        = undef,
  $keytab_owner                                         = 'root',
  $keytab_group                                         = 'root',
  $keytab_mode                                          = '0400',
  $vas_fqdn                                             = $::fqdn,
  $computers_ou                                         = 'UNSET',
  $users_ou                                             = 'UNSET',
  $nismaps_ou                                           = 'ou=nismaps,dc=example,dc=com',
  $user_search_path                                     = 'UNSET',
  $group_search_path                                    = 'UNSET',
  $upm_search_path                                      = 'UNSET',
  $nisdomainname                                        = undef,
  $realm                                                = 'realm.example.com',
  $domain_change                                        = false,
  $sitenameoverride                                     = 'UNSET',
  $vas_conf_client_addrs                                = 'UNSET',
  $vas_conf_full_update_interval                        = 'UNSET',
  $vas_conf_group_update_mode                           = 'none',
  $vas_conf_root_update_mode                            = 'none',
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
  $vas_conf_vasd_username_attr_name                     = 'UNSET',
  $vas_conf_vasd_groupname_attr_name                    = 'UNSET',
  $vas_conf_vasd_uid_number_attr_name                   = 'UNSET',
  $vas_conf_vasd_gid_number_attr_name                   = 'UNSET',
  $vas_conf_vasd_gecos_attr_name                        = 'UNSET',
  $vas_conf_vasd_home_dir_attr_name                     = 'UNSET',
  $vas_conf_vasd_login_shell_attr_name                  = 'UNSET',
  $vas_conf_vasd_group_member_attr_name                 = 'UNSET',
  $vas_conf_vasd_memberof_attr_name                     = 'UNSET',
  $vas_conf_vasd_unix_password_attr_name                = 'UNSET',
  $vas_conf_prompt_vas_ad_pw                            = '"Enter Windows password: "',
  $vas_conf_pam_vas_prompt_ad_lockout_msg               = 'UNSET',
  $vas_conf_libdefaults_forwardable                     = true,
  $vas_conf_vas_auth_uid_check_limit                    = 'UNSET',
  $vas_conf_vas_auth_allow_disconnected_auth            = 'UNSET',
  $vas_conf_vas_auth_expand_ac_groups                   = 'UNSET',
  $vas_conf_libvas_vascache_ipc_timeout                 = 15,
  $vas_conf_libvas_use_server_referrals                 = true,
  $vas_conf_libvas_use_server_referrals_version_switch  = '4.1.0.21518',
  $vas_conf_libvas_auth_helper_timeout                  = 10,
  $vas_conf_libvas_mscldap_timeout                      = 1,
  $vas_conf_libvas_site_only_servers                    = false,
  $vas_conf_libvas_use_dns_srv                          = true,
  $vas_conf_libvas_use_tcp_only                         = true,
  $vas_conf_lowercase_names                             = 'UNSET',
  $vas_conf_lowercase_homedirs                          = 'UNSET',
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
  $domain_realms                                        = {},
  $join_domain_controllers                              = 'UNSET',
  $unjoin_vas                                           = false,
) {

  $domain_realms_real = merge({"${vas_fqdn}" => $realm}, $domain_realms)

  $_vas_users_allow_path_default = '/etc/opt/quest/vas/users.allow'
  $_vas_users_deny_path_default = '/etc/opt/quest/vas/users.deny'
  $_vas_user_override_path_default = '/etc/opt/quest/vas/user-override'
  $_vas_group_override_path_default = '/etc/opt/quest/vas/group-override'

  if versioncmp("${::vas_version}", $vas_conf_libvas_use_server_referrals_version_switch) >= 0 { # lint:ignore:only_variable_string
    $vas_conf_libvas_use_server_referrals_default = false
  } else {
    $vas_conf_libvas_use_server_referrals_default = true
  }

  # validate params
  validate_integer($vas_conf_vasd_update_interval)
  validate_integer($vas_conf_vasd_auto_ticket_renew_interval)
  if $vas_conf_vasd_deluser_check_timelimit != 'UNSET' {
    validate_integer($vas_conf_vasd_deluser_check_timelimit)
  }
  if $vas_conf_vasd_delusercheck_interval != 'UNSET' {
    validate_integer($vas_conf_vasd_delusercheck_interval)
  }
  validate_integer($vas_conf_libvas_vascache_ipc_timeout)
  validate_integer($vas_conf_libvas_auth_helper_timeout)
  validate_string($vas_conf_prompt_vas_ad_pw)

  validate_string($user_search_path)
  validate_string($group_search_path)
  validate_string($upm_search_path)
  validate_string($users_ou)
  validate_string($computers_ou)
  validate_string($nismaps_ou)

  validate_string($vas_conf_vasd_username_attr_name)
  validate_string($vas_conf_vasd_groupname_attr_name)
  validate_string($vas_conf_vasd_uid_number_attr_name)
  validate_string($vas_conf_vasd_gid_number_attr_name)
  validate_string($vas_conf_vasd_gecos_attr_name)
  validate_string($vas_conf_vasd_home_dir_attr_name)
  validate_string($vas_conf_vasd_login_shell_attr_name)
  validate_string($vas_conf_vasd_group_member_attr_name)
  validate_string($vas_conf_vasd_memberof_attr_name)
  validate_string($vas_conf_vasd_unix_password_attr_name)

  if $vas_conf_vas_auth_allow_disconnected_auth != 'UNSET' {
    if type3x($vas_conf_vas_auth_allow_disconnected_auth) == 'boolean' {
      $vas_conf_vas_auth_allow_disconnected_auth_string = bool2str($vas_conf_vas_auth_allow_disconnected_auth)
    }
    elsif type3x($vas_conf_vas_auth_allow_disconnected_auth) == 'string' {
      validate_re($vas_conf_vas_auth_allow_disconnected_auth, '^(true|false)$',
        'vas_conf_vas_auth_allow_disconnected_auth is not a boolean. Valid values are <true> and <false>.'
      )
      $vas_conf_vas_auth_allow_disconnected_auth_string = $vas_conf_vas_auth_allow_disconnected_auth
    }
    else {
      fail('vas_conf_vas_auth_allow_disconnected_auth is not a boolean nor a string. Valid values are <true> and <false>.')
    }
  }

  if $vas_conf_vas_auth_expand_ac_groups != 'UNSET' {
    if type3x($vas_conf_vas_auth_expand_ac_groups) == 'boolean' {
      $vas_conf_vas_auth_expand_ac_groups_string = bool2str($vas_conf_vas_auth_expand_ac_groups)
    }
    elsif type3x($vas_conf_vas_auth_expand_ac_groups) == 'string' {
      validate_re($vas_conf_vas_auth_expand_ac_groups, '^(true|false)$',
        'vas_conf_vas_auth_expand_ac_groups is not a boolean. Valid values are <true> and <false>.'
      )
      $vas_conf_vas_auth_expand_ac_groups_string = $vas_conf_vas_auth_expand_ac_groups
    }
    else {
      fail('vas_conf_vas_auth_expand_ac_groups is not a boolean nor a string. Valid values are <true> and <false>.')
    }
  }

  if is_string($domain_change) {
    $domain_change_real = str2bool($domain_change)
  } else {
    $domain_change_real = $domain_change
  }
  validate_bool($domain_change_real)

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

  # client-addrs has a limit of 1024 and vasypd will fail completely
  # if this limit is exceeded!!
  if $vas_conf_client_addrs != 'UNSET' {
    validate_slength($vas_conf_client_addrs,1024)
  }

  if $vas_conf_disabled_user_pwhash != undef {
    validate_string($vas_conf_disabled_user_pwhash)
  }

  if $vas_conf_locked_out_pwhash != undef {
    validate_string($vas_conf_locked_out_pwhash)
  }

  if $vas_conf_group_update_mode != undef {
    validate_string($vas_conf_group_update_mode)
  }

  if $vas_conf_root_update_mode != undef {
    validate_string($vas_conf_root_update_mode)
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

  if is_string($user_override_hiera_merge) {
    $user_override_hiera_merge_real = str2bool($user_override_hiera_merge)
  } else {
    $user_override_hiera_merge_real = $user_override_hiera_merge
  }
  validate_bool($user_override_hiera_merge_real)

  if is_string($group_override_hiera_merge) {
    $group_override_hiera_merge_real = str2bool($group_override_hiera_merge)
  } else {
    $group_override_hiera_merge_real = $group_override_hiera_merge
  }
  validate_bool($group_override_hiera_merge_real)

  if is_string($vas_conf_libdefaults_forwardable) {
    $vas_conf_libdefaults_forwardable_real = str2bool($vas_conf_libdefaults_forwardable)
  } else {
    $vas_conf_libdefaults_forwardable_real = $vas_conf_libdefaults_forwardable
  }

  if is_string($vas_conf_libvas_use_server_referrals) {
    $vas_conf_libvas_use_server_referrals_real = $vas_conf_libvas_use_server_referrals ? {
      'USE_DEFAULTS' => $vas_conf_libvas_use_server_referrals_default,
      default        => str2bool($vas_conf_libvas_use_server_referrals)
    }
  }
  else {
    validate_bool($vas_conf_libvas_use_server_referrals)
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

  if $vas_conf_lowercase_names != 'UNSET' {
    if is_string($vas_conf_lowercase_names) {
      $vas_conf_lowercase_names_real = str2bool($vas_conf_lowercase_names)
    } else {
      $vas_conf_lowercase_names_real = $vas_conf_lowercase_names
    }
  }

  if $vas_conf_lowercase_homedirs != 'UNSET' {
    if is_string($vas_conf_lowercase_homedirs) {
      $vas_conf_lowercase_homedirs_real = str2bool($vas_conf_lowercase_homedirs)
    } else {
      $vas_conf_lowercase_homedirs_real = $vas_conf_lowercase_homedirs
    }
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

  if is_string($unjoin_vas) {
    $unjoin_vas_real = str2bool($unjoin_vas)
  } else {
    $unjoin_vas_real = $unjoin_vas
  }
  validate_bool($unjoin_vas_real)

  if is_string($enable_group_policies) {
    $enable_group_policies_real = str2bool($enable_group_policies)
  } else {
    $enable_group_policies_real = $enable_group_policies
  }

  case type3x($join_domain_controllers) {
    'array': { $join_domain_controllers_real = join($join_domain_controllers, ' ') }
    'string': {
      case $join_domain_controllers {
        'UNSET': { $join_domain_controllers_real = undef }
        default: { $join_domain_controllers_real = $join_domain_controllers }
      }
    }
    default: { fail('vas::join_domain_controllers is not an array nor a string.') }
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

  # Define search paths
  if $upm_search_path == 'UNSET' {
    if $users_ou != 'UNSET' {
      $upm_search_path_real = $users_ou
    } else {
      $upm_search_path_real = undef
    }
  } else {
    $upm_search_path_real = $upm_search_path
  }

  if $user_search_path == 'UNSET' {
    $user_search_path_real = undef
  } else {
    $user_search_path_real = $user_search_path
  }

  if $group_search_path == 'UNSET' {
    $group_search_path_real = undef
  } else {
    $group_search_path_real = $group_search_path
  }


  case $::kernel {
    'Linux': {
      include ::vas::linux
    }
    'SunOS': {
      include ::vas::solaris
    }
    default: {
      fail("Vas module support Linux and SunOS kernels. Detected kernel is <${::kernel}>")
    }
  }

  include ::nisclient
  include ::nsswitch
  include ::pam

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
    $package_ensure = $package_version
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

  if $user_override_hiera_merge_real == true {
    $user_override_entries_real = hiera_array('vas::user_override_entries')
  } else {
    $user_override_entries_real = $user_override_entries
  }

  if $group_override_hiera_merge_real == true {
    $group_override_entries_real = hiera_array('vas::group_override_entries')
  } else {
    $group_override_entries_real = $group_override_entries
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

  $once_file = '/etc/opt/quest/vas/puppet_joined'


  if $unjoin_vas_real == true and $::vas_domain != undef {
      exec { 'vas_unjoin':
        command  => "$(sed 's/\\(.*\\)join.*/\\1unjoin/' /etc/opt/quest/vas/lastjoin) > /tmp/vas_unjoin.txt 2>&1 && rm -f ${once_file}",
        onlyif   => "/usr/bin/test -f ${keytab_path} && /usr/bin/test -f /etc/opt/quest/vas/lastjoin",
        provider => 'shell',
        path     => '/bin:/usr/bin:/opt/quest/bin',
        timeout  => 1800,
        require  => [Package['vasclnt','vasyp','vasgp']],
      }
  } elsif $unjoin_vas_real == false {
    # no run if undef!
    # We should probably have better sanity checks for $realm parameter instead of this.
    if $realm != undef {
      # So we use the fact vas_domain to identify if vas is already joined to a AD
      # server. It will make sure and check that ::vas_domain is not undef before doing this
      # to prevent something from happening at first run.
      # If the vas_domain fact is not the same as the realm specified in hiera it
      # will then check if the domain_change_real parameter is set to true. If it is
      # it will join the domain with help of the lastjoin file.
      # If the domain_change_real fact is false, it will fail the compilation and warn
      # of the mismatching realm.
      if $::vas_domain != $realm and $::vas_domain != undef  {
        if $domain_change_real == true {
          exec { 'vas_change_domain':
            # This command executes the result of the sed command, puts the log from
            # the unjoin command into a log file and removes the once file to allow
            # the  vas_inst command to join the new AD server.
            # This is how the join command is built up by the vas module.
            # ${vastool_binary} -u ${username} -k ${keytab_path} -d3 join -f ${workstation_flag} -c ${computers_ou} ${user_search_path_parm} ${group_search_path_parm} ${upm_search_path_parm} -n ${vas_fqdn}
            # The sed regex will save everything up to but not including the join part.
            # (${vastool_binary} -u ${username} -k ${keytab_path} -d3 )
            # It will save the part above and add to the end of it unjoin.
            # The result would be ${vastool_binary} -u ${username} -k ${keytab_path} -d3 unjoin
            #
            # This sed command is required because we need to use the old credentials
            # and old username to unjoin the currently joined AD.
            # It could be that you need to use a newly created keytab file for perhaps
            # the same/new user required to join the new AD Server. So to join the
            # new AD server we would need updated hiera information for that. Preventing
            # us from using the new hiera data to unjoin the current AD Server.
            command  => "$(sed 's/\\(.*\\)join.*/\\1unjoin/' /etc/opt/quest/vas/lastjoin) > /tmp/vas_unjoin.txt 2>&1 && rm -f ${once_file}",
            onlyif   => "/usr/bin/test -f ${keytab_path} && /usr/bin/test -f /etc/opt/quest/vas/lastjoin",
            provider => 'shell',
            path     => '/bin:/usr/bin:/opt/quest/bin',
            timeout  => 1800,
            before   => [File['vas_config'], File['keytab'], Exec['vasinst']],
            require  => [Package['vasclnt','vasyp','vasgp']],
          }
        } else {
          fail('VAS domain mismatch!')
        }
      }
    }

    file { 'vas_config':
      ensure  => file,
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
      ensure  => file,
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
      ensure  => file,
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
      ensure  => file,
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
      ensure  => file,
      path    => $_vas_group_override_path,
      owner   => $vas_group_override_owner,
      group   => $vas_group_override_group,
      mode    => $vas_group_override_mode,
      content => template('vas/group-override.erb'),
      require => Package['vasclnt','vasyp','vasgp'],
      before  => Service['vasd','vasypd'],
    }

    file { 'keytab':
      ensure => 'file',
      name   => $keytab_path,
      source => $keytab_source,
      owner  => $keytab_owner,
      group  => $keytab_group,
      mode   => $keytab_mode,
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

    if $sitenameoverride == 'UNSET' {
      $s_opts = '' # lint:ignore:empty_string_assignment
    } else {
      $s_opts = "-s ${sitenameoverride}"
    }

    if $vas_conf_vasd_workstation_mode_real == true {
      $workstation_flag = '-w'
    } else {
      $workstation_flag = '' # lint:ignore:empty_string_assignment
    }

    if $user_search_path_real != undef {
      $user_search_path_parm = "-u ${user_search_path_real}"
    } else {
      $user_search_path_parm = '' # lint:ignore:empty_string_assignment
    }
    if $group_search_path_real != undef {
      $group_search_path_parm = "-g ${group_search_path_real}"
    } else {
      $group_search_path_parm = '' # lint:ignore:empty_string_assignment
    }
    if $upm_search_path_real != undef {
      $upm_search_path_parm = "-p ${upm_search_path_real}"
    } else {
      $upm_search_path_parm = '' # lint:ignore:empty_string_assignment
    }

    exec { 'vasinst':
      command => "${vastool_binary} -u ${username} -k ${keytab_path} -d3 join -f ${workstation_flag} -c ${computers_ou} ${user_search_path_parm} ${group_search_path_parm} ${upm_search_path_parm} -n ${vas_fqdn} ${s_opts} ${realm} ${join_domain_controllers_real} > ${vasjoin_logfile} 2>&1 && touch ${once_file}",
      path    => '/sbin:/bin:/usr/bin:/opt/quest/bin',
      timeout => 1800,
      creates => $once_file,
      before  => Class['pam'],
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
}
