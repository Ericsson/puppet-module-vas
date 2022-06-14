# Puppet module to manage DELL Authentication Services previously known as VAS or
# Quest Authentication Services.
#
# When using the users.allow functionality in VAS, make sure to set the following option:
# pam::allowed_users:
#   - 'ALL'
#
# The module creates facts as below:
# - vas_usersallow - A list of entries in /etc/opt/quest/vas/users.allow.
# - vas_domain - The domain that the host belongs to.
# - vas_server_type - The server types (GC, DC, PDC).
# - vas_servers - List of servers that VAS is using for authentication.
# - vas_site - The AD-site that the host belongs to.
# - vas_version - The complete version-string for the vas-client.
# - vasmajversion - The Major version of the vas-client.
#
# @summary Manages Dell Authentication Services previously known as VAS / QAS.
#
# @example Example hiera config
#   vas::username: 'joinuser'
#   vas::keytab_source: '/net/server/join.keytab'
#   vas::computers_ou: 'ou=computers,dc=example,dc=com'
#   vas::users_ou: 'ou=users,dc=example,dc=com'
#   vas::nismaps_ou: 'ou=nismaps,dc=example,dc=com'
#   vas::realm: 'realm.example.com'
#
#
# @param manage_nis
#   FIXME Missing description
#
# @param package_version
#   The VAS package version. Used when upgrading.
#
# @param enable_group_policies
#   Boolean to control if vas should manage group policies. Manages the vasgp
#   package. Version is controlled by package_version.
#
# @param users_allow_entries
#  List of users.allow entries. All users are allowed by default.
#
# @param users_deny_entries
#   List of users.deny entries. No users are denied by default.
#
# @param user_override_entries
#   List of user-override entries. Used to override specific user data fields;
#   UID, GID, GECOS, HOME_DIR and SHELL.
#
# @param group_override_entries
#   List of group-override entries. Used to override specific group data fields;
#   GROUP_NAME, GID and GROUP_MEMBERSHIP.
#
# @param username
#   Name of user account used to join Active Directory.
#
# @param keytab_path
#   The path to the keytab file used together with <username> to join Active Directory.
#
# @param keytab_source
#   File source for the keytab file used to join Active Directory.
#
# @param keytab_owner
#   keytab file owner.
#
# @param keytab_group
#   keytab file group.
#
# @param keytab_mode
#   keytab file mode.
#
# @param vas_fqdn
#   FQDN to join to VAS as.
#
# @param computers_ou
#   Path to OU where to store computer object.
#
# @param users_ou
#   Deprecated, this parameter is the same as upm_search_path. Path to OU where
#   to load UPM user profiles.
#
# @param nismaps_ou
#   Path to OU where to load nismaps initially.
#
# @param nismaps_ou
#   Path to OU where to load nismaps initially.
#
# @param user_search_path
#   LDAP search path for user profiles. This will limit the scope where QAS will
#   search for users when operating in RFC2307 mode.
#
# @param group_search_path
#   LDAP search path for groups. This will limit the scope where QAS will search
#   for groups when operating in RFC2307 mode.
#
# @param upm_search_path
#   LDAP search path for UPM user profiles. Setting this parameter will cause
#   QAS to run in UPM mode.
#
# @param nisdomainname
#   Name of the NIS domain.
#
# @param realm
#   Name of the realm.
#
# @param domain_change
#   FIXME Missing description
#
# @param sitenameoverride
#   Name of AD site to join. The AD site is determined automatically in AD by
#   default.
#
# @param vas_conf_client_addrs
#   client-addrs option in vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasypd_update_interval
#   Integer for number of seconds vasypd will wait between checks for updated
#   NIS Map information in Active Directory. See VAS.CONF(5).
#
# @param vas_conf_group_update_mode
#   The value of group-update-mode in the [nss_vas] configuration section.
#   This controls how directory searches will be handeled for group nss
#   functions. See VAS.CONF(5) for more info.
#   Possible values: force | force-if-missing | none
#
# @param vas_conf_root_update_mode
#   The value of root-update-mode in the [nss_vas] configuration section.
#   This controls how directory searches will be performed when calling nss
#   functions. See VAS.CONF(5) for more info.
#   Possible values: force | force-if-missing | none
#
# @param vas_conf_disabled_user_pwhash
#   String to be used for disabled-user-pwhash option in vas.conf. If undef,
#   line will be suppressed.
#
# @param vas_conf_expired_account_pwhash
#   String to be used for expired-account-pwhash option in vas.conf.
#   If undef, line will be suppressed.
#
# @param vas_conf_locked_out_pwhash
#   String to be used for locked-out-pwhash option in vas.conf.
#   If undef, line will be suppressed.
#
# @param vas_conf_preload_nested_memberships
#   preload-nested-membership option in vas.conf. Set this to 'false' to speed
#   up flush (and join) operations in VAS version 4.0.3-206 and later.
#
# @param vas_conf_update_process
#   update-process option in vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_upm_computerou_attr
#   upm-computerou-attr option in vas.conf. Changed to 'department' to work in
#   a multi-AD-domain setup. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_update_interval
#   Integer for number of seconds to set value of update-interval in [vasd]
#   section of vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_auto_ticket_renew_interval
#   Integer for number of seconds to set value of auto-ticket-renew-interval
#   in [vasd] section of vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_lazy_cache_update_interval
#   Integer for number of minutes for the value of lazy-cache-update-interval
#   in [vasd] section of vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_timesync_interval
#   Integer for number of seconds to set value of timesync-interval in
#   [vasd] section of vas.conf. See VAS.CONF(5) for more info.
#   If $::virtual is "zone" this value is set to 0
#
# @param vas_conf_vasd_cross_domain_user_groups_member_search
#   Boolean to set value of cross-domain-user-groups-member-search in
#   [vasd] section of vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_password_change_script
#   Path for script to set value of password-change-script in
#   [vasd] section of vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_password_change_script_timelimit
#   Integer for number of seconds to set value of
#   password-change-script-timelimit in [vasd] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_workstation_mode
#   Boolean to control whether or not vasd operates in Workstation mode.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_workstation_mode_users_preload
#   Comma separated list of groups for preloading users in Workstation mode.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_workstation_mode_group_do_member
#   Boolean to control if vasd should process group memberships in Workstation
#   mode. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_workstation_mode_groups_skip_update
#   Boolean that can be used to reduce the number of updates by vasd in
#   Workstation mode. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_ws_resolve_uid
#   Boolean to control whether vasd will resolve unknown UIDs when in
#   Workstation mode. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_deluser_check_timelimit
#   Integer for number of seconds to set value of deluser-check-timelimit in
#   [vasd] section of vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_delusercheck_interval
#   Integer for number of minutes to set value of delusercheck-interval in
#   [vasd] section of vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_delusercheck_script
#   Path for script to set value of delusercheck-script in [vasd] section of
#   vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_username_attr_name
#   String to be used for username-attr-name  in [vasd] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_groupname_attr_name
#   String to be used for groupname-attr-name  in [vasd] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_uid_number_attr_name
#   String to be used for uid-number-attr-name  in [vasd] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_gid_number_attr_name
#   String to be used for gid-number-attr-name  in [vasd] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_gecos_attr_name
#   String to be used for gecos-attr-name  in [vasd] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_home_dir_attr_name
#   String to be used for home-dir-attr-name  in [vasd] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_login_shell_attr_name
#   String to be used for login-shell-attr-name  in [vasd] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_group_member_attr_name
#   String to be used for group-member-attr-name  in [vasd] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_memberof_attr_name
#   String to be used for memberof-attr-name  in [vasd] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_unix_password_attr_name
#   String to be used for unix_password-attr-name  in [vasd] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vasd_netgroup_mode
#   String to be used to set value of netgroup-mode in the [vasd] section of
#   vas.conf. Valid values are 'NSS', 'NIS' and 'OFF'. If not specified, the
#   netgroup-mode parameter will not be set in vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_prompt_vas_ad_pw
#   prompt-vas-ad-pw option in vas.conf. Sets the password prompt for logins.
#
# @param vas_conf_pam_vas_prompt_ad_lockout_msg
#   prompt-ad-lockout-msg option in vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_libdefaults_forwardable
#   Boolean to set value of forwardable in [libdefaults] vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_libdefaults_tgs_default_enctypes
#   FIXME Missing description
#
# @param vas_conf_libdefaults_tkt_default_enctypes
#   FIXME Missing description
#
# @param vas_conf_libdefaults_default_etypes
#   String to set value of default_etypes in [libdefaults] vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_libdefaults_default_cc_name
#   String to set where kerberos cache files should be stored (default on most
#   systems is /tmp/krb5cc_${uid}).
#   Example: FILE:/new/path/krb5cc_${uid}
#
# @param vas_conf_vas_auth_uid_check_limit
#   Integer for uid-check-limit option in vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_vas_auth_allow_disconnected_auth
#   Boolean to set value of allow-disconnected-auth option in [vas_auth] section
#   of vas.conf. See VAS.CONF(5) for more info. If set to 'UNSET' nothing will
#   get printed.
#
# @param vas_conf_vas_auth_expand_ac_groups
#   Boolean to set value of expand-ac-groups option in [vas_auth] section of
#   vas.conf. See VAS.CONF(5) for more info. If set to 'UNSET' nothing will get
#   printed.
#
# @param vas_conf_libvas_vascache_ipc_timeout
#   Integer for number of seconds to set value of vascache-ipc-timeout in
#   [libvas] section of vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_libvas_use_server_referrals
#   Boolean to set valut of use-server-referrals in [libvas] section of vas.conf.
#   See VAS.CONF(5) for more info. Set to 'USE_DEFAULTS' for automagically
#   switching depending on running $vas_version.
#   Also see $vas_conf_libvas_use_server_referrals_version_switch.
#
# @param vas_conf_libvas_use_server_referrals_version_switch
#  String with version number to set use-server-referrals to false when
#  $vas_conf_libvas_use_server_referrals is set to 'USE_DEFAULTS'.
#  Equal or higher version numbers will pull the trigger.
#
# @param vas_conf_libvas_auth_helper_timeout
#   Integer for number of seconds to set value of auth-helper-timeout in
#   [libvas] section of vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_libvas_mscldap_timeout
#   Integer to control the timeout when performing a MSCLDAP ping against
#   AD Domain Controllers. See VAS.CONF(5) for more info.
#
# @param vas_conf_libvas_site_only_servers
#   Boolean to set valut of site-only-servers in [libvas] section of
#   vas.conf. See VAS.CONF(5) for more info.
#
# @param vas_conf_libvas_use_dns_srv
#   Boolean to set value of use-dns-srv in [libvas] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_libvas_use_tcp_only
#   Boolean to set value of use-tcp-only in [libvas] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_lowercase_names
#   Boolean to set value of lowercase-names in [nss_vas] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_conf_lowercase_homedirs
#   Boolean to set value of lowercase-homedirs in [nss_vas] section of vas.conf.
#   See VAS.CONF(5) for more info.
#
# @param vas_config_path
#   Path to VAS config file.
#
# @param vas_config_owner
#   vas.conf owner.
#
# @param vas_config_group
#   vas.conf group.
#
# @param vas_config_mode
#   vas.conf mode.
#
# @param vas_user_override_path
#   Path to user-override file.
#
# @param vas_user_override_owner
#   user-override file owner.
#
# @param vas_user_override_group
#   user-override file group.
#
# @param vas_user_override_mode
#   user-override file mode.
#
# @param vas_group_override_path
#   Path to user-override file.
#
# @param vas_group_override_owner
#   group-override file owner.
#
# @param vas_group_override_group
#   group-override file group.
#
# @param vas_group_override_mode
#   group-override file mode.
#
# @param vas_users_allow_path
#   Path to users.allow file.
#
# @param vas_users_allow_owner
#   users.allow file owner.
#
# @param vas_users_allow_group
#   users.allow file group.
#
# @param vas_users_allow_mode
#   users.allow file mode.
#
# @param vas_users_deny_path
#   Path to users.deny file.
#
# @param vas_users_deny_owner
#   users.deny file owner.
#
# @param vas_users_deny_group
#   users.deny file group.
#
# @param vas_users_deny_mode
#   users.deny file mode.
#
# @param vasjoin_logfile
#   Path to logfile used by AD join commando.
#
# @param vastool_binary
#   Path to vastool binary to create symlink from.
#
# @param symlink_vastool_binary_target
#   Path to where the symlink should be created.
#
# @param symlink_vastool_binary
#   Boolean for ensuring a symlink for vastool_binary to
#   symlink_vastool_binary_target. This is useful since /opt/quest/bin is a
#   non-standard location that is not in your $PATH.
#
# @param license_files
#   Hash of license files.
#
# @param domain_realms
#   Hash of domains that should be mapped to correct realm.
#
# @param join_domain_controllers
#   A string or an array with domain controllers to contact during the join
#   process. Normally the servers for the domain will be automatically detected
#   through DNS and LDAP lookups. By specifying this parameter vastool will
#   contact the specified servers and only those servers during the join process.
#   This can be useful if the machine being joined is not able to talk with all
#   global Domain Controllers (e.g. due to firewalls). Note that this will have
#   no effect after the join, where normal site discovery of servers will be
#   made.
#
# @param unjoin_vas
#   Boolean to trigger an unjoining of the domain. Obviously this will only
#   work if the system is joined to a domain.
#
# @param use_srv_infocache
#   A bool to achieve the same thing as issuing "vastool configure vas libvas
#   use-srv-info-cache <bool>" Only has any effect if set to false.
#
# @param kdcs
#   An array of kdcs that are to be entered under the [realms] section. If set
#   has the same effect as issuing
#   "vastool configure realm domain.tld srv1.domain.tld srv2.domain.tld". (eg)
#
# @param kdc_port
#   An integer containing the kdc port. Has no effect unless kdcs is populated
#   with servernames.
#
# @param kpasswd_servers
#   An array of kpasswd servers that are to be entered under the [realms] section
#   Normally needs not be set unless you want something different than the value
#   of kdcs (above).
#
# @param kpasswd_server_port
#   An integer containing the kpasswd server port. Has no effect unless
#   kpasswd_servers or kdcs is populated with servernames.
#
# @param api_enable
#   A boolean to control, whether the API function is called. If called, the API
#   will return a list of entries for the users.allow file. This result will be
#   merged with whatever content is provided otherwise provided; i.e. it will be
#   concatenated with the content created by parameters users_allow_entries.
#
# @param api_users_allow_url
#   The URL towards the API.
#
# @param api_token
#   Security token for authenticated access to the API.
#
class vas (
  Boolean $manage_nis                                                     = true,
  String[1] $package_version                                              = 'installed',
  Boolean $enable_group_policies                                          = true,
  Array[String[1]] $users_allow_entries                                   = [],
  Array[String[1]] $users_deny_entries                                    = [],
  Array[String[1]] $user_override_entries                                 = [],
  Array[String[1]] $group_override_entries                                = [],
  String[1] $username                                                     = 'username',
  Stdlib::Absolutepath $keytab_path                                       = '/etc/vasinst.key',
  Optional[String[1]] $keytab_source                                      = undef,
  String[1] $keytab_owner                                                 = 'root',
  String[1] $keytab_group                                                 = 'root',
  Stdlib::Filemode $keytab_mode                                           = '0400',
  Stdlib::Fqdn $vas_fqdn                                                  = $::fqdn,
  Optional[String[1]] $computers_ou                                       = undef,
  Optional[String[1]] $users_ou                                           = undef,
  String[1] $nismaps_ou                                                   = 'ou=nismaps,dc=example,dc=com',
  Optional[String[1]] $user_search_path                                   = undef,
  Optional[String[1]] $group_search_path                                  = undef,
  Optional[String[1]] $upm_search_path                                    = undef,
  Optional[String[1]] $nisdomainname                                      = undef,
  Stdlib::Host $realm                                                     = 'realm.example.com',
  Boolean $domain_change                                                  = false,
  Optional[String[1]] $sitenameoverride                                   = undef,
  Optional[String[1,1024]] $vas_conf_client_addrs                         = undef, # vasypd has a limit of 1024 and will fail hard otherwise !
  Integer[0] $vas_conf_vasypd_update_interval                             = 1800,
  Optional[Integer] $vas_conf_full_update_interval                        = undef,
  String[1] $vas_conf_group_update_mode                                   = 'none',
  String[1] $vas_conf_root_update_mode                                    = 'none',
  Optional[String[1]] $vas_conf_disabled_user_pwhash                      = undef,
  Optional[String[1]] $vas_conf_expired_account_pwhash                    = undef,
  Optional[String[1]] $vas_conf_locked_out_pwhash                         = undef,
  Optional[Boolean] $vas_conf_preload_nested_memberships                  = undef,
  Stdlib::Absolutepath $vas_conf_update_process                           = '/opt/quest/libexec/vas/mapupdate_2307',
  Optional[String[1]] $vas_conf_upm_computerou_attr                       = undef,
  Integer[0] $vas_conf_vasd_update_interval                               = 600,
  Integer[0] $vas_conf_vasd_auto_ticket_renew_interval                    = 32400,
  Integer[0] $vas_conf_vasd_lazy_cache_update_interval                    = 10,
  Optional[Integer] $vas_conf_vasd_timesync_interval                      = undef,
  Optional[Boolean] $vas_conf_vasd_cross_domain_user_groups_member_search = undef,
  Optional[Stdlib::Absolutepath] $vas_conf_vasd_password_change_script    = undef,
  Optional[Integer] $vas_conf_vasd_password_change_script_timelimit       = undef,
  Boolean $vas_conf_vasd_workstation_mode                                 = false,
  Optional[String[1]] $vas_conf_vasd_workstation_mode_users_preload       = undef,
  Boolean $vas_conf_vasd_workstation_mode_group_do_member                 = false,
  Boolean $vas_conf_vasd_workstation_mode_groups_skip_update              = false,
  Boolean $vas_conf_vasd_ws_resolve_uid                                   = false,
  Optional[Integer] $vas_conf_vasd_deluser_check_timelimit                = undef,
  Optional[Integer] $vas_conf_vasd_delusercheck_interval                  = undef,
  Optional[Stdlib::Absolutepath] $vas_conf_vasd_delusercheck_script       = undef,
  Optional[String[1]] $vas_conf_vasd_username_attr_name                   = undef,
  Optional[String[1]] $vas_conf_vasd_groupname_attr_name                  = undef,
  Optional[String[1]] $vas_conf_vasd_uid_number_attr_name                 = undef,
  Optional[String[1]] $vas_conf_vasd_gid_number_attr_name                 = undef,
  Optional[String[1]] $vas_conf_vasd_gecos_attr_name                      = undef,
  Optional[String[1]] $vas_conf_vasd_home_dir_attr_name                   = undef,
  Optional[String[1]] $vas_conf_vasd_login_shell_attr_name                = undef,
  Optional[String[1]] $vas_conf_vasd_group_member_attr_name               = undef,
  Optional[String[1]] $vas_conf_vasd_memberof_attr_name                   = undef,
  Optional[String[1]] $vas_conf_vasd_unix_password_attr_name              = undef,
  Optional[Enum['NSS', 'NIS', 'OFF']] $vas_conf_vasd_netgroup_mode        = undef,
  String[1] $vas_conf_prompt_vas_ad_pw                                    = '"Enter Windows password: "',
  Optional[String[1]] $vas_conf_pam_vas_prompt_ad_lockout_msg             = undef,
  Boolean $vas_conf_libdefaults_forwardable                               = true,
  String[1] $vas_conf_libdefaults_tgs_default_enctypes                    = 'arcfour-hmac-md5',
  String[1] $vas_conf_libdefaults_tkt_default_enctypes                    = 'arcfour-hmac-md5',
  String[1] $vas_conf_libdefaults_default_etypes                          = 'arcfour-hmac-md5',
  Optional[String[1]] $vas_conf_libdefaults_default_cc_name               = undef,
  Optional[Integer] $vas_conf_vas_auth_uid_check_limit                    = undef,
  Optional[Boolean] $vas_conf_vas_auth_allow_disconnected_auth            = undef,
  Optional[Boolean] $vas_conf_vas_auth_expand_ac_groups                   = undef,
  Integer[0] $vas_conf_libvas_vascache_ipc_timeout                        = 15,
  Variant[Boolean, Enum['']] $vas_conf_libvas_use_server_referrals        = true,
  String[1] $vas_conf_libvas_use_server_referrals_version_switch          = '4.1.0.21518',
  Integer[0] $vas_conf_libvas_auth_helper_timeout                         = 10,
  Integer[0] $vas_conf_libvas_mscldap_timeout                             = 1,
  Boolean $vas_conf_libvas_site_only_servers                              = false,
  Boolean $vas_conf_libvas_use_dns_srv                                    = true,
  Boolean $vas_conf_libvas_use_tcp_only                                   = true,
  Optional[Boolean] $vas_conf_lowercase_names                             = undef,
  Optional[Boolean] $vas_conf_lowercase_homedirs                          = undef,
  Stdlib::Absolutepath $vas_config_path                                   = '/etc/opt/quest/vas/vas.conf',
  String[1] $vas_config_owner                                             = 'root',
  String[1] $vas_config_group                                             = 'root',
  Stdlib::Filemode $vas_config_mode                                       = '0644',
  Optional[Stdlib::Absolutepath] $vas_user_override_path                  = undef,
  String[1] $vas_user_override_owner                                      = 'root',
  String[1] $vas_user_override_group                                      = 'root',
  Stdlib::Filemode $vas_user_override_mode                                = '0644',
  Optional[Stdlib::Absolutepath] $vas_group_override_path                 = undef,
  String[1] $vas_group_override_owner                                     = 'root',
  String[1] $vas_group_override_group                                     = 'root',
  Stdlib::Filemode $vas_group_override_mode                               = '0644',
  Optional[Stdlib::Absolutepath] $vas_users_allow_path                    = undef,
  String[1] $vas_users_allow_owner                                        = 'root',
  String[1] $vas_users_allow_group                                        = 'root',
  Stdlib::Filemode $vas_users_allow_mode                                  = '0644',
  Optional[Stdlib::Absolutepath] $vas_users_deny_path                     = undef,
  String[1] $vas_users_deny_owner                                         = 'root',
  String[1] $vas_users_deny_group                                         = 'root',
  Stdlib::Filemode $vas_users_deny_mode                                   = '0644',
  Stdlib::Absolutepath $vasjoin_logfile                                   = '/var/tmp/vasjoin.log',
  Stdlib::Absolutepath $vastool_binary                                    = '/opt/quest/bin/vastool',
  Stdlib::Absolutepath $symlink_vastool_binary_target                     = '/usr/bin/vastool',
  Boolean $symlink_vastool_binary                                         = false,
  Hash $license_files                                                     = {},
  Hash $domain_realms                                                     = {},
  Array[String[1]] $join_domain_controllers                               = [],
  Boolean $unjoin_vas                                                     = false,
  Optional[Boolean] $use_srv_infocache                                    = undef,
  Array[String[1]] $kdcs                                                  = [],
  Stdlib::Port $kdc_port                                                  = 88,
  Array[String[1]] $kpasswd_servers                                       = [],
  Stdlib::Port $kpasswd_server_port                                       = 464,
  Boolean $api_enable                                                     = false,
  Optional[Stdlib::HTTPSUrl] $api_users_allow_url                         = undef,
  Optional[String[1]] $api_token                                          = undef,
) {

  $domain_realms_real = merge({"${vas_fqdn}" => $realm}, $domain_realms)

  if versioncmp("${::vas_version}", $vas_conf_libvas_use_server_referrals_version_switch) >= 0 { # lint:ignore:only_variable_string
    $vas_conf_libvas_use_server_referrals_default = false
  } else {
    $vas_conf_libvas_use_server_referrals_default = true
  }

  $vas_conf_libvas_use_server_referrals_real = pick($vas_conf_libvas_use_server_referrals, $vas_conf_libvas_use_server_referrals_default)

  $license_files_defaults = {
    'ensure' => 'file',
    'path' => '/etc/opt/quest/vas/.licenses/VAS_license',
    'require' => Package['vasclnt'],
  }

  create_resources(file, $license_files, $license_files_defaults)

  $kdcs_real = join(suffix($kdcs, ":${kdc_port}"), ' ')

  if empty($kpasswd_servers) {
    $kpasswd_servers_real = join(suffix($kdcs, ":${kpasswd_server_port}"), ' ')
  } else {
    $kpasswd_servers_real = join(suffix($kpasswd_servers, ":${kpasswd_server_port}"), ' ')
  }

  $join_domain_controllers_real = join($join_domain_controllers, ' ')

  # Define search paths
  if $upm_search_path == undef {
    if $users_ou {
      $upm_search_path_real = $users_ou
    } else {
      $upm_search_path_real = undef
    }
  } else {
    $upm_search_path_real = $upm_search_path
  }

  include ::vas::linux

  if $enable_group_policies == true {
    $gp_package_ensure = $package_version
  } else {
    $gp_package_ensure = 'absent'
  }

  package { 'vasclnt':
    ensure => $package_version,
  }

  if $manage_nis {
    include ::nisclient

    $package_require = [
      Package['vasclnt'],
      Package['vasyp'],
      Package['vasgp'],
    ]

    $service_require = [
      Service['vasd'],
      Service['vasypd'],
    ]

    package { 'vasyp':
      ensure => $package_version,
    }
  } else {
    $package_require = [
      Package['vasclnt'],
      Package['vasgp'],
    ]

    $service_require = [
      Service['vasd'],
    ]
  }

  package { 'vasgp':
    ensure => $gp_package_ensure,
  }

  include ::nsswitch
  include ::pam

  # Use nisdomainname is supplied. If not, use nisclient::domainname if it
  # exists, last resort fall back to domain fact
  if $manage_nis and $nisdomainname == undef {
    if $nisclient::domainname != undef {
      $my_nisdomainname = $nisclient::domainname
    } else {
      $my_nisdomainname = $::domain
    }
  } else {
    $my_nisdomainname = $nisdomainname
  }

  if $api_enable == true {
    if $api_users_allow_url == undef or $api_token == undef {
      fail('vas::api_enable is set to true but required parameters vas::api_users_allow_url and/or vas::api_token missing')
    }

    $api_users_allow_data  = api_fetch($api_users_allow_url, $api_token)
    # Return value is integer in Puppet 3 and string in Puppet 6
    if $api_users_allow_data[0] == 200 or $api_users_allow_data[0] == '200' {
      $manage_users_allow = true
      $users_allow_entries_real = concat($users_allow_entries, $api_users_allow_data[1])
    } else {
      # VAS API is configured but down. Don't manage users_allow to prevent removal of entries.
      $manage_users_allow = false
      warning("VAS API Error. Code: ${api_users_allow_data[0]}, Error: ${api_users_allow_data[1]}")
    }
  } else {
    $manage_users_allow = true
    $users_allow_entries_real = $users_allow_entries
  }

  $once_file = '/etc/opt/quest/vas/puppet_joined'

  if $unjoin_vas == true and $::vas_domain != undef {
    exec { 'vas_unjoin':
      command  => "$(sed 's/\\(.*\\)join.*/\\1unjoin/' /etc/opt/quest/vas/lastjoin) > /tmp/vas_unjoin.txt 2>&1 && rm -f ${once_file}",
      onlyif   => "/usr/bin/test -f ${keytab_path} && /usr/bin/test -f /etc/opt/quest/vas/lastjoin",
      provider => 'shell',
      path     => '/bin:/usr/bin:/opt/quest/bin',
      timeout  => 1800,
      require  => $package_require,
    }
  } elsif $unjoin_vas == false {
    # no run if undef!
    # We should probably have better sanity checks for $realm parameter instead of this.
    if $realm != undef {
      # So we use the fact vas_domain to identify if vas is already joined to a AD
      # server. It will make sure and check that ::vas_domain is not undef before doing this
      # to prevent something from happening at first run.
      # If the vas_domain fact is not the same as the realm specified in hiera it
      # will then check if the domain_change parameter is set to true. If it is
      # it will join the domain with help of the lastjoin file.
      # If the domain_change fact is false, it will fail the compilation and warn
      # of the mismatching realm.
      if $::vas_domain != $realm and $::vas_domain != undef {
        if $domain_change == true {
          exec { 'vas_change_domain':
            # This command executes the result of the sed command, puts the log from
            # the unjoin command into a log file and removes the once file to allow
            # the  vas_inst command to join the new AD server.
            # This is how the join command is built up by the vas module.
            # ${vastool_binary} -u ${username} -k ${keytab_path} -d3 join -f ${workstation_flag} \
            # -c ${computers_ou} ${user_search_path_parm} ${group_search_path_parm} ${upm_search_path_parm} -n ${vas_fqdn}
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
            require  => $package_require,
          }
        } else {
          fail("VAS domain mismatch, got <${::vas_domain}> but wanted <${realm}>")
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
      require => $package_require,
    }

    $_vas_users_allow_path = $vas_users_allow_path ? {
      undef   => '/etc/opt/quest/vas/users.allow',
      default => $vas_users_allow_path,
    }

    if $manage_users_allow {
      file { 'vas_users_allow':
        ensure  => file,
        path    => $_vas_users_allow_path,
        owner   => $vas_users_allow_owner,
        group   => $vas_users_allow_group,
        mode    => $vas_users_allow_mode,
        content => template('vas/users.allow.erb'),
        require => $package_require,
      }
    }

    $_vas_users_deny_path = $vas_users_deny_path ? {
      undef   => '/etc/opt/quest/vas/users.deny',
      default => $vas_users_deny_path,
    }
    file { 'vas_users_deny':
      ensure  => file,
      path    => $_vas_users_deny_path,
      owner   => $vas_users_deny_owner,
      group   => $vas_users_deny_group,
      mode    => $vas_users_deny_mode,
      content => template('vas/users.deny.erb'),
      require => $package_require,
    }

    $_vas_user_override_path = $vas_user_override_path ? {
      undef   => '/etc/opt/quest/vas/user-override',
      default => $vas_user_override_path,
    }
    file { 'vas_user_override':
      ensure  => file,
      path    => $_vas_user_override_path,
      owner   => $vas_user_override_owner,
      group   => $vas_user_override_group,
      mode    => $vas_user_override_mode,
      content => template('vas/user-override.erb'),
      require => $package_require,
      before  => $service_require,
    }

    $_vas_group_override_path = $vas_group_override_path ? {
      undef   => '/etc/opt/quest/vas/group-override',
      default => $vas_group_override_path,
    }
    file { 'vas_group_override':
      ensure  => file,
      path    => $_vas_group_override_path,
      owner   => $vas_group_override_owner,
      group   => $vas_group_override_group,
      mode    => $vas_group_override_mode,
      content => template('vas/group-override.erb'),
      require => $package_require,
      before  => $service_require,
    }

    file { 'keytab':
      ensure => 'file',
      path   => $keytab_path,
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

    if $manage_nis {
      exec { 'Process check Vasypd' :
        path    => '/usr/bin:/bin',
        command => 'rm -f /var/opt/quest/vas/vasypd/.vasypd.pid',
        unless  => 'ps -p `cat /var/opt/quest/vas/vasypd/.vasypd.pid` | grep .vasypd',
        before  => Service['vasypd'],
        notify  => Service['vasypd'],
      }

      service { 'vasypd':
        ensure  => 'running',
        enable  => true,
        require => Service['vasd'],
        before  => Class['nisclient'],
      }
    }

    if $sitenameoverride == undef {
      $s_opts = '' # lint:ignore:empty_string_assignment
    } else {
      $s_opts = "-s ${sitenameoverride}"
    }

    if $vas_conf_vasd_workstation_mode == true {
      $workstation_flag = '-w'
    } else {
      $workstation_flag = '' # lint:ignore:empty_string_assignment
    }

    if $user_search_path != undef {
      $user_search_path_parm = "-u ${user_search_path}"
    } else {
      $user_search_path_parm = '' # lint:ignore:empty_string_assignment
    }
    if $group_search_path != undef {
      $group_search_path_parm = "-g ${group_search_path}"
    } else {
      $group_search_path_parm = '' # lint:ignore:empty_string_assignment
    }
    if $upm_search_path_real != undef {
      $upm_search_path_parm = "-p ${upm_search_path_real}"
    } else {
      $upm_search_path_parm = '' # lint:ignore:empty_string_assignment
    }

    exec { 'vasinst':
      command => "${vastool_binary} -u ${username} -k ${keytab_path} -d3 join -f ${workstation_flag} -c ${computers_ou} ${user_search_path_parm} ${group_search_path_parm} ${upm_search_path_parm} -n ${vas_fqdn} ${s_opts} ${realm} ${join_domain_controllers_real} > ${vasjoin_logfile} 2>&1 && touch ${once_file}", # lint:ignore:140chars
      path    => '/sbin:/bin:/usr/bin:/opt/quest/bin',
      timeout => 1800,
      creates => $once_file,
      before  => Class['pam'],
      require => [
        $package_require,
        File['keytab']
      ],
    }

    # optionally create symlinks to vastool binary
    if $symlink_vastool_binary == true {
      file { 'vastool_symlink':
        ensure => link,
        path   => $symlink_vastool_binary_target,
        target => $vastool_binary,
      }
    }
  }
}
