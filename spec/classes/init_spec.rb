require 'spec_helper'

describe 'vas' do
  default_facts = {
    :kernel                    => 'Linux',
    :osfamily                  => 'RedHat',
    :lsbmajdistrelease         => '6',
    :operatingsystemmajrelease => '6',
    :vas_domain                => 'realm.example.com',
    :vas_version               => '4.1.0.21518',
    :virtual                   => 'physical',
    :fqdn                      => 'host.example.com',
    :domain                    => 'example.com',
  }
  let(:facts) { default_facts }

  describe 'packages' do
    context 'defaults on osfamily RedHat with lsbmajdistrelease 6' do
      it { should contain_package('vasclnt').with({ 'ensure' => 'installed' }) }
      it { should contain_package('vasyp').with({ 'ensure' => 'installed' }) }
      it { should contain_package('vasgp').with({ 'ensure' => 'installed' }) }
    end

    context 'defaults on osfamily Suse with lsbmajdistrelease 11' do
      let :facts do
        default_facts.merge(
          {
            :osfamily          => 'Suse',
            :lsbmajdistrelease => '11'
          }
        )
      end

      it { should contain_package('vasclnt').with({ 'ensure' => 'installed' }) }
      it { should contain_package('vasyp').with({ 'ensure' => 'installed' }) }
      it { should contain_package('vasgp').with({ 'ensure' => 'installed' }) }
    end

    context 'defaults on osfamily Solaris with kernelrelease 5.10' do
      let :facts do
        default_facts.merge(
          {
            :kernel        => 'SunOS',
            :osfamily      => 'Solaris',
            :kernelrelease => '5.10'
          }
        )
      end

      it { should contain_package('vasclnt').with({ 'ensure' => 'installed' }) }
      it { should contain_package('vasyp').with({ 'ensure' => 'installed' }) }
      it { should contain_package('vasgp').with({ 'ensure' => 'installed' }) }
    end

    context 'with package_version specified on osfamily RedHat with lsbmajdistrelease 6' do
      let :params do
        {
          :package_version => '4.0.3-206',
        }
      end

      it { should contain_package('vasclnt').with({ 'ensure' => '4.0.3-206' }) }
      it { should contain_package('vasyp').with({ 'ensure' => '4.0.3-206' }) }
      it { should contain_package('vasgp').with({ 'ensure' => '4.0.3-206' }) }
    end

    context 'with enable_group_policies set to false' do
      let :params do
        {
          :enable_group_policies => 'false',
        }
      end

      it { should contain_package('vasgp').with({ 'ensure' => 'absent' }) }
    end
  end

  describe 'config' do
    context 'defaults on osfamily redhat with lsbmajdistrelease 6' do
      content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |[domain_realm]
        | host.example.com = REALM.EXAMPLE.COM
        |
        |[libdefaults]
        | default_realm = REALM.EXAMPLE.COM
        | default_tgs_enctypes = arcfour-hmac-md5
        | default_tkt_enctypes = arcfour-hmac-md5
        | default_etypes = arcfour-hmac-md5
        | forwardable = true
        | renew_lifetime = 604800
        |
        | ticket_lifetime = 36000
        | default_keytab_name = /etc/opt/quest/vas/host.keytab
        |
        |[libvas]
        | vascache-ipc-timeout = 15
        | use-server-referrals = true
        | mscldap-timeout = 1
        | use-dns-srv = true
        | use-tcp-only = true
        | auth-helper-timeout = 10
        | site-only-servers = false
        |
        |[pam_vas]
        | prompt-vas-ad-pw = "Enter Windows password: "
        |
        |[vasypd]
        | search-base = ou=nismaps,dc=example,dc=com
        | split-groups = true
        | update-interval = 1800
        | domainname-override = example.com
        | update-process = /opt/quest/libexec/vas/mapupdate_2307
        |
        |[vasd]
        | update-interval = 600
        | workstation-mode = false
        | auto-ticket-renew-interval = 32400
        | lazy-cache-update-interval = 10
        | upm-computerou-attr = department
        |
        |[nss_vas]
        | group-update-mode = none
        | root-update-mode = none
        |
        |[vas_auth]
      END

      it do
        should contain_file('vas_config').with({
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/vas.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => content,
        })
      end
      it do
        should contain_file('vas_user_override').with({
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/user-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n"

        })
      end
      it do
        should contain_file('vas_group_override').with({
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/group-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n"
        })
      end
      it do
        should contain_file('vas_users_allow').with({
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/users.allow',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n"
        })
      end
      it do
        should contain_file('vas_users_deny').with({
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/users.deny',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n"
        })
      end
    end

    context 'with parameters for vas.conf specified on osfamily redhat with lsbmajdistrelease 6' do
      let :facts do
        default_facts.merge(
          {
            :vas_domain => 'realm2.example.com',
          }
        )
      end
      let :params do
        {
          :vas_fqdn                                             => 'host2.example.com',
          :computers_ou                                         => 'ou=site,ou=computers,dc=example,dc=com',
          :nismaps_ou                                           => 'ou=site,ou=nismaps,dc=example,dc=com',
          :users_ou                                             => 'ou=site,ou=users,dc=example,dc=com',
          :realm                                                => 'realm2.example.com',
          :domain_realms                                        => { 'fqdn.example.se' => 'example.se' },
          :nisdomainname                                        => 'nis.domain',
          :vas_conf_prompt_vas_ad_pw                            => 'Enter pw',
          :vas_conf_pam_vas_prompt_ad_lockout_msg               => 'Account is locked',
          :vas_conf_libdefaults_forwardable                     => 'false',
          :vas_conf_libdefaults_tgs_default_enctypes            => 'arcfour-hmac-md5',
          :vas_conf_libdefaults_tkt_default_enctypes            => 'arcfour-hmac-md5',
          :vas_conf_libdefaults_default_etypes                  => 'arcfour-hmac-md5',
          :vas_conf_libdefaults_default_cc_name                 => 'FILE:/dev/null/krb5cc_${uid}',
          :vas_conf_client_addrs                                => '10.10.0.0/24 10.50.0.0/24',
          :vas_conf_disabled_user_pwhash                        => 'disabled',
          :vas_conf_expired_account_pwhash                      => 'expired',
          :vas_conf_locked_out_pwhash                           => 'locked',
          :vas_conf_update_process                              => '/opt/quest/libexec/vas/mapupdate',
          :vas_conf_vasypd_update_interval                      => '2200',
          :vas_conf_full_update_interval                        => '3600',
          :vas_conf_vasd_update_interval                        => '1200',
          :vas_conf_upm_computerou_attr                         => 'managedBy',
          :vas_conf_preload_nested_memberships                  => 'false',
          :vas_conf_vasd_cross_domain_user_groups_member_search => 'true',
          :vas_conf_vasd_timesync_interval                      => '0',
          :vas_conf_vasd_auto_ticket_renew_interval             => '540',
          :vas_conf_vasd_password_change_script                 => '/opt/quest/libexec/vas-set-samba-password',
          :vas_conf_vasd_workstation_mode                       => 'true',
          :vas_conf_vasd_workstation_mode_users_preload         => 'usergroup',
          :vas_conf_vasd_workstation_mode_group_do_member       => 'true',
          :vas_conf_vasd_workstation_mode_groups_skip_update    => 'true',
          :vas_conf_vasd_username_attr_name                     => 'userprincipalname',
          :vas_conf_vasd_groupname_attr_name                    => 'groupprincipalname',
          :vas_conf_vasd_uid_number_attr_name                   => 'employeID',
          :vas_conf_vasd_gid_number_attr_name                   => 'primaryGroupID',
          :vas_conf_vasd_gecos_attr_name                        => 'displayName',
          :vas_conf_vasd_home_dir_attr_name                     => 'homeDirectory',
          :vas_conf_vasd_login_shell_attr_name                  => 'loginShell',
          :vas_conf_vasd_group_member_attr_name                 => 'groupMembershipSAM',
          :vas_conf_vasd_memberof_attr_name                     => 'memberOf',
          :vas_conf_vasd_unix_password_attr_name                => 'userPassword',
          :vas_conf_vasd_netgroup_mode                          => 'NIS',
          :vas_conf_vasd_ws_resolve_uid                         => 'true',
          :vas_conf_vasd_lazy_cache_update_interval             => '5',
          :vas_conf_vasd_password_change_script_timelimit       => '30',
          :vas_conf_libvas_auth_helper_timeout                  => '120',
          :vas_conf_vas_auth_allow_disconnected_auth            => false,
          :vas_conf_vas_auth_expand_ac_groups                   => false,
          :sitenameoverride                                     => 'foobar',
          :vas_conf_libvas_use_dns_srv                          => 'false',
          :vas_conf_libvas_use_tcp_only                         => 'false',
          :vas_conf_libvas_mscldap_timeout                      => '10',
          :vas_conf_libvas_site_only_servers                    => 'false',
          :vas_conf_vas_auth_uid_check_limit                    => '100000',
          :vas_conf_lowercase_names                             => true,
          :vas_conf_lowercase_homedirs                          => true,
        }
      end

      content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |[domain_realm]
        | fqdn.example.se = EXAMPLE.SE
        | host2.example.com = REALM2.EXAMPLE.COM
        |
        |[libdefaults]
        | default_realm = REALM2.EXAMPLE.COM
        | default_tgs_enctypes = arcfour-hmac-md5
        | default_tkt_enctypes = arcfour-hmac-md5
        | default_etypes = arcfour-hmac-md5
        | forwardable = false
        | renew_lifetime = 604800
        |
        | ticket_lifetime = 36000
        | default_keytab_name = /etc/opt/quest/vas/host.keytab
        | default_cc_name = FILE:/dev/null/krb5cc_${uid}
        |
        |[libvas]
        | vascache-ipc-timeout = 15
        | use-server-referrals = true
        | site-name-override = foobar
        | mscldap-timeout = 10
        | use-dns-srv = false
        | use-tcp-only = false
        | auth-helper-timeout = 120
        | site-only-servers = false
        |
        |[pam_vas]
        | prompt-vas-ad-pw = Enter pw
        | prompt-ad-lockout-msg = "Account is locked"
        |
        |[vasypd]
        | search-base = ou=site,ou=nismaps,dc=example,dc=com
        | split-groups = true
        | update-interval = 2200
        | domainname-override = nis.domain
        | update-process = /opt/quest/libexec/vas/mapupdate
        | full-update-interval = 3600
        | client-addrs = 10.10.0.0/24 10.50.0.0/24
        |
        |[vasd]
        | update-interval = 1200
        | upm-search-path = ou=site,ou=users,dc=example,dc=com
        | workstation-mode = true
        | workstation-mode-users-preload = usergroup
        | workstation-mode-group-do-member = true
        | workstation-mode-groups-skip-update = true
        | ws-resolve-uid = true
        | auto-ticket-renew-interval = 540
        | lazy-cache-update-interval = 5
        | cross-domain-user-groups-member-search = true
        | timesync-interval = 0
        | preload-nested-memberships = false
        | upm-computerou-attr = managedBy
        | password-change-script = /opt/quest/libexec/vas-set-samba-password
        | password-change-script-timelimit = 30
        | netgroup-mode = NIS
        | username-attr-name = userprincipalname
        | groupname-attr-name = groupprincipalname
        | uid-number-attr-name = employeID
        | gid-number-attr-name = primaryGroupID
        | gecos-attr-name = displayName
        | home-dir-attr-name = homeDirectory
        | login-shell-attr-name = loginShell
        | group-member-attr-name = groupMembershipSAM
        | memberof-attr-name = memberOf
        | unix-password-attr-name = userPassword
        |
        |[nss_vas]
        | group-update-mode = none
        | root-update-mode = none
        | disabled-user-pwhash = disabled
        | expired-account-pwhash = expired
        | locked-out-pwhash = locked
        | lowercase-names = true
        | lowercase-homedirs = true
        |
        |[vas_auth]
        | uid-check-limit = 100000
        | allow-disconnected-auth = false
        | expand-ac-groups = false
      END

      it do
        should contain_file('vas_config').with({
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/vas.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => content,
        })
      end
    end

    context 'with vas_conf_vasypd_update_interval set' do
      let :params do
        { :vas_conf_vasypd_update_interval => '234577' }
      end

      it do
        should contain_file('vas_config').with_content(/update-interval = 234577/)
      end
    end

    context 'with vas_conf_vasd_netgroup_mode set to valid string NSS' do
      let(:params) { { :vas_conf_vasd_netgroup_mode => 'NSS', } }
      it { should contain_file('vas_config').with_content(/^[ ]*netgroup-mode = NSS$/) }
    end

    context 'with vas_conf_vasd_netgroup_mode set to valid string UNSET' do
      let(:params) { { :vas_conf_vasd_netgroup_mode => 'UNSET', } }
      it { should contain_file('vas_config').without_content(/^[ ]*netgroup-mode/) }
    end

    context 'with use_server_referrals enabled by vas version' do
      let :params do
        { :vas_conf_libvas_use_server_referrals => 'USE_DEFAULTS' }
      end

      it do
        should contain_file('vas_config').with_content(/use-server-referrals = false/)
      end
    end

    context 'with use_server_referrals disabled by vas version' do
      let :facts do
        default_facts.merge(
          {
            :vas_version => '4.1.0.21517',
          }
        )
      end
      let :params do
        { :vas_conf_libvas_use_server_referrals => 'USE_DEFAULTS' }
      end

      it do
        should contain_file('vas_config').with_content(/use-server-referrals = true/)
      end
    end

    context 'with use_server_referrals set to invalid value' do
      let :params do
        { :vas_conf_libvas_use_server_referrals => 42 }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /is not a boolean/)
      end
    end

    context 'with vas_fqdn to invalid domainname' do
      let :params do
        { :vas_fqdn => 'bad!@#hostname' }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /vas::vas_fqdn is not a valid FQDN. Detected value is <bad!@#hostname>./)
      end
    end

    context 'with enable_group_policies to invalid type (not bool or string)' do
      let :params do
        { :enable_group_policies => '600invalid' }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /Unknown type of boolean given/)
      end
    end

    context 'with vas_conf_vasd_auto_ticket_renew_interval to invalid string (non-integer)' do
      let :params do
        { :vas_conf_vasd_auto_ticket_renew_interval => '600invalid' }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /validate_integer/)
      end
    end

    context 'with vas_conf_vasd_update_interval set to invalid string (non-integer)' do
      let :params do
        { :vas_conf_vasd_update_interval => '600invalid' }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /validate_integer/)
      end
    end

    context 'with vas_conf_prompt_vas_ad_pw set to invalid type (non-string)' do
      let :params do
        { :vas_conf_prompt_vas_ad_pw => ['array'] }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /is not a string/)
      end
    end

    context 'with vas_conf_disabled_user_pwhash set to invalid type (non-string)' do
      let :params do
        { :vas_conf_disabled_user_pwhash => ['array'] }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /is not a string/)
      end
    end

    context 'with vas_conf_expired_account_pwhash set to invalid type (non-string)' do
      let :params do
        { :vas_conf_expired_account_pwhash => ['array'] }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /is not a string/)
      end
    end

    context 'with vas_conf_locked_out_pwhash set to invalid type (non-string)' do
      let :params do
        { :vas_conf_locked_out_pwhash => ['array'] }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /is not a string/)
      end
    end

    context 'with vas_conf_libvas_use_dns_srv set to invalid non-boolean string' do
      let :params do
        { :vas_conf_libvas_use_dns_srv => 'invalid' }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error)
      end
    end

    context 'with vas_conf_libvas_use_tcp_only set to invalid non-boolean string' do
      let :params do
        { :vas_conf_libvas_use_tcp_only => 'invalid' }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error)
      end
    end

    context 'with vas_conf_lowercase_homedirs set to invalid non-boolean string' do
      let :params do
        { :vas_conf_lowercase_homedirs => 'invalid' }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error)
      end
    end

    context 'with vas_conf_lowercase_names set to invalid non-boolean string' do
      let :params do
        { :vas_conf_lowercase_names => 'invalid' }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error)
      end
    end

    context 'with vas_conf_libvas_site_only_servers set to invalid non-boolean string' do
      let :params do
        { :vas_conf_libvas_site_only_servers => 'invalid' }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error)
      end
    end

    context 'with vas_conf_libvas_auth_helper_timeout set to invalid string (non-integer)' do
      let :params do
        { :vas_conf_libvas_auth_helper_timeout => '10invalid' }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /validate_integer/)
      end
    end

    context 'with vas_conf_client_addrs set to a string too long (>1024 bytes)' do
      let :params do
        { :vas_conf_client_addrs => '100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100 100.100.100.100' }
      end

      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /validate_slength/)
      end
    end

    context 'with users_allow_entries specified as an array on osfamily redhat with lsbmajdistrelease 6' do
      let :params do
        {
          :users_allow_entries => ['user@realm.com', 'DOMAIN\adgroup'],
        }
      end
      content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |user@realm.com
        |DOMAIN\\adgroup
      END

      it do
        should contain_file('vas_users_allow').with({
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/users.allow',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => content,
        })
      end
    end

    context 'with users_allow_entries specified as a string on osfamily redhat with lsbmajdistrelease 6' do
      let :params do
        {
          :users_allow_entries => 'DOMAIN\adgroup',
        }
      end
      content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |DOMAIN\\adgroup
      END

      it do
        should contain_file('vas_users_allow').with({
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/users.allow',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => content,
        })
      end
    end

    context 'with users_deny_entries specified as an array on osfamily redhat with lsbmajdistrelease 6' do
      let :params do
        {
          :users_deny_entries => ['user@realm.com', 'DOMAIN\adgroup'],
        }
      end
      content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |user@realm.com
        |DOMAIN\\adgroup
      END

      it do
        should contain_file('vas_users_deny').with({
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/users.deny',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => content,
        })
      end
    end

    context 'with users_deny_entries specified as a string on osfamily redhat with lsbmajdistrelease 6' do
      let :params do
        {
          :users_deny_entries => 'DOMAIN\adgroup',
        }
      end
      content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |DOMAIN\\adgroup
      END

      it do
        should contain_file('vas_users_deny').with({
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/users.deny',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => content,
        })
      end
    end

    context 'with user_override_entries specified as an array on osfamily redhat with lsbmajdistrelease 6' do
      let :params do
        {
          :user_override_entries  => ['jdoe@example.com::::::/bin/sh', 'jane@example.com:::::/local/home/jane:'],
          :vas_user_override_path => '/path/to/user-override',
        }
      end
      content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |jdoe@example.com::::::/bin/sh
        |jane@example.com:::::/local/home/jane:
      END

      it do
        should contain_file('vas_user_override').with({
          'ensure'  => 'file',
          'path'    => '/path/to/user-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => content,
        })
      end
    end

    context 'with user_override_entries specified as a string on osfamily redhat with lsbmajdistrelease 6' do
      let :params do
        {
          :user_override_entries  => 'jdoestring@example.com::::::/bin/sh',
          :vas_user_override_path => '/path/to/user-override',
        }
      end
      content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |jdoestring@example.com::::::/bin/sh
      END

      it do
        should contain_file('vas_user_override').with({
          'ensure'  => 'file',
          'path'    => '/path/to/user-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => content,
        })
      end
    end

    context 'with group_override_entries specified as an array on osfamily redhat with lsbmajdistrelease 6' do
      let :params do
        {
          :group_override_entries  => ['DOMAIN\adgroup:group::', 'DOMAIN\adgroup2:group2::'],
          :vas_group_override_path => '/path/to/group-override',
        }
      end
      content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |DOMAIN\\adgroup:group::
        |DOMAIN\\adgroup2:group2::
      END

      it do
        should contain_file('vas_group_override').with({
          'ensure'  => 'file',
          'path'    => '/path/to/group-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => content,
        })
      end
    end

    context 'with group_override_entries specified as a string on osfamily redhat with lsbmajdistrelease 6' do
      let :params do
        {
          :group_override_entries  => 'DOMAIN\adgroup:group::',
          :vas_group_override_path => '/path/to/group-override',
        }
      end
      content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |DOMAIN\\adgroup:group::
      END

      it do
        should contain_file('vas_group_override').with({
          'ensure'  => 'file',
          'path'    => '/path/to/group-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => content,
        })
      end
    end

    # Vas Domain unjoin
    context 'with unjoin_vas set to false' do
      let :params do
        {
          :unjoin_vas => false,
          :realm      => 'realm.example.com',
        }
      end
      it { should contain_class('vas') }
      it { should_not contain_exec('vas_unjoin') }
      it { should contain_exec('vasinst') }
    end

    context 'with unjoin_vas set to true and vas_domain fact set' do
      let :facts do
        default_facts.merge(
          {
            :vas_domain => 'realm.example.com',
          }
        )
      end
      let :params do
        {
          :unjoin_vas => true,
          :realm      => 'realm.example.com',
        }
      end
      it { should contain_class('vas') }
      it { should contain_exec('vas_unjoin') }
      it { should_not contain_exec('vasinst') }
    end

    context 'with unjoin_vas set to true and vas_domain fact unset' do
      let :facts do
        default_facts.merge(
          {
            :vas_domain => nil,
          }
        )
      end
      let :params do
        {
          :unjoin_vas => true,
          :realm      => 'realm.example.com',
        }
      end
      it { should contain_class('vas') }
      it { should_not contain_exec('vas_unjoin') }
      it { should_not contain_exec('vasinst') }
    end

    # Domain change spec tests
    context 'with domain_change set to false and matching domains' do
      let :params do
        {
          :domain_change => false,
          :realm         => 'realm.example.com',
        }
      end
      it { should contain_class('vas') }
      it { should_not contain_exec('vas_change_domain') }
    end

    context 'with domain_change set to false and mismatching domains' do
      let :params do
        {
          :domain_change => false,
          :realm         => 'example.io',
        }
      end
      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /VAS domain mismatch/)
      end
    end

    context 'with domain_change set to true and matching domains' do
      let :params do
        {
          :domain_change => true,
          :realm         => 'realm.example.com',
        }
      end
      it { should_not contain_exec('vas_change_domain') }
    end

    context 'with domain_change set to true and mismatching domains' do
      let :params do
        {
          :domain_change => true,
          :realm         => 'example.io',
        }
      end
      it do
        should contain_exec('vas_change_domain').with(
          'command'  => "$(sed 's/\\(.*\\)join.*/\\1unjoin/' /etc/opt/quest/vas/lastjoin) > /tmp/vas_unjoin.txt 2>&1 && rm -f /etc/opt/quest/vas/puppet_joined",
          'onlyif'   => '/usr/bin/test -f /etc/vasinst.key && /usr/bin/test -f /etc/opt/quest/vas/lastjoin',
          'provider' => 'shell',
          'path'     => '/bin:/usr/bin:/opt/quest/bin',
          'timeout'  => 1800,
          'before'   => ['File[vas_config]', 'File[keytab]', 'Exec[vasinst]'],
          'require'  => ['Package[vasclnt]', 'Package[vasyp]', 'Package[vasgp]']
        )
      end
      it { should contain_exec('vasinst') }
      it { should contain_exec('vasinst').that_requires('Exec[vas_change_domain]') }
    end
    # End Domain change spec tests

    context 'with non-UPM configuration' do
      let :params do
        {
          :user_search_path           => 'OU=Users,DC=example,DC=com',
          :group_search_path          => 'OU=Groups,DC=example,DC=com',
          :computers_ou               => 'OU=Computers,DC=example,DC=com',
          :vas_conf_root_update_mode  => 'force-if-needed',
          :vas_conf_group_update_mode => 'force-if-needed',
        }
      end
      it { should contain_file('vas_config').with_content(/^\s*user-search-path = OU=Users,DC=example,DC=com$/) }
      it { should contain_file('vas_config').with_content(/^\s*group-search-path = OU=Groups,DC=example,DC=com$/) }
      it { should contain_file('vas_config').with_content(/^\s*root-update-mode = force-if-needed$/) }
      it { should contain_file('vas_config').with_content(/^\s*group-update-mode = force-if-needed$/) }

      it { should contain_class('pam') }
      it { should contain_exec('vasinst').that_comes_before('Class[pam]') }
      it { should contain_exec('vasinst').with_command(/-u OU=Users,DC=example,DC=com/) }
      it { should contain_exec('vasinst').with_command(/-g OU=Groups,DC=example,DC=com/) }
      it { should contain_exec('vasinst').with_command(/-c OU=Computers,DC=example,DC=com/) }
      it { should contain_exec('vasinst').with_command(/-n host.example.com/) }
      it { should_not contain_file('vas_config').with_content(/^\s*upm-search-path/) }
      it { should_not contain_exec('vasinst').with_command(/-p OU=UPM,DC=example,DC=com/) }
    end
  end
  context 'new UPM configuration' do
    let :params do
      {
        :upm_search_path => 'OU=UPM,DC=example,DC=com',
        :computers_ou    => 'OU=Computers,DC=example,DC=com',
      }
    end

    it { should contain_file('vas_config').with_content(/^\s*upm-search-path = OU=UPM,DC=example,DC=com$/) }
    it { should_not contain_file('vas_config').with_content(/^\s*user-search-path/) }
    it { should_not contain_file('vas_config').with_content(/^\s*group-search-path/) }

    it { should contain_class('pam') }
    it { should contain_exec('vasinst').with_command(/-p OU=UPM,DC=example,DC=com/) }
    it { should contain_exec('vasinst').with_command(/-c OU=Computers,DC=example,DC=com/) }
    it { should contain_exec('vasinst').with_command(/-n host.example.com/) }
    it { should_not contain_exec('vasinst').with_command(/-g/) }
  end

  context 'old UPM-mode parameters' do
    let :params do
      {
        :users_ou     => 'OU=UPM,DC=example,DC=com',
        :computers_ou => 'OU=Computers,DC=example,DC=com',
      }
    end

    it { should contain_file('vas_config').with_content(/^\s*upm-search-path = OU=UPM,DC=example,DC=com$/) }
    it { should_not contain_file('vas_config').with_content(/^\s*user-search-path/) }
    it { should_not contain_file('vas_config').with_content(/^\s*group-search-path/) }

    it { should contain_exec('vasinst').that_comes_before('Class[pam]') }
    it { should contain_exec('vasinst').with_command(/-p OU=UPM,DC=example,DC=com/) }
    it { should contain_exec('vasinst').that_comes_before('Class[pam]') }
    it { should contain_exec('vasinst').with_command(/-c OU=Computers,DC=example,DC=com/) }
    it { should contain_exec('vasinst').with_command(/-n host.example.com/) }
    it { should_not contain_exec('vasinst').with_command(/-g/) }
  end

  # valid for all join_domain_controllers tests
  jdc_before = '/opt/quest/bin/vastool -u username -k /etc/vasinst.key -d3 join -f  -c UNSET    -n host.example.com  realm.example.com'
  jdc_after  = '> /var/tmp/vasjoin.log 2>&1 && touch /etc/opt/quest/vas/puppet_joined'

  context 'with join_domain_controllers unset' do
    it { should contain_exec('vasinst').with_command(/#{jdc_before}  #{jdc_after}/) }
  end

  context 'with join_domain_controllers as a string' do
    let(:params) { { :join_domain_controllers => 'dc01.example.com' } }

    it { should contain_exec('vasinst').with_command(/#{jdc_before} dc01.example.com #{jdc_after}/) }
  end

  context 'with join_domain_controllers as an array' do
    let(:params) { { :join_domain_controllers => ['dc01.example.com', 'dc02.example.com'] } }

    it { should contain_exec('vasinst').with_command(/#{jdc_before} dc01.example.com dc02.example.com #{jdc_after}/) }
  end

  hiera_merge_parameters = {
    'user_override_hiera_merge' =>
      {
        :filename      => 'vas_user_override',
        :true_content  => "user2@example.com:1235:12346::::/bin/bash\nuser@example.com:1234:12345::::/bin/ksh\n",
        :false_content => "user2@example.com:1235:12346::::/bin/bash\n",
      },
    'group_override_hiera_merge' =>
      {
        :filename      => 'vas_group_override',
        :true_content  => "EXAMPLE\\Engineering_Group:enggrp::\nEXAMPLE\\dbadmins:::localuser,bob\n",
        :false_content => "EXAMPLE\\Engineering_Group:enggrp::\n",
      },
  }

  file_header = "# This file is being maintained by Puppet\.\n# DO NOT EDIT\n"

  hiera_merge_parameters.each do |parameter, v|
    describe 'hiera merge parameters' do
      let :facts do
        default_facts.merge(
          {
            :fqdn            => 'hieramerge.example.local',
            :parameter_tests => parameter.to_s,
          }
        )
      end

      [true, false, 'true', 'false'].each do |value|
        context "when #{parameter} is set to #{value} (as #{value.class})" do
          let :params do
            {
              :"#{parameter}" => value,
            }
          end
          content = "#{Regexp.escape(file_header)}#{Regexp.escape(v[:"#{value}_content"])}"
          it { should contain_file(v[:filename].to_s).with_content(/^#{content}/) }
        end
      end
    end
  end

  describe 'other' do
    context 'fail on unsupported kernel' do
      let :facts do
        default_facts.merge(
          {
            :kernel => 'AIX',
          }
        )
      end
      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /Vas module support Linux and SunOS kernels\./)
      end
    end

    context 'fail on unsupported osfamily' do
      let :facts do
        default_facts.merge(
          {
            :osfamily => 'Gentoo',
          }
        )
      end
      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /Vas supports Debian, Suse, and RedHat\./)
      end
    end
  end

  describe 'with symlink_vastool_binary' do
    ['true', true].each do |value|
      context "set to #{value} (default)" do
        let(:params) do
          { :symlink_vastool_binary => value, }
        end
        it do
          should contain_file('vastool_symlink').with({
              'path'   => '/usr/bin/vastool',
              'target' => '/opt/quest/bin/vastool',
              'ensure' => 'link',
          })
        end
      end
    end

    ['false', false].each do |value|
      context "set to #{value} (default)" do
        let(:params) do
          { :symlink_vastool_binary => value, }
        end

        it { should_not contain_file('vastool_symlink') }
      end
    end

    context 'enabled with all params specified' do
      let(:params) do
        {
          :symlink_vastool_binary        => true,
          :vastool_binary                => '/foo/bar',
          :symlink_vastool_binary_target => '/bar',
        }
      end

      it do
        should contain_file('vastool_symlink').with({
            'path'   => '/bar',
            'target' => '/foo/bar',
            'ensure' => 'link',
        })
      end
    end

    context 'enabled with invalid vastool_binary' do
      let(:params) do
        {
          :symlink_vastool_binary        => true,
          :vastool_binary                => 'true',
          :symlink_vastool_binary_target => '/bar'
        }
      end
      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /is not an absolute path/)
      end
    end

    context 'enabled with invalid symlink_vastool_binary_target' do
      let(:params) do
        {
          :symlink_vastool_binary        => true,
          :vastool_binary                => '/foo/bar',
          :symlink_vastool_binary_target => 'undef'
        }
      end
      it 'should fail' do
        expect { should contain_class('vas') }.to raise_error(Puppet::Error, /is not an absolute path/)
      end
    end
  end

  describe 'licensefiles' do
    context 'with defaults on osfamily RedHat' do
      let :params do
        {
          :license_files => {
            'VAS_license' => {
              'content' => 'VAS license file contents',
            }
          }
        }
      end

      it do
        should contain_file('VAS_license').with({
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/.licenses/VAS_license',
          'content' => 'VAS license file contents',
        })
      end
    end

    context 'with custom parameters on osfamily RedHat' do
      let :params do
        {
          :license_files => {
            'VAS_license' => {
              'ensure'  => 'file',
              'path'    => '/tmp/vas_license',
              'content' => 'VAS license file',
            }
          }
        }
      end
      it do
        should contain_file('VAS_license').with({
          'ensure'  => 'file',
          'path'    => '/tmp/vas_license',
          'content' => 'VAS license file',
        })
      end
    end
  end

  [true, false,:undef].each do |value|
    context "with use_srv_infocache set to valid #{value} (as #{value.class})" do
      let (:params) { { :use_srv_infocache => value } }

      if value != :undef
        it { should contain_file('vas_config').with_content(%r{^ use-srvinfo-cache = #{value}$}) }
      else
        it { should contain_file('vas_config').without_content(%r{use-srvinfo-cache}) }
      end
    end
  end

  context 'with kdcs set to valid array [test1.domain.local test2.domain.local]' do
    let (:params) { { :kdcs => ['kdc1.domain.local', 'kdc2.domain.local'] } }
    it { should contain_file('vas_config').with_content(%r{^  kdc = kdc1.domain.local:88 kdc2.domain.local:88\n  kpasswd_server = kdc1.domain.local:464 kdc2.domain.local:464}) }
  end

  context 'with kdcs unset' do
    it { should contain_file('vas_config').without_content(%r{kdc}) }
  end

  context 'with kpasswd_servers set to valid array [kpasswd1.domain.local kpasswd2.domain.local]' do
    let (:params) { { :kpasswd_servers => ['kpasswd1.domain.local', 'kpasswd2.domain.local'] } }
    it { should contain_file('vas_config').without_content(%r{kpasswd_server}) }
  end

  context 'with kpasswd_servers set to valid array [kpasswd1.domain.local kpasswd2.domain.local] when kdcs is set to a valid array' do
    let (:params) do
      {
        :kpasswd_servers => ['kpasswd1.domain.local', 'kpasswd2.domain.local'],
        :kdcs            => ['kdc1.domain.local', 'kdc2.domain.local'],
      }
    end
    it { should contain_file('vas_config').with_content(%r{^  kdc = kdc1.domain.local:88 kdc2.domain.local:88\n  kpasswd_server = kpasswd1.domain.local:464 kpasswd2.domain.local:464}) }
  end

  context 'with kpasswd_servers unset' do
    it { should contain_file('vas_config').without_content(%r{kdc}) }
  end

  context 'with kdc_port set to valid integer 242' do
    let (:params) { { :kdc_port => 242 } }
    it { should contain_file('vas_config').without_content(%r{kdc}) }
  end

  context 'with kdc_port set to valid integer 242 when kdcs is set to a valid array' do
    let (:params) do
      {
        :kdc_port => 242,
        :kdcs     => ['kdc1.domain.local', 'kdc2.domain.local'],
      }
    end
    it { should contain_file('vas_config').with_content(%r{^  kdc = kdc1.domain.local:242 kdc2.domain.local:242}) }
  end

  context 'with kpasswd_server_port set to valid integer 242' do
    let (:params) { { :kpasswd_server_port => 242 } }
    it { should contain_file('vas_config').without_content(%r{kdc}) }
  end

  context 'with kpasswd_server_port set to valid integer 242 when kdcs is set to a valid array' do
    let (:params) do
      {
        :kpasswd_server_port => 242,
        :kdcs     => ['kdc1.domain.local', 'kdc2.domain.local'],
      }
    end
    it { should contain_file('vas_config').with_content(%r{^  kpasswd_server = kdc1.domain.local:242 kdc2.domain.local:242}) }
  end

  describe 'variable data type and content validations' do
    # set needed custom facts and variables
    let :facts do
      default_facts.merge(
        {
          :fqdn => 'hieramerge.example.local',
        }
      )
    end

    validations = {
      'netgroup_mode' => {
        :name    => %w(vas_conf_vasd_netgroup_mode),
        :valid   => ['UNSET', 'NSS', 'NIS', 'OFF'],
        :validf  => [],
        :invalid => [{ 'ha' => 'sh' }, 3, 2.42, true, false, 'nss', 'nis', 'off'],
        :message => 'Valid values are NSS, NIS and OFF|is not a string'
      },
      'array' => {
        :name    => %w(kdcs kpasswd_servers),
        :valid   => [%w(array)],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'is not an Array',
      },
      'array/string' => {
        :name    => %w(join_domain_controllers),
        :valid   => [%w(array), 'string'],
        :validf  => [],
        :invalid => [{ 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not an array nor a string',
      },
      'boolean' => {
        :name    => %w(user_override_hiera_merge group_override_hiera_merge domain_change unjoin_vas vas_conf_vas_auth_allow_disconnected_auth vas_conf_vas_auth_expand_ac_groups use_srv_infocache),
        :valid   => [true, false, 'true', 'false'],
        :validf  => [],
        :invalid => ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => '(is not a boolean|Unknown type of boolean)',
      },
      'integer/stringified' => {
        :name    => %w(vas_conf_vasypd_update_interval kdc_port kpasswd_server_port),
        :valid   => [242,'242'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 2.42, true, false, nil],
        :validf  => [],
        :message => 'Expected.*to be an Integer',
      },
      'integer (range 1-65535)' => {
        :name    => %w(kdc_port kpasswd_server_port),
        :valid   => [1, 65535],
        :validf  => [],
        :invalid => [0, 65536],
        :message => 'Expected \d+ to be (smaller|greater) or equal to (1|65535)',
      },
      'string' => {
        :name    => %w(vas_conf_libdefaults_default_cc_name vas_conf_libdefaults_default_etypes vas_conf_libdefaults_tgs_default_enctypes vas_conf_libdefaults_tkt_default_enctypes),
        :valid   => ['string'],
        :validf  => [],
        :invalid => [%w(array), { 'ha' => 'sh' }, true], # removed integer and float for Puppet 3 compatibility
        :message => 'is not a string',
      },
      'boolean/API' => {
        :name    => %w(api_enable),
        :params  => { :'api_users_allow_url' => 'https://api.example.local', :'api_token' => 'somesecret', },
        :valid   => [false, 'false'],
        :validf  => [true, 'true'], # This is valid; but depending on an external function call; thus will fail. :(
        :invalid => ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => '(is not a boolean|Unknown type of boolean)',
      },
      'string/API' => {
        :name    => %w(api_users_allow_url api_token),
        :params  => { :'api_enable' => true, :'api_users_allow_url' => 'https://api.example.local', :'api_token' => 'somesecret', },
        :valid   => [],
        :validf  => ['string'], # This is valid; but depending on an external function call; thus will fail. :(
        :invalid => [%w(array), { 'ha' => 'sh' }, true], # removed integer and float for Puppet 3 compatibility
        :message => 'is not a string',
      },
    }
    validations.sort.each do |type, var|
      mandatory_params = {} if mandatory_params.nil?
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        # For the API parts, we have a dependency on a function included in the module, which will _not_
        # work during spec-tests. For this scenario, this special exception halding for "valid but failing"
        # has been added.
        var[:validf].each do |validf|
          context "when #{var_name} (#{type}) is set to valid (but failing) #{validf} (as #{validf.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => validf, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /Error while evaluating a Function Call/)
            end
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
