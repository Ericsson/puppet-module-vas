require 'spec_helper'

describe 'vas' do

  describe 'packages' do

    context 'defaults on osfamily RedHat with lsbmajdistrelease 6' do
      let :facts do
      {
        :kernel            => 'Linux',
        :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6'
      }
      end

      it { should contain_package('vasclnt').with({'ensure' => 'installed'}) }
      it { should contain_package('vasyp').with({'ensure' => 'installed'}) }
      it { should contain_package('vasgp').with({'ensure' => 'installed'}) }
    end

# pam module does not support Suse yet
#    context 'defaults on osfamily Suse with lsbmajdistrelease 11' do
#      let :facts do
#      {
#        :kernel            => 'Linux',
#        :osfamily          => 'Suse',
#        :lsbmajdistrelease => '11'
#      }
#      end
#
#      it { should contain_package('vasclnt').with({'ensure' => 'installed'}) }
#      it { should contain_package('vasyp').with({'ensure' => 'installed'}) }
#      it { should contain_package('vasgp').with({'ensure' => 'installed'}) }
#    end

# pam module does not support Solaris yet
#    context 'defaults on osfamily Solaris with kernelrelease 5.10' do
#      let :facts do
#      {
#        :kernel        => 'SunOS',
#        :osfamily      => 'Solaris',
#        :kernelrelease => '5.10'
#      }
#      end
#
#      it { should contain_package('vasclnt').with({'ensure' => 'installed'}) }
#      it { should contain_package('vasyp').with({'ensure' => 'installed'}) }
#      it { should contain_package('vasgp').with({'ensure' => 'installed'}) }
#    end

    context 'with package_version specified on osfamily RedHat with lsbmajdistrelease 6' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6'
        }
      end
      let :params do
        {
          :package_version => '4.0.3-206',
        }
      end

      it { should contain_package('vasclnt').with({'ensure' => '4.0.3-206'}) }
      it { should contain_package('vasyp').with({'ensure' => '4.0.3-206'}) }
      it { should contain_package('vasgp').with({'ensure' => '4.0.3-206'}) }
    end

  end

  describe 'config' do

    context 'defaults on osfamily redhat with lsbmajdistrelease 6' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end

      it do
        should contain_file('vas_config').with({
          'ensure'  => 'present',
          'path'    => '/etc/opt/quest/vas/vas.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('vas_config').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
[domain_realm]
 host.example.com = REALM.EXAMPLE.COM

[libdefaults]
 default_realm = REALM.EXAMPLE.COM
 default_tgs_enctypes = arcfour-hmac-md5
 default_tkt_enctypes = arcfour-hmac-md5
 default_etypes_des = des-cbc-crc
 default_etypes = arcfour-hmac-md5
 forwardable = true
 renew_lifetime = 604800

 ticket_lifetime = 36000
 default_keytab_name = /etc/opt/quest/vas/host.keytab

[libvas]
 vascache-ipc-timeout = 15
 use-server-referrals = true
 mscldap-timeout = 1
 use-dns-srv = true
 use-tcp-only = true
 auth-helper-timeout = 10
 site-only-servers = false

[pam_vas]
 prompt-vas-ad-pw = "Enter Windows password: "

[vasypd]
 search-base = ou=nismaps,dc=example,dc=com
 split-groups = true
 update-interval = 1800
 domainname-override = example.com
 update-process = /opt/quest/libexec/vas/mapupdate_2307

[vasd]
 update-interval = 600
 upm-search-path = ou=users,dc=example,dc=com
 workstation-mode = false
 auto-ticket-renew-interval = 32400
 lazy-cache-update-interval = 10
 upm-computerou-attr = department

[nss_vas]
 group-update-mode = none
 root-update-mode = none

[vas_auth]
})
      end
      it do
        should contain_file('vas_user_override').with({
          'ensure'  => 'present',
          'path'    => '/etc/opt/quest/vas/user-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('vas_user_override').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
})
      end
      it do
        should contain_file('vas_group_override').with({
          'ensure'  => 'present',
          'path'    => '/etc/opt/quest/vas/group-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('vas_group_override').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
})
      end
      it do
        should contain_file('vas_users_allow').with({
          'ensure'  => 'present',
          'path'    => '/etc/opt/quest/vas/users.allow',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('vas_users_allow').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
})
      end
    end

    context 'with parameters for vas.conf specified on osfamily redhat with lsbmajdistrelease 6' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        {
          :vas_fqdn                                             => 'host2.example.com',
          :computers_ou                                         => 'ou=site,ou=computers,dc=example,dc=com',
          :nismaps_ou                                           => 'ou=site,ou=nismaps,dc=example,dc=com',
          :users_ou                                             => 'ou=site,ou=users,dc=example,dc=com',
          :realm                                                => 'realm2.example.com',
          :nisdomainname                                        => 'nis.domain',
          :vas_conf_prompt_vas_ad_pw                            => 'Enter pw',
          :vas_conf_pam_vas_prompt_ad_lockout_msg               => 'Account is locked',
          :vas_conf_libdefaults_forwardable                     => 'false',
          :vas_conf_client_addrs                                => '10.10.0.0/24 10.50.0.0/24',
          :vas_conf_update_process                              => '/opt/quest/libexec/vas/mapupdate',
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
          :vas_conf_vasd_ws_resolve_uid                         => 'true',
          :vas_conf_vasd_lazy_cache_update_interval             => '5',
          :vas_conf_vasd_password_change_script_timelimit       => '30',
          :vas_conf_libvas_auth_helper_timeout                  => '120',
          :sitenameoverride                                     => 'foobar',
          :vas_conf_libvas_use_dns_srv                          => 'false',
          :vas_conf_libvas_use_tcp_only                         => 'false',
          :vas_conf_libvas_mscldap_timeout                      => '10',
          :vas_conf_libvas_site_only_servers                    => 'false',
          :vas_conf_vas_auth_uid_check_limit                    => '100000',
        }
      end

      it do
        should contain_file('vas_config').with({
          'ensure'  => 'present',
          'path'    => '/etc/opt/quest/vas/vas.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('vas_config').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
[domain_realm]
 host2.example.com = REALM2.EXAMPLE.COM

[libdefaults]
 default_realm = REALM2.EXAMPLE.COM
 default_tgs_enctypes = arcfour-hmac-md5
 default_tkt_enctypes = arcfour-hmac-md5
 default_etypes_des = des-cbc-crc
 default_etypes = arcfour-hmac-md5
 forwardable = false
 renew_lifetime = 604800

 ticket_lifetime = 36000
 default_keytab_name = /etc/opt/quest/vas/host.keytab

[libvas]
 vascache-ipc-timeout = 15
 use-server-referrals = true
 site-name-override = foobar
 mscldap-timeout = 10
 use-dns-srv = false
 use-tcp-only = false
 auth-helper-timeout = 120
 site-only-servers = false

[pam_vas]
 prompt-vas-ad-pw = Enter pw
 prompt-ad-lockout-msg = "Account is locked"

[vasypd]
 search-base = ou=site,ou=nismaps,dc=example,dc=com
 split-groups = true
 update-interval = 1800
 domainname-override = nis.domain
 update-process = /opt/quest/libexec/vas/mapupdate
 client-addrs = 10.10.0.0/24 10.50.0.0/24

[vasd]
 update-interval = 1200
 upm-search-path = ou=site,ou=users,dc=example,dc=com
 workstation-mode = true
 workstation-mode-users-preload = usergroup
 workstation-mode-group-do-member = true
 workstation-mode-groups-skip-update = true
 ws-resolve-uid = true
 auto-ticket-renew-interval = 540
 lazy-cache-update-interval = 5
 cross-domain-user-groups-member-search = true
 timesync-interval = 0
 preload-nested-memberships = false
 upm-computerou-attr = managedBy
 password-change-script = /opt/quest/libexec/vas-set-samba-password
 password-change-script-timelimit = 30

[nss_vas]
 group-update-mode = none
 root-update-mode = none

[vas_auth]
 uid-check-limit = 100000
})
      end
    end

    context 'with vas_fqdn to invalid domainname' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        { :vas_fqdn => 'bad!@#hostname' }
      end

      it 'should fail' do
        expect {
          should include_class('vas')
        }.to raise_error(Puppet::Error,/vas::vas_fqdn is not a valid FQDN. Detected value is <bad!@#hostname>./)
      end
    end

    context 'with vas_conf_vasd_auto_ticket_renew_interval to invalid string (non-integer)' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        { :vas_conf_vasd_auto_ticket_renew_interval => '600invalid' }
      end

      it 'should fail' do
        expect {
          should include_class('vas')
        }.to raise_error(Puppet::Error,/vas::vas_conf_vasd_auto_ticket_renew_interval must be an integer. Detected value is <600invalid>./)
      end
    end

    context 'with vas_conf_vasd_update_interval set to invalid string (non-integer)' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        { :vas_conf_vasd_update_interval => '600invalid' }
      end

      it 'should fail' do
        expect {
          should include_class('vas')
        }.to raise_error(Puppet::Error,/vas::vas_conf_vasd_update_interval must be an integer. Detected value is <600invalid>./)
      end
    end

    context 'with vas_conf_prompt_vas_ad_pw set to invalid type (non-string)' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        { :vas_conf_prompt_vas_ad_pw => ['array'] }
      end

      it 'should fail' do
        expect {
          should include_class('vas')
        }.to raise_error(Puppet::Error,/is not a string/)
      end
    end

    context 'with vas_conf_libvas_use_dns_srv set to invalid non-boolean string' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        { :vas_conf_libvas_use_dns_srv => 'invalid' }
      end

      it 'should fail' do
        expect {
          should include_class('vas')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with vas_conf_libvas_use_tcp_only set to invalid non-boolean string' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        { :vas_conf_libvas_use_tcp_only => 'invalid' }
      end

      it 'should fail' do
        expect {
          should include_class('vas')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with vas_conf_libvas_site_only_servers set to invalid non-boolean string' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        { :vas_conf_libvas_site_only_servers => 'invalid' }
      end

      it 'should fail' do
        expect {
          should include_class('vas')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with vas_conf_libvas_auth_helper_timeout set to invalid string (non-integer)' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        { :vas_conf_libvas_auth_helper_timeout => '10invalid' }
      end

      it 'should fail' do
        expect {
          should include_class('vas')
        }.to raise_error(Puppet::Error,/vas::vas_conf_libvas_auth_helper_timeout must be an integer. Detected value is <10invalid>./)
      end
    end

    context 'with users_allow_entries specified on osfamily redhat with lsbmajdistrelease 6' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        {
          :users_allow_entries => ['user@realm.com','DOMAIN\adgroup'],
        }
      end

      it do
        should contain_file('vas_users_allow').with({
          'ensure'  => 'present',
          'path'    => '/etc/opt/quest/vas/users.allow',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('vas_users_allow').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
user@realm.com
DOMAIN\\adgroup
})
      end
    end

    context 'with user_override_entries specified on osfamily redhat with lsbmajdistrelease 6' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        {
          :user_override_entries => ['jdoe@example.com::::::/bin/sh'],
          :vas_user_override_path => '/path/to/user-override',
        }
      end

      it do
        should contain_file('vas_user_override').with({
          'ensure'  => 'present',
          'path'    => '/path/to/user-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('vas_user_override').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
jdoe@example.com::::::/bin/sh
})
      end
    end

    context 'with group_override_entries specified on osfamily redhat with lsbmajdistrelease 6' do
      let :facts do
        {
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
          :fqdn              => 'host.example.com',
          :domain            => 'example.com',
        }
      end
      let :params do
        {
          :group_override_entries => ['DOMAIN\adgroup:group::'],
          :vas_group_override_path => '/path/to/group-override',
        }
      end

      it do
        should contain_file('vas_group_override').with({
          'ensure'  => 'present',
          'path'    => '/path/to/group-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
        should contain_file('vas_group_override').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
DOMAIN\\adgroup:group::
})
      end
    end

  end

  describe "other" do

    context 'fail on unsupported kernel' do
      let :facts do
        {
          :kernel => 'AIX',
        }
      end
      it do
        expect {
          should include_class('vas')
        }.to raise_error(Puppet::Error,/Vas module support Linux and SunOS kernels./)
      end
    end

    context 'fail on unsupported osfamily' do
      let :facts do
        {
          :kernel   => 'Linux',
          :osfamily => 'Gentoo',
        }
      end
      it do
        expect {
          should include_class('vas')
        }.to raise_error(Puppet::Error,/Vas supports Debian, Suse, and RedHat./)
      end
    end

  end

  describe 'with symlink_vastool_binary' do
    ['true',true].each do |value|
      context "set to #{value} (default)" do
        let(:facts) { { :kernel            => 'Linux',
                        :osfamily          => 'Redhat',
                        :lsbmajdistrelease => 6,
                    } }
        let(:params) do
          { :symlink_vastool_binary => value, }
        end

        it {
          should contain_file('vastool_symlink').with({
            'path'    => '/usr/bin/vastool',
            'target'  => '/opt/quest/bin/vastool',
            'ensure'  => 'link',
          })
        }
      end
    end

    ['false',false].each do |value|
      context "set to #{value} (default)" do
        let(:facts) { { :kernel            => 'Linux',
                        :osfamily          => 'Redhat',
                        :lsbmajdistrelease => 6,
                    } }
        let(:params) do
          { :symlink_vastool_binary => value, }
        end

        it { should_not contain_file('vastool_symlink') }
      end
    end

    context 'enabled with all params specified' do
      let(:facts) { { :kernel            => 'Linux',
                      :osfamily          => 'Redhat',
                      :lsbmajdistrelease => 6,
                  } }
      let(:params) do
        { :symlink_vastool_binary        => true,
          :vastool_binary                => '/foo/bar',
          :symlink_vastool_binary_target => '/bar',
        }
      end

      it {
        should contain_file('vastool_symlink').with({
          'path'    => '/bar',
          'target'  => '/foo/bar',
          'ensure'  => 'link',
        })
      }
    end

    context 'enabled with invalid vastool_binary' do
      let(:params) { { :symlink_vastool_binary        => true,
                       :vastool_binary                => 'true',
                       :symlink_vastool_binary_target => '/bar' } }
      it do
        expect { should }.to raise_error(Puppet::Error)
      end
    end

    context 'enabled with invalid symlink_vastool_binary_target' do
      let(:params) { { :symlink_vastool_binary        => true,
                       :vastool_binary                => '/foo/bar',
                       :symlink_vastool_binary_target => 'undef' } }
      it do
        expect { should }.to raise_error(Puppet::Error)
      end
    end
  end

end
