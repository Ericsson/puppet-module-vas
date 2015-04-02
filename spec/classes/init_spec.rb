require 'spec_helper'

describe 'vas' do

  platforms = {
    'Linux' =>
      { :osfamily                   => 'RedHat',
        :kernel                     => 'Linux',
        :lsbmajdistrelease          => '6',
        :operatingsystemmajrelease  => '6',
        :package_version_ensure     => '4.0.3-206',
      },
#    'RedHat-5' =>
#      { :osfamily                   => 'RedHat',
#        :kernel                     => 'Linux',
#        :lsbmajdistrelease          => '5',
#        :operatingsystemmajrelease  => '5',
#      },
#    'RedHat-6' =>
#      { :osfamily                   => 'RedHat',
#        :kernel                     => 'Linux',
#        :lsbmajdistrelease          => '6',
#        :operatingsystemmajrelease  => '6',
#      },
#    'RedHat-7' =>
#      { :osfamily                   => 'RedHat',
#        :kernel                     => 'Linux',
#        :lsbmajdistrelease          => '7',
#        :operatingsystemmajrelease  => '7',
#      },
#    'Suse-10' =>
#      { :osfamily                   => 'Suse',
#        :kernel                     => 'Linux',
#        :lsbmajdistrelease          => '10',
#        :operatingsystemmajrelease  => '',
#      },
#    'Suse-11' =>
#      { :osfamily                   => 'Suse',
#        :kernel                     => 'Linux',
#        :lsbmajdistrelease          => '11',
#        :operatingsystemmajrelease  => '',
#      },
    'SunOS' =>
      { :osfamily                   => 'Solaris',
        :kernel                     => 'SunOS',
        :kernelrelease              => '5.10',
        :package_version_ensure     => 'installed',
      },
  }

  describe 'with default values' do

    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        it { should contain_package('vasclnt').with({'ensure' => 'installed'}) }
        it { should contain_package('vasyp').with({'ensure' => 'installed'}) }
        it { should contain_package('vasgp').with({'ensure' => 'installed'}) }

        it {
          should contain_file('vas_config').with({
            'ensure'  => 'present',
            'path'    => '/etc/opt/quest/vas/vas.conf',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }
        it { should contain_file('vas_config').with_content(/host.example.com = REALM.EXAMPLE.COM/) }
        it { should contain_file('vas_config').with_content(/upm-search-path = ou=users,dc=example,dc=com/) }
        it { should contain_file('vas_config').with_content(/search-base = ou=nismaps,dc=example,dc=com/) }
        it { should contain_file('vas_config').with_content(/domainname-override = example.com/) }
        it { should contain_file('vas_config').with_content(/prompt-vas-ad-pw = "Enter Windows password: "/) }
        it { should contain_file('vas_config').with_content(/forwardable = true/) }
        it { should contain_file('vas_config').with_content(/update-process = \/opt\/quest\/libexec\/vas\/mapupdate_2307/) }
        it { should contain_file('vas_config').with_content(/update-interval = 600/) }
        it { should contain_file('vas_config').with_content(/upm-computerou-attr = department/) }
        it { should contain_file('vas_config').with_content(/workstation-mode = false/) }
        it { should contain_file('vas_config').with_content(/lazy-cache-update-interval = 10/) }
        it { should contain_file('vas_config').with_content(/auth-helper-timeout = 10/) }
        it { should contain_file('vas_config').with_content(/use-dns-srv = true/) }
        it { should contain_file('vas_config').with_content(/use-tcp-only = true/) }
        it { should contain_file('vas_config').with_content(/mscldap-timeout = 1/) }
        it { should contain_file('vas_config').with_content(/site-only-servers = false/) }
        it { should contain_file('vas_config').with_content(/vascache-ipc-timeout = 15/) }

        it {
          should contain_file('vas_user_override').with({
            'ensure'  => 'present',
            'path'    => '/etc/opt/quest/vas/user-override',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }
        it {
          should contain_file('vas_group_override').with({
            'ensure'  => 'present',
            'path'    => '/etc/opt/quest/vas/group-override',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }
        it {
          should contain_file('vas_users_allow').with({
            'ensure'  => 'present',
            'path'    => '/etc/opt/quest/vas/users.allow',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }
        it {
          should contain_file('vas_users_deny').with({
            'ensure'  => 'present',
            'path'    => '/etc/opt/quest/vas/users.deny',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }

        it {
          should contain_file('keytab').with({
            'ensure'  => 'present',
            'path'    => '/etc/vasinst.key',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0400',
          })
        }

        it {
          should contain_service('vasd').with({
            'ensure'  => 'running',
            'enable'  => 'true',
            'require' => 'Exec[vasinst]',
          })
        }

        it {
          should contain_service('vasypd').with({
            'ensure'  => 'running',
            'enable'  => 'true',
            'require' => 'Service[vasd]',
          })
        }

        it { should contain_exec('vasinst').with_command(/\/opt\/quest\/bin\/vastool -u username -k \/etc\/vasinst.key -d3 join -f  -c ou=computers,dc=example,dc=com -p ou=users,dc=example,dc=com -n host.example.com  realm.example.com > \/var\/tmp\/vasjoin.log 2>&1 && touch \/etc\/opt\/quest\/vas\/puppet_joined/) }

      end
    end

    context 'on unsupported kernel' do
      let :facts do
        {
          :kernel => 'AIX',
        }
      end
      it 'should fail' do
        expect {
          should contain_class('vas')
        }.to raise_error(Puppet::Error,/Vas module support Linux and SunOS kernels./)
      end
    end

    context 'on unsupported Linux osfamily' do
      let :facts do
      {
        :kernel   => 'Linux',
        :osfamily => 'Gentoo',
      }
      end
      it 'should fail' do
        expect {
          should contain_class('vas')
        }.to raise_error(Puppet::Error,/Vas supports Debian, Suse, and RedHat./)
      end
    end

    context 'on unsupported Solaris kernelrelease' do
      let :facts do
      {
        :kernel        => 'SunOS',
        :kernelrelease => '5.8',
      }
      end
      it 'should fail' do
        expect {
          should contain_class('vas')
        }.to raise_error(Puppet::Error,/Vas supports Solaris kernelrelease 5.9, 5.10 and 5.11. Detected kernelrelease is <5.8>/)
      end
    end
  end

  describe 'with parameters for vas.conf specified' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
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
          :sitenameoverride                                     => 'foobar',
          :vas_conf_prompt_vas_ad_pw                            => 'Enter pw',
          :vas_conf_pam_vas_prompt_ad_lockout_msg               => 'Account is locked',
          :vas_conf_libdefaults_forwardable                     => 'false',
          :vas_conf_client_addrs                                => '10.10.0.0/24 10.50.0.0/24',
          :vas_conf_disabled_user_pwhash                        => 'disabled',
          :vas_conf_locked_out_pwhash                           => 'locked',
          :vas_conf_update_process                              => '/opt/quest/libexec/vas/mapupdate',
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
          :vas_conf_vasd_ws_resolve_uid                         => 'true',
          :vas_conf_vasd_lazy_cache_update_interval             => '5',
          :vas_conf_vasd_password_change_script_timelimit       => '30',
          :vas_conf_libvas_auth_helper_timeout                  => '120',
          :vas_conf_libvas_use_dns_srv                          => 'false',
          :vas_conf_libvas_use_tcp_only                         => 'false',
          :vas_conf_libvas_mscldap_timeout                      => '10',
          :vas_conf_libvas_site_only_servers                    => 'false',
          :vas_conf_libvas_vascache_ipc_timeout                 => '10',
          :vas_conf_vas_auth_uid_check_limit                    => '100000',
          :vas_conf_vasd_deluser_check_timelimit                => '30',
          :vas_conf_vasd_delusercheck_interval                  => '30',
          :vas_conf_vasd_delusercheck_script                    => '/path/to/script',
        }
        end

        it { should contain_file('vas_config').with_content(/host2.example.com = REALM2.EXAMPLE.COM/) }
        it { should contain_file('vas_config').with_content(/upm-search-path = ou=site,ou=users,dc=example,dc=com/) }
        it { should contain_file('vas_config').with_content(/search-base = ou=site,ou=nismaps,dc=example,dc=com/) }
        it { should contain_file('vas_config').with_content(/domainname-override = nis.domain/) }
        it { should contain_file('vas_config').with_content(/prompt-vas-ad-pw = Enter pw/) }
        it { should contain_file('vas_config').with_content(/prompt-ad-lockout-msg = \"Account is locked\"/) }
        it { should contain_file('vas_config').with_content(/forwardable = false/) }
        it { should contain_file('vas_config').with_content(/client-addrs = 10.10.0.0\/24 10.50.0.0\/24/) }
        it { should contain_file('vas_config').with_content(/disabled-user-pwhash = disabled/) }
        it { should contain_file('vas_config').with_content(/locked-out-pwhash = locked/) }
        it { should contain_file('vas_config').with_content(/update-process = \/opt\/quest\/libexec\/vas\/mapupdate/) }
        it { should contain_file('vas_config').with_content(/full-update-interval = 3600/) }
        it { should contain_file('vas_config').with_content(/update-interval = 1200/) }
        it { should contain_file('vas_config').with_content(/upm-computerou-attr = managedBy/) }
        it { should contain_file('vas_config').with_content(/preload-nested-memberships = false/) }
        it { should contain_file('vas_config').with_content(/cross-domain-user-groups-member-search = true/) }
        it { should contain_file('vas_config').with_content(/workstation-mode = true/) }
        it { should contain_file('vas_config').with_content(/workstation-mode-users-preload = usergroup/) }
        it { should contain_file('vas_config').with_content(/workstation-mode-group-do-member = true/) }
        it { should contain_file('vas_config').with_content(/workstation-mode-groups-skip-update = true/) }
        it { should contain_file('vas_config').with_content(/ws-resolve-uid = true/) }
        it { should contain_file('vas_config').with_content(/lazy-cache-update-interval = 5/) }
        it { should contain_file('vas_config').with_content(/password-change-script-timelimit = 30/) }
        it { should contain_file('vas_config').with_content(/site-name-override = foobar/) }
        it { should contain_file('vas_config').with_content(/auth-helper-timeout = 120/) }
        it { should contain_file('vas_config').with_content(/use-dns-srv = false/) }
        it { should contain_file('vas_config').with_content(/use-tcp-only = false/) }
        it { should contain_file('vas_config').with_content(/mscldap-timeout = 10/) }
        it { should contain_file('vas_config').with_content(/site-only-servers = false/) }
        it { should contain_file('vas_config').with_content(/uid-check-limit = 100000/) }
        it { should contain_file('vas_config').with_content(/vascache-ipc-timeout = 10/) }
        it { should contain_file('vas_config').with_content(/deluser-check-timelimit = 30/) }
        it { should contain_file('vas_config').with_content(/delusercheck-interval = 30/) }
        it { should contain_file('vas_config').with_content(/delusercheck-script = \/path\/to\/script/) }
      end
    end
  end

  describe 'with package_version specified' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :package_version => '4.0.3-206' } end

        it { should contain_package('vasclnt').with({'ensure' => v[:package_version_ensure]}) }
        it { should contain_package('vasyp').with({'ensure' => v[:package_version_ensure]}) }
        it { should contain_package('vasgp').with({'ensure' => v[:package_version_ensure]}) }
      end
    end
  end

  describe 'with users_allow_entries specified as an array' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :users_allow_entries => ['user@realm.com','DOMAIN\adgroup'] } end

        it {
          should contain_file('vas_users_allow').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
user@realm.com
DOMAIN\\adgroup
}) }
      end
    end
  end

  describe 'with users_allow_entries specified as a string' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :users_allow_entries => 'DOMAIN\adgroup' } end

        it {
          should contain_file('vas_users_allow').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
DOMAIN\\adgroup
}) }
      end
    end
  end

  describe 'with users_deny_entries specified as an array' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :users_deny_entries => ['user@realm.com','DOMAIN\adgroup'] } end

        it {
          should contain_file('vas_users_deny').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
user@realm.com
DOMAIN\\adgroup
}) }
      end
    end
  end

  describe 'with users_deny_entries specified as a string' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :users_deny_entries => 'DOMAIN\adgroup' } end

        it {
          should contain_file('vas_users_deny').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
DOMAIN\\adgroup
}) }
      end
    end
  end

  describe 'with user_override_entries specified as an array' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :user_override_entries => ['jdoe@example.com::::::/bin/sh','jane@example.com:::::/local/home/jane:'] } end

        it {
          should contain_file('vas_user_override').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
jdoe@example.com::::::/bin/sh
jane@example.com:::::/local/home/jane:
}) }
      end
    end
  end

  describe 'with user_override_entries specified as a string' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :user_override_entries => 'jdoestring@example.com::::::/bin/sh' } end

        it {
          should contain_file('vas_user_override').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
jdoestring@example.com::::::/bin/sh
}) }
      end
    end
  end

  describe 'with group_override_entries specified as an array' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :group_override_entries => ['DOMAIN\adgroup:group::','DOMAIN\adgroup2:group2::'] } end

        it {
          should contain_file('vas_group_override').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
DOMAIN\\adgroup:group::
DOMAIN\\adgroup2:group2::
}) }
      end
    end
  end

  describe 'with group_override_entries specified as a string' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :group_override_entries => 'DOMAIN\adgroup:group::' } end

        it {
          should contain_file('vas_group_override').with_content(
%{# This file is being maintained by Puppet.
# DO NOT EDIT
DOMAIN\\adgroup:group::
}) }
      end
    end
  end

  describe 'with symlink_vastool_binary specified' do
    platforms.sort.each do |k,v|

      ['true',true].each do |value|
        context "set to #{value} (default) on <#{k}>" do
          let(:facts) { { :kernel                    => v[:kernel],
                          :kernelrelease             => v[:kernelrelease],
                          :osfamily                  => v[:osfamily],
                          :lsbmajdistrelease         => v[:lsbmajdistrelease],
                          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
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
        context "set to #{value} (default) on <#{k}>" do
          let(:facts) { { :kernel                    => v[:kernel],
                          :kernelrelease             => v[:kernelrelease],
                          :osfamily                  => v[:osfamily],
                          :lsbmajdistrelease         => v[:lsbmajdistrelease],
                          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
                      } }
          let(:params) do
            { :symlink_vastool_binary => value, }
          end

          it { should_not contain_file('vastool_symlink') }
        end
      end

      context "enabled with all params specified on <#{k}>" do
        let(:facts) { { :kernel                    => v[:kernel],
                        :kernelrelease             => v[:kernelrelease],
                        :osfamily                  => v[:osfamily],
                        :lsbmajdistrelease         => v[:lsbmajdistrelease],
                        :operatingsystemmajrelease => v[:operatingsystemmajrelease],
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

      context "enabled with invalid vastool_binary on <#{k}>" do
        let(:facts) { { :kernel                    => v[:kernel],
                        :kernelrelease             => v[:kernelrelease],
                        :osfamily                  => v[:osfamily],
                        :lsbmajdistrelease         => v[:lsbmajdistrelease],
                        :operatingsystemmajrelease => v[:operatingsystemmajrelease],
                    } }
        let(:params) { { :symlink_vastool_binary        => true,
                         :vastool_binary                => 'true',
                         :symlink_vastool_binary_target => '/bar' } }
        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error, /is not an absolute path/)
        end
      end

      context "enabled with invalid symlink_vastool_binary_target on <#{k}>" do
        let(:facts) { { :kernel                    => v[:kernel],
                        :kernelrelease             => v[:kernelrelease],
                        :osfamily                  => v[:osfamily],
                        :lsbmajdistrelease         => v[:lsbmajdistrelease],
                        :operatingsystemmajrelease => v[:operatingsystemmajrelease],
                    } }
        let(:params) { { :symlink_vastool_binary        => true,
                         :vastool_binary                => '/foo/bar',
                         :symlink_vastool_binary_target => 'undef' } }
        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error, /is not an absolute path/)
        end
      end
    end
  end

  describe 'with license_files defaults' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do
        {
          :license_files => {
            'VAS_license' => {
              'content' => 'VAS license file contents',
            }
          }
        }
        end

        it {
          should contain_file('VAS_license').with({
            'ensure' => 'file',
            'path'   => '/etc/opt/quest/vas/.licenses/VAS_license',
            'content' => 'VAS license file contents',
          })
        }
      end
    end
  end

  describe 'with license_files specified with custom parameters' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do
        {
          :license_files => {
            'VAS_license' => {
              'ensure' => 'present',
              'path' => '/tmp/vas_license',
              'content' => 'VAS license file',
            }
          }
        }
        end

        it {
          should contain_file('VAS_license').with({
            'ensure' => 'present',
            'path'   => '/tmp/vas_license',
            'content' => 'VAS license file',
          })
        }
      end
    end
  end

  describe 'with enable_group_policies set to false' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :enable_group_policies => 'false' } end

        it { should contain_package('vasgp').with_ensure('absent') }
      end
    end
  end

  describe 'with vas_fqdn to invalid domainname' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :vas_fqdn => 'bad!@#hostname' } end

        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error,/vas::vas_fqdn is not a valid FQDN. Detected value is <bad!@#hostname>./)
        end
      end
    end
  end

  describe 'with enable_group_policies to invalid type (not bool or string)' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :enable_group_policies => '600invalid' } end

        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error,/Unknown type of boolean given/)
        end
      end
    end
  end

  describe 'with vas_conf_vasd_auto_ticket_renew_interval to invalid string (non-integer)' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :vas_conf_vasd_auto_ticket_renew_interval => '600invalid' } end

        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error,/vas::vas_conf_vasd_auto_ticket_renew_interval must be an integer. Detected value is <600invalid>./)
        end
      end
    end
  end

  describe 'with vas_conf_vasd_update_interval set to invalid string (non-integer)' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :vas_conf_vasd_update_interval => '600invalid' } end

        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error,/vas::vas_conf_vasd_update_interval must be an integer. Detected value is <600invalid>./)
        end
      end
    end
  end

  describe 'with vas_conf_prompt_vas_ad_pw set to invalid type (non-string)' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :vas_conf_prompt_vas_ad_pw => ['array'] } end

        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error,/is not a string/)
        end
      end
    end
  end

  describe 'with vas_conf_prompt_vas_ad_pw set to invalid type (non-string)' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :vas_conf_disabled_user_pwhash => ['array'] } end

        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error,/is not a string/)
        end
      end
    end
  end

  describe 'with vas_conf_locked_out_pwhash set to invalid type (non-string)' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :vas_conf_locked_out_pwhash => ['array'] } end

        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error,/is not a string/)
        end
      end
    end
  end

  describe 'with vas_conf_libvas_use_dns_srv set to invalid non-boolean string' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :vas_conf_libvas_use_dns_srv => 'invalid' } end

        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error,/Unknown type of boolean given/)
        end
      end
    end
  end

  describe 'with vas_conf_libvas_use_tcp_only set to invalid non-boolean string' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :vas_conf_libvas_use_tcp_only => 'invalid' } end

        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error,/Unknown type of boolean given/)
        end
      end
    end
  end

  describe 'with vas_conf_libvas_site_only_servers set to invalid non-boolean string' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :vas_conf_libvas_site_only_servers => 'invalid' } end

        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error,/Unknown type of boolean given/)
        end
      end
    end
  end

  describe 'with vas_conf_libvas_auth_helper_timeout set to invalid string (non-integer)' do
    platforms.sort.each do |k,v|

      context "on <#{k}>" do
        let :facts do
        {
          :kernel                    => v[:kernel],
          :kernelrelease             => v[:kernelrelease],
          :osfamily                  => v[:osfamily],
          :lsbmajdistrelease         => v[:lsbmajdistrelease],
          :operatingsystemmajrelease => v[:operatingsystemmajrelease],
          :fqdn                      => 'host.example.com',
          :domain                    => 'example.com',
        }
        end

        let :params do { :vas_conf_libvas_auth_helper_timeout => '10invalid' } end

        it 'should fail' do
          expect {
            should contain_class('vas')
          }.to raise_error(Puppet::Error,/vas::vas_conf_libvas_auth_helper_timeout must be an integer. Detected value is <10invalid>./)
        end
      end
    end
  end
end
