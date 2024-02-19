# frozen_string_literal: true

require 'spec_helper'

describe 'vas' do
  required_params = {
    keytab_source: 'puppet:///files/vas/vasinit.key',
    computers_ou: 'ou=computers,dc=domain,dc=tld',
  }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:node) { 'foo.example.com' }
      let(:facts) do
        os_facts.merge(
          lsbmajdistrelease: os_facts[:os]['release']['major'], # Satisfy nisclient
        )
      end
      let(:params) do
        required_params
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_class('nisclient')
      }

      it {
        is_expected.to contain_class('nsswitch')
      }

      it {
        is_expected.to contain_class('pam')
      }

      it {
        is_expected.to contain_package('vasclnt').with('ensure' => 'installed')
      }

      it {
        is_expected.to contain_package('vasyp').with('ensure' => 'installed')
      }

      it {
        is_expected.to contain_package('vasgp').with('ensure' => 'installed')
      }

      it {
        is_expected.not_to contain_service('vasgpd')
      }

      it {
        is_expected.not_to contain_exec('vas_unjoin')
      }

      it {
        is_expected.not_to contain_exec('vas_change_domain')
      }

      content = <<-END.gsub(%r{^\s+\|}, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |[domain_realm]
        | foo.example.com = REALM.EXAMPLE.COM
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
        | user-override-file = /etc/opt/quest/vas/user-override
        | group-override-file = /etc/opt/quest/vas/group-override

        | auto-ticket-renew-interval = 32400
        | lazy-cache-update-interval = 10
        |
        |[nss_vas]
        | group-update-mode = none
        | root-update-mode = none
        |
        |[vas_auth]
        | users-allow-file = /etc/opt/quest/vas/users.allow
        | users-deny-file = /etc/opt/quest/vas/users.deny
      END

      it {
        is_expected.to contain_file('vas_config').with(
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/vas.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => content,
          'require' => [
            'Package[vasclnt]',
            'Package[vasgp]',
            'Package[vasyp]',
          ],
        )
      }

      it {
        is_expected.to contain_file('vas_users_allow').with(
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/users.allow',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n",
          'require' => [
            'Package[vasclnt]',
            'Package[vasgp]',
            'Package[vasyp]',
          ],
        )
      }

      it {
        is_expected.to contain_file('vas_users_deny').with(
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/users.deny',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n",
          'require' => [
            'Package[vasclnt]',
            'Package[vasgp]',
            'Package[vasyp]',
          ],
        )
      }

      it {
        is_expected.to contain_file('vas_user_override').with(
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/user-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n",
          'require' => [
            'Package[vasclnt]',
            'Package[vasgp]',
            'Package[vasyp]',
          ],
          'before' => [
            'Service[vasd]',
            'Service[vasypd]',
          ],
        )
      }

      it {
        is_expected.to contain_file('vas_group_override').with(
          'ensure'  => 'file',
          'path'    => '/etc/opt/quest/vas/group-override',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => "# This file is being maintained by Puppet.\n# DO NOT EDIT\n",
          'require' => [
            'Package[vasclnt]',
            'Package[vasgp]',
            'Package[vasyp]',
          ],
          'before' => [
            'Service[vasd]',
            'Service[vasypd]',
          ],
        )
      }

      it {
        is_expected.to contain_file('keytab').with(
          'ensure' => 'file',
          'path'   => '/etc/vasinst.key',
          'source' => 'puppet:///files/vas/vasinit.key',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0400',
        )
      }

      it {
        is_expected.to contain_exec('Process check Vasypd').with(
          'path'    => '/usr/bin:/bin',
          'command' => 'rm -f /var/opt/quest/vas/vasypd/.vasypd.pid',
          'unless'  => 'ps -p `cat /var/opt/quest/vas/vasypd/.vasypd.pid` | grep .vasypd',
          'before'  => 'Service[vasypd]',
          'notify'  => 'Service[vasypd]',
        )
      }

      it {
        is_expected.to contain_service('vasd').with(
          'ensure'  => 'running',
          'enable'  => 'true',
          'require' => 'Exec[vasinst]',
        )
      }

      it {
        is_expected.to contain_service('vasypd').with(
          'ensure'  => 'running',
          'enable'  => 'true',
          'require' => 'Service[vasd]',
          'before'  => 'Class[Nisclient]',
        )
      }

      it {
        is_expected.to contain_exec('vasinst').with(
          # rubocop:disable Layout/LineLength
          'command' => '/opt/quest/bin/vastool -u username -k /etc/vasinst.key -d3 join -f  -c ou=computers,dc=domain,dc=tld    -n foo.example.com  realm.example.com  > /var/tmp/vasjoin.log 2>&1 && touch /etc/opt/quest/vas/puppet_joined',
          # rubocop:enable Layout/LineLength
          'path'    => '/sbin:/bin:/usr/bin:/opt/quest/bin',
          'timeout' => 1800,
          'creates' => '/etc/opt/quest/vas/puppet_joined',
          'before'  => 'Class[Pam]',
          'require' => [
            'Package[vasclnt]',
            'Package[vasgp]',
            'File[keytab]',
            'Package[vasyp]',
          ],
        )
      }

      it {
        is_expected.not_to contain_file('vastool_symlink')
      }

      describe 'with fact vas_version missing' do
        vas_version_missing = { vas_version: nil }
        let(:facts) do
          os_facts.merge(
            vas_version_missing,
          )
        end

        it { is_expected.to compile }
      end

      describe 'with users.{allow,deny} configured' do
        context 'with API enabled' do
          api_enabled = { 'api_enable': true }
          let(:params) do
            api_enabled
          end

          it {
            is_expected.to compile.and_raise_error(%r{vas::api_enable is set to true but required parameters vas::api_users_allow_url and/or vas::api_token missing})
          }

          context 'param "api_users_allow_url" set' do
            let(:params) do
              api_enabled.merge(
                'api_users_allow_url': 'https://host.domain.tld',
              )
            end

            it {
              is_expected.to compile.and_raise_error(%r{vas::api_enable is set to true but required parameters vas::api_users_allow_url and/or vas::api_token missing})
            }
          end

          context 'param "api_token" set' do
            let(:params) do
              api_enabled.merge(
                'api_token': 'mytoken',
              )
            end

            it {
              is_expected.to compile.and_raise_error(%r{vas::api_enable is set to true but required parameters vas::api_users_allow_url and/or vas::api_token missing})
            }
          end

          context 'with required parameters' do
            let(:params) do
              api_enabled.merge(
                'api_users_allow_url': 'https://host.domain.tld',
                'api_token': 'mytoken',
              )
            end

            context 'and returns 200' do
              context 'without data' do
                let(:pre_condition) do
                  'function api_fetch($api_users_allow_url, $api_token) { return [200, undef] }'
                end

                users_allow_api_nodata_content = <<-END.gsub(%r{^\s+\|}, '')
                  |# This file is being maintained by Puppet.
                  |# DO NOT EDIT
                  |
                END

                it {
                  is_expected.to contain_file('vas_users_allow').with_content(users_allow_api_nodata_content)
                }

                context 'and users_allow parameter specified' do
                  let(:params) do
                    api_enabled.merge(
                      'api_users_allow_url': 'https://host.domain.tld',
                      'api_token': 'mytoken',
                      'users_allow_entries': ['user1@example.com', 'user2@example.com'],
                    )
                  end

                  users_allow_api_nodata_param_content = <<-END.gsub(%r{^\s+\|}, '')
                    |# This file is being maintained by Puppet.
                    |# DO NOT EDIT
                    |user1@example.com
                    |user2@example.com
                    |
                  END

                  it {
                    is_expected.to contain_file('vas_users_allow').with_content(users_allow_api_nodata_param_content)
                  }
                end
              end

              context 'with data' do
                let(:pre_condition) do
                  'function api_fetch($api_users_allow_url, $api_token) { return [200, \'apiuser@example.com\'] }'
                end

                users_allow_api_data_content = <<-END.gsub(%r{^\s+\|}, '')
                  |# This file is being maintained by Puppet.
                  |# DO NOT EDIT
                  |apiuser@example.com
                END

                it {
                  is_expected.to contain_file('vas_users_allow').with_content(users_allow_api_data_content)
                }

                context 'and users_allow parameter specified' do
                  let(:params) do
                    api_enabled.merge(
                      'api_users_allow_url': 'https://host.domain.tld',
                      'api_token': 'mytoken',
                      'users_allow_entries': ['user1@example.com', 'user2@example.com'],
                    )
                  end

                  users_allow_api_data_param_content = <<-END.gsub(%r{^\s+\|}, '')
                    |# This file is being maintained by Puppet.
                    |# DO NOT EDIT
                    |user1@example.com
                    |user2@example.com
                    |apiuser@example.com
                  END

                  it {
                    is_expected.to contain_file('vas_users_allow').with_content(users_allow_api_data_param_content)
                  }
                end
              end
            end

            context 'and return non-200 code' do
              let(:pre_condition) do
                'function api_fetch($api_users_allow_url, $api_token) { return [0, undef] }'
              end

              it {
                is_expected.not_to contain_file('vas_users_allow')
              }
            end
          end
        end

        context 'with file attribute changes' do
          let(:params) do
            required_params.merge(
              vas_users_allow_path: '/path/to/users_allow',
              vas_users_allow_owner: 'uallowo',
              vas_users_allow_group: 'uallowg',
              vas_users_allow_mode: '0600',
              vas_users_deny_path: '/path/to/users_deny',
              vas_users_deny_owner: 'gallowo',
              vas_users_deny_group: 'gallowg',
              vas_users_deny_mode: '0400',
            )
          end

          it {
            is_expected.to contain_file('vas_users_allow').with(
              'owner' => 'uallowo',
              'group' => 'uallowg',
              'mode'  => '0600',
            )
          }

          it {
            is_expected.to contain_file('vas_config').with_content(%r{ users-allow-file = /path/to/users_allow})
          }

          it {
            is_expected.to contain_file('vas_users_deny').with(
              'owner' => 'gallowo',
              'group' => 'gallowg',
              'mode'  => '0400',
            )
          }

          it {
            is_expected.to contain_file('vas_config').with_content(%r{ users-deny-file = /path/to/users_deny})
          }
        end
      end

      describe 'with users/group override configured' do
        context 'with file attribute changes' do
          let(:params) do
            required_params.merge(
              {
                vas_user_override_path: '/path/to/user_override',
                vas_user_override_owner: 'uoverrideo',
                vas_user_override_group: 'uoverrideg',
                vas_user_override_mode: '0600',
                vas_group_override_path: '/path/to/group_override',
                vas_group_override_owner: 'goverrideo',
                vas_group_override_group: 'goverrideg',
                vas_group_override_mode: '0400',
              },
            )
          end

          it {
            is_expected.to contain_file('vas_user_override').with(
              'owner' => 'uoverrideo',
              'group' => 'uoverrideg',
              'mode'  => '0600',
            )
          }

          it {
            is_expected.to contain_file('vas_config').with_content(%r{ user-override-file = /path/to/user_override})
          }

          it {
            is_expected.to contain_file('vas_group_override').with(
              'owner' => 'goverrideo',
              'group' => 'goverrideg',
              'mode'  => '0400',
            )
          }

          it {
            is_expected.to contain_file('vas_config').with_content(%r{ group-override-file = /path/to/group_override})
          }
        end
      end

      describe 'with keytab changes' do
        let(:params) do
          required_params.merge(
            keytab_path: '/etc/vas.key',
            keytab_source: 'puppet:///files/vas/vas.key',
            keytab_owner: 'keytabuser',
            keytab_group: 'keytabgroup',
            keytab_mode: '0440',
          )
        end

        it {
          is_expected.to contain_file('keytab').with(
            'ensure' => 'file',
            'path'   => '/etc/vas.key',
            'source' => 'puppet:///files/vas/vas.key',
            'owner'  => 'keytabuser',
            'group'  => 'keytabgroup',
            'mode'   => '0440',
          )
        }

        it {
          is_expected.to contain_exec('vasinst').with_command(%r{ -k /etc/vas.key })
        }
      end

      describe 'with join logic' do
        context 'with changes to join arguments' do
          let(:facts) do
            os_facts.merge(
              lsbmajdistrelease: os_facts[:os]['release']['major'], # Satisfy nisclient
              vas_domain: 'realm2.example.com',
            )
          end

          let(:params) do
            required_params.merge(
              {
                vastool_binary: '/opt/bin/vastool',
                username: 'joinuser',
                computers_ou: 'ou=mycomputers,dc=example,dc=com',
                user_search_path: 'OU=unix,DC=example,DC=com;OU=unix,DC=sub,DC=example,DC=com',
                group_search_path: 'OU=unix,DC=example,DC=com;OU=unix,DC=sub,DC=example,DC=com',
                sitenameoverride: 'foobar',
                realm: 'realm2.example.com',
                join_domain_controllers: ['dc1.example.com', 'dc2.example.com'],
              },
            )
          end

          it {
            # rubocop:disable Layout/LineLength
            is_expected.to contain_exec('vasinst').with_command('/opt/bin/vastool -u joinuser -k /etc/vasinst.key -d3 join -f  -c ou=mycomputers,dc=example,dc=com -u OU=unix,DC=example,DC=com;OU=unix,DC=sub,DC=example,DC=com -g OU=unix,DC=example,DC=com;OU=unix,DC=sub,DC=example,DC=com  -n foo.example.com -s foobar realm2.example.com dc1.example.com dc2.example.com > /var/tmp/vasjoin.log 2>&1 && touch /etc/opt/quest/vas/puppet_joined')
            # rubocop:enable Layout/LineLength
          }
        end

        context 'with UPM configuration' do
          let(:params) do
            required_params.merge(
              upm_search_path: 'OU=UPM,DC=example,DC=com',
              computers_ou: 'OU=Computers,DC=example,DC=com',
            )
          end

          it { is_expected.to contain_file('vas_config').with_content(%r{^\s*upm-search-path = OU=UPM,DC=example,DC=com$}) }
          it { is_expected.not_to contain_file('vas_config').with_content(%r{^\s*user-search-path}) }
          it { is_expected.not_to contain_file('vas_config').with_content(%r{^\s*group-search-path}) }

          it { is_expected.to contain_exec('vasinst').with_command(%r{-p OU=UPM,DC=example,DC=com}) }
          it { is_expected.to contain_exec('vasinst').with_command(%r{-c OU=Computers,DC=example,DC=com}) }
          it { is_expected.to contain_exec('vasinst').with_command(%r{-n foo.example.com}) }
        end
      end

      describe 'with unjoin_vas set to true' do
        let(:params) do
          required_params.merge(
            {
              unjoin_vas: true,
            },
          )
        end

        it {
          is_expected.to contain_exec('vas_unjoin').with(
            'command'  => "$(sed 's/\\(.*\\)join.*/\\1unjoin/' /etc/opt/quest/vas/lastjoin) > /tmp/vas_unjoin.txt 2>&1 && rm -f /etc/opt/quest/vas/puppet_joined",
            'onlyif'   => '/usr/bin/test -f /etc/vasinst.key && /usr/bin/test -f /etc/opt/quest/vas/lastjoin',
            'provider' => 'shell',
            'path'     => '/bin:/usr/bin:/opt/quest/bin',
            'timeout'  => 1800,
            'require'  => [
              'Package[vasclnt]',
              'Package[vasgp]',
              'Package[vasyp]',
            ],
          )
        }

        it { is_expected.not_to contain_exec('vas_change_domain') }
        it { is_expected.not_to contain_exec('vasinst') }
      end

      describe 'with parameters for vas.conf' do
        context 'with all (most) parameters' do
          let(:facts) do
            os_facts.merge(
              lsbmajdistrelease: os_facts[:os]['release']['major'], # Satisfy nisclient
              vas_domain: 'realm2.example.com',
            )
          end

          let(:params) do
            required_params.merge(
              {
                vas_fqdn: 'host2.example.com',
                computers_ou: 'ou=site,ou=computers,dc=example,dc=com',
                users_ou: 'ou=site,ou=users,dc=example,dc=com',
                nismaps_ou: 'ou=site,ou=nismaps,dc=example,dc=com',
                user_search_path: 'OU=unix,DC=example,DC=com; OU=unix,DC=sub,DC=example,DC=com',
                group_search_path: 'OU=unix,DC=example,DC=com; OU=unix,DC=sub,DC=example,DC=com',
                nisdomainname: 'nis.domain',
                realm: 'realm2.example.com',
                sitenameoverride: 'foobar',
                vas_conf_client_addrs: '10.10.0.0/24 10.50.0.0/24',
                vas_conf_vasypd_update_interval: 2200,
                vas_conf_full_update_interval: 3600,
                vas_conf_group_update_mode: 'none',
                vas_conf_root_update_mode: 'none',
                vas_conf_disabled_user_pwhash: 'disabled',
                vas_conf_expired_account_pwhash: 'expired',
                vas_conf_locked_out_pwhash: 'locked',
                vas_conf_preload_nested_memberships: false,
                vas_conf_update_process: '/opt/quest/libexec/vas/mapupdate',
                vas_conf_upm_computerou_attr: 'managedBy',
                vas_conf_vasd_update_interval: 1200,
                vas_conf_vasd_auto_ticket_renew_interval: 540,
                vas_conf_vasd_lazy_cache_update_interval: 20,
                vas_conf_vasd_timesync_interval: 0,
                vas_conf_vasd_cross_domain_user_groups_member_search: true,
                vas_conf_vasd_password_change_script: '/opt/quest/libexec/vas-set-samba-password',
                vas_conf_vasd_password_change_script_timelimit: 30,
                vas_conf_vasd_workstation_mode: true,
                vas_conf_vasd_workstation_mode_users_preload: 'usergroup',
                vas_conf_vasd_workstation_mode_group_do_member: true,
                vas_conf_vasd_workstation_mode_groups_skip_update: true,
                vas_conf_vasd_ws_resolve_uid: true,
                vas_conf_vasd_deluser_check_timelimit: 60,
                vas_conf_vasd_delusercheck_interval: 1440,
                vas_conf_vasd_delusercheck_script: '/opt/quest/libexec/vas/vasd/delusercheck2',
                vas_conf_vasd_username_attr_name: 'userprincipalname',
                vas_conf_vasd_groupname_attr_name: 'groupprincipalname',
                vas_conf_vasd_uid_number_attr_name: 'employeID',
                vas_conf_vasd_gid_number_attr_name: 'primaryGroupID',
                vas_conf_vasd_gecos_attr_name: 'displayName',
                vas_conf_vasd_home_dir_attr_name: 'homeDirectory',
                vas_conf_vasd_login_shell_attr_name: 'loginShell',
                vas_conf_vasd_group_member_attr_name: 'groupMembershipSAM',
                vas_conf_vasd_memberof_attr_name: 'memberOf',
                vas_conf_vasd_unix_password_attr_name: 'userPassword',
                vas_conf_vasd_netgroup_mode: 'NIS',
                vas_conf_prompt_vas_ad_pw: 'Enter pw',
                vas_conf_pam_vas_prompt_ad_lockout_msg: 'Account is locked',
                vas_conf_libdefaults_forwardable: false,
                vas_conf_libdefaults_tgs_default_enctypes: 'arcfour-hmac-md5',
                vas_conf_libdefaults_tkt_default_enctypes: 'arcfour-hmac-md5',
                vas_conf_libdefaults_default_etypes: 'arcfour-hmac-md5',
                vas_conf_libdefaults_default_cc_name: 'FILE:/dev/null/krb5cc_${uid}',
                vas_conf_vas_auth_uid_check_limit: 100_000,
                vas_conf_vas_auth_allow_disconnected_auth: false,
                vas_conf_vas_auth_expand_ac_groups: false,
                vas_conf_libvas_vascache_ipc_timeout: 10,
                vas_conf_libvas_use_server_referrals: true,
                vas_conf_libvas_auth_helper_timeout: 120,
                vas_conf_libvas_mscldap_timeout: 10,
                vas_conf_libvas_site_only_servers: false,
                vas_conf_libvas_use_dns_srv: false,
                vas_conf_libvas_use_tcp_only: false,
                vas_conf_lowercase_names: true,
                vas_conf_lowercase_homedirs: true,
                vas_config_path: '/etc/opt/quest/vas2.conf',
                vas_config_owner: 'vasuser',
                vas_config_group: 'vasgroup',
                vas_config_mode: '0664',
                use_srv_infocache: false,
                domain_realms: { 'fqdn.example.se' => 'example.se' },
                kdcs: ['kdc1.example.com', 'kdc2.example.com'],
                kdc_port: 1234,
                kpasswd_servers: ['kpasswd1.example.com', 'kpasswd2.example.com'],
                kpasswd_server_port: 4321,
              },
            )
          end

          vasconf_content = <<-END.gsub(%r{^\s+\|}, '')
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
            | vascache-ipc-timeout = 10
            | use-server-referrals = true
            | site-name-override = foobar
            | mscldap-timeout = 10
            | use-dns-srv = false
            | use-tcp-only = false
            | auth-helper-timeout = 120
            | site-only-servers = false
            | use-srvinfo-cache = false
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
            | user-search-path = OU=unix,DC=example,DC=com; OU=unix,DC=sub,DC=example,DC=com
            | group-search-path = OU=unix,DC=example,DC=com; OU=unix,DC=sub,DC=example,DC=com
            | user-override-file = /etc/opt/quest/vas/user-override
            | group-override-file = /etc/opt/quest/vas/group-override
            | auto-ticket-renew-interval = 540
            | lazy-cache-update-interval = 20
            | cross-domain-user-groups-member-search = true
            | timesync-interval = 0
            | preload-nested-memberships = false
            | upm-computerou-attr = managedBy
            | password-change-script = /opt/quest/libexec/vas-set-samba-password
            | password-change-script-timelimit = 30
            | deluser-check-timelimit = 60
            | delusercheck-interval = 1440
            | delusercheck-script = /opt/quest/libexec/vas/vasd/delusercheck2
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
            | users-allow-file = /etc/opt/quest/vas/users.allow
            | users-deny-file = /etc/opt/quest/vas/users.deny
            | uid-check-limit = 100000
            | allow-disconnected-auth = false
            | expand-ac-groups = false
            |
            |[realms]
            | REALM2.EXAMPLE.COM = {
            |  kdc = kdc1.example.com:1234 kdc2.example.com:1234
            |  kpasswd_server = kpasswd1.example.com:4321 kpasswd2.example.com:4321
            | }
          END

          it {
            is_expected.to contain_file('vas_config').with(
              'ensure'  => 'file',
              'path'    => '/etc/opt/quest/vas2.conf',
              'owner'   => 'vasuser',
              'group'   => 'vasgroup',
              'mode'    => '0664',
              'content' => vasconf_content,
            )
          }
        end

        context 'with use_server_referrals enabled by vas version' do
          let(:params) do
            { vas_conf_libvas_use_server_referrals: '' }
          end

          it {
            is_expected.to contain_file('vas_config').with_content(%r{use-server-referrals = false})
          }
        end

        context 'with use_server_referrals disabled by vas version' do
          let(:facts) do
            os_facts.merge(
              lsbmajdistrelease: os_facts[:os]['release']['major'], # Satisfy nisclient
              vas_version: '4.1.0.21517',
            )
          end

          let(:params) do
            { vas_conf_libvas_use_server_referrals: '' }
          end

          it {
            is_expected.to contain_file('vas_config').with_content(%r{use-server-referrals = true})
          }
        end

        context 'with vas_conf_lowercase_homedirs set to invalid non-boolean string' do
          let(:params) do
            { vas_conf_lowercase_homedirs: 'invalid' }
          end

          it 'fails' do
            expect { is_expected.to contain_class('vas') }.to raise_error(Puppet::Error)
          end
        end

        context 'with vas_conf_lowercase_names set to invalid non-boolean string' do
          let(:params) do
            { vas_conf_lowercase_names: 'invalid' }
          end

          it 'fails' do
            expect { is_expected.to contain_class('vas') }.to raise_error(Puppet::Error)
          end
        end

        [true, false, :undef].each do |value|
          context "with use_srv_infocache set to valid #{value} (as #{value.class})" do
            let(:params) do
              {
                use_srv_infocache: value
              }
            end

            if value != :undef
              it { is_expected.to contain_file('vas_config').with_content(%r{^ use-srvinfo-cache = #{value}$}) }
            else
              it { is_expected.to contain_file('vas_config').without_content(%r{use-srvinfo-cache}) }
            end
          end
        end
      end

      describe 'with licensefiles' do
        let(:params) do
          {
            license_files: {
              'VAS_license' => {
                'content' => 'VAS license file contents',
              }
            }
          }
        end

        it {
          is_expected.to contain_file('VAS_license').with(
            'ensure'  => 'file',
            'path'    => '/etc/opt/quest/vas/.licenses/VAS_license',
            'content' => 'VAS license file contents',
          )
        }

        context 'with custom parameters' do
          let(:params) do
            {
              license_files: {
                'VAS_license' => {
                  'ensure'  => 'file',
                  'path'    => '/tmp/vas_license',
                  'content' => 'VAS license file',
                }
              }
            }
          end

          it {
            is_expected.to contain_file('VAS_license').with(
              'ensure'  => 'file',
              'path'    => '/tmp/vas_license',
              'content' => 'VAS license file',
            )
          }
        end
      end

      describe 'with VAS version 3.x' do
        let(:facts) do
          os_facts.merge(
            lsbmajdistrelease: os_facts[:os]['release']['major'],
            vas_version: '3.1.2',
          )
        end

        it {
          is_expected.to contain_service('vasgpd').with(
            'ensure'    => 'running',
            'enable'    => true,
            'subscribe' => 'Exec[vasinst]',
          )
        }
      end
    end
  end

  describe 'on unsupported osfamily' do
    let(:facts) do
      {
        os: { family: 'unsupported' },
      }
    end

    it 'fails' do
      expect { is_expected.to contain_class('vas') }.to raise_error(Puppet::Error, %r{Vas supports Debian, Suse, and RedHat})
    end
  end
end
