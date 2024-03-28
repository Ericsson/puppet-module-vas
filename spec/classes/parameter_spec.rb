require 'spec_helper'

describe 'vas' do
  header = <<-END.gsub(%r{^\s+\|}, '')
    |# This file is being maintained by Puppet.
    |# DO NOT EDIT
  END

  test_on = {
    supported_os: [
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['8'],
      },
    ],
  }

  required_params = {
    keytab_source: 'puppet:///files/vas/vasinit.key',
    computers_ou: 'ou=computers,dc=domain,dc=tld',
  }

  on_supported_os(test_on).each do |_os, os_facts|
    describe 'parameter testing' do
      let(:node) { 'foo.example.com' }
      let(:facts) do
        os_facts.merge(
          lsbmajdistrelease: os_facts[:os]['release']['major'], # Satisfy nisclient
        )
      end

      [true, false].each do |value|
        describe "with manage_nis set to valid #{value}" do
          let(:params) do
            required_params.merge(
              manage_nis: value,
            )
          end

          content_nis = <<-END.gsub(%r{^\s+\|}, '')
            |[vasypd]
            | search-base = ou=nismaps,dc=example,dc=com
            | split-groups = true
            | update-interval = 1800
            | domainname-override = example.com
            | update-process = /opt/quest/libexec/vas/mapupdate_2307
          END
          content_nis_regex = Regexp.escape(content_nis)

          case value
          when true
            package_require = ['Package[vasclnt]', 'Package[vasgp]', 'Package[vasyp]']
            service_require = ['Service[vasd]', 'Service[vasypd]']

            it { is_expected.to contain_class('nisclient') }
            it { is_expected.to contain_package('vasyp') }
            it { is_expected.to contain_exec('Process check Vasypd') }
            it { is_expected.to contain_service('vasypd') }
            it { is_expected.to contain_file('vas_config').with_content(%r{#{content_nis_regex}}) }
          else
            package_require = ['Package[vasclnt]', 'Package[vasgp]']
            service_require = ['Service[vasd]']

            it { is_expected.not_to contain_class('nisclient') }
            it { is_expected.not_to contain_package('vasyp') }
            it { is_expected.not_to contain_exec('Process check Vasypd') }
            it { is_expected.not_to contain_service('vasypd') }
            it { is_expected.to contain_file('vas_config').without_content(%r{#{content_nis_regex}}) }
          end

          it { is_expected.to contain_file('vas_config').with_require(package_require) }
          it { is_expected.to contain_file('vas_users_allow').that_requires(package_require) }
          it { is_expected.to contain_file('vas_users_deny').that_requires(package_require) }

          it do
            is_expected.to contain_file('vas_user_override').with(
              'require' => package_require,
              'before' =>  service_require,
            )
          end

          it do
            is_expected.to contain_file('vas_group_override').with(
              'require' => package_require,
              'before' =>  service_require,
            )
          end
        end
      end

      [true, false].each do |value|
        describe "with manage_nsswitch set to valid #{value}" do
          let(:params) do
            required_params.merge(
              manage_nsswitch: value,
              # Class PAM includes nsswitch as well, disable it for test
              manage_pam: value,
            )
          end

          case value
          when true
            it { is_expected.to contain_class('nsswitch') }
          else
            it { is_expected.not_to contain_class('nsswitch') }
          end
        end
      end

      [true, false].each do |value|
        describe "with manage_pam set to valid #{value}" do
          let(:params) do
            required_params.merge(
              manage_pam: value,
            )
          end

          case value
          when true
            it { is_expected.to contain_class('pam') }
            it { is_expected.to contain_exec('vasinst').with_before('Class[Pam]') }
          else
            it { is_expected.not_to contain_class('pam') }
            it { is_expected.not_to contain_exec('vasinst').with_before('Class[Pam]') }
          end
        end
      end

      describe 'with manage_nis set to valid true and nisdomainname is defined' do
        let(:params) do
          required_params.merge(
            manage_nis: true,
            nisdomainname: 'test.ing',
          )
        end

        it { is_expected.to contain_file('vas_config').with_content(%r{domainname-override = test.ing}) }
      end

      [true, false].each do |value|
        describe "with enable_group_policies set to valid #{value}" do
          let(:params) do
            required_params.merge(
              enable_group_policies: value,
            )
          end

          result = if value == true
                     'installed'
                   else
                     'absent'
                   end

          it { is_expected.to contain_package('vasgp').with('ensure' => result) }
        end
      end

      [true, false].each do |domain_change|
        describe "with domain_change set to valid #{domain_change}" do
          ['mismatch.ing', 'realm.example.com'].each do |realm|
            context "when domain is #{realm}" do
              let(:params) do
                required_params.merge(
                  domain_change: domain_change,
                  realm: realm,
                )
              end

              case realm
              when 'mismatch.ing'
                if domain_change == true
                  it do
                    is_expected.to contain_exec('vas_change_domain').only_with(
                      'command'  => "$(sed 's/\\(.*\\)join.*/\\1unjoin/' /etc/opt/quest/vas/lastjoin) > /tmp/vas_unjoin.txt 2>&1 && rm -f /etc/opt/quest/vas/puppet_joined",
                      'onlyif'   => '/usr/bin/test -f /etc/vasinst.key && /usr/bin/test -f /etc/opt/quest/vas/lastjoin',
                      'provider' => 'shell',
                      'path'     => '/bin:/usr/bin:/opt/quest/bin',
                      'timeout'  => 1800,
                      'before'   => ['File[vas_config]', 'File[keytab]', 'Exec[vasinst]'],
                      'require'  => ['Package[vasclnt]', 'Package[vasgp]', 'Package[vasyp]'],
                    )
                  end

                else
                  it 'fails' do
                    expect { is_expected.to contain_class('vas') }.to raise_error(Puppet::Error, %r{VAS domain mismatch})
                  end
                end

              when 'realm.example.com'
                it { is_expected.to compile.with_all_deps }
                it { is_expected.not_to contain_exec('vas_change_domain') }
              end
            end
          end
        end
      end

      [true, false].each do |value|
        context "with vas_conf_vasd_workstation_mode set to valid #{value}" do
          let(:params) { { vas_conf_vasd_workstation_mode: value } }

          command = if value == true
                      '-w'
                    else
                      ''
                    end

          it { is_expected.to contain_exec('vasinst').with_command(%r{join -f #{command} -c}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_vasd_workstation_mode_group_do_member set to valid #{value}" do
          let(:params) { { vas_conf_vasd_workstation_mode_group_do_member: value } }

          it { is_expected.to contain_file('vas_config').without_content(%r{workstation-mode-group-do-member}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_vasd_workstation_mode_group_do_member set to valid #{value} when vas_conf_vasd_workstation_mode is true" do
          let(:params) do
            {
              vas_conf_vasd_workstation_mode_group_do_member: value,
              vas_conf_vasd_workstation_mode: true,
            }
          end

          it { is_expected.to contain_file('vas_config').with_content(%r{ workstation-mode-group-do-member = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_vasd_workstation_mode_groups_skip_update set to valid #{value}" do
          let(:params) { { vas_conf_vasd_workstation_mode_groups_skip_update: value } }

          it { is_expected.to contain_file('vas_config').without_content(%r{workstation-mode-groups-skip-update}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_vasd_workstation_mode_groups_skip_update set to valid #{value} when vas_conf_vasd_workstation_mode is true" do
          let(:params) do
            {
              vas_conf_vasd_workstation_mode_groups_skip_update: value,
              vas_conf_vasd_workstation_mode: true,
            }
          end

          it { is_expected.to contain_file('vas_config').with_content(%r{ workstation-mode-groups-skip-update = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_vasd_ws_resolve_uid set to valid #{value}" do
          let(:params) { { vas_conf_vasd_ws_resolve_uid: value } }

          it { is_expected.to contain_file('vas_config').without_content(%r{ws-resolve-uid}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_vasd_ws_resolve_uid set to valid #{value} when vas_conf_vasd_workstation_mode is true" do
          let(:params) do
            {
              vas_conf_vasd_ws_resolve_uid: value,
              vas_conf_vasd_workstation_mode: true,
            }
          end

          it { is_expected.to contain_file('vas_config').with_content(%r{ ws-resolve-uid = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_libdefaults_forwardable set to valid #{value}" do
          let(:params) { { vas_conf_libdefaults_forwardable: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ forwardable = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_libvas_site_only_servers set to valid #{value}" do
          let(:params) { { vas_conf_libvas_site_only_servers: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{site-only-servers}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_libvas_site_only_servers set to valid #{value} when vas_conf_vasd_workstation_mode is true" do
          let(:params) do
            {
              vas_conf_libvas_site_only_servers: value,
              vas_conf_vasd_workstation_mode: true,
            }
          end

          it { is_expected.to contain_file('vas_config').with_content(%r{ site-only-servers = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_libvas_use_dns_srv set to valid #{value}" do
          let(:params) { { vas_conf_libvas_use_dns_srv: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ use-dns-srv = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_libvas_use_tcp_only set to valid #{value}" do
          let(:params) { { vas_conf_libvas_use_tcp_only: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ use-tcp-only = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with symlink_vastool_binary set to valid #{value}" do
          let(:params) { { symlink_vastool_binary: value } }

          if value == true
            it do
              is_expected.to contain_file('vastool_symlink').only_with(
                'ensure' => 'link',
                'path'   => '/usr/bin/vastool',
                'target' => '/opt/quest/bin/vastool',
              )
            end
          else
            it { is_expected.not_to contain_file('vastool_symlink') }
          end
        end
      end

      [true, false].each do |value|
        context "with unjoin_vas set to valid #{value} when realm is set to matching domain" do
          let(:params) do
            {
              unjoin_vas: value,
              realm: 'realm.example.com',
            }
          end

          if value == true
            it do
              is_expected.to contain_exec('vas_unjoin').only_with(
                'command'  => "$(sed 's/\\(.*\\)join.*/\\1unjoin/' /etc/opt/quest/vas/lastjoin) > /tmp/vas_unjoin.txt 2>&1 && rm -f /etc/opt/quest/vas/puppet_joined",
                'onlyif'   => '/usr/bin/test -f /etc/vasinst.key && /usr/bin/test -f /etc/opt/quest/vas/lastjoin',
                'provider' => 'shell',
                'path'     => '/bin:/usr/bin:/opt/quest/bin',
                'timeout'  => 1800,
                'require'  => ['Package[vasclnt]', 'Package[vasgp]', 'Package[vasyp]'],
              )
            end
          else
            it { is_expected.not_to contain_exec('vas_unjoin') }
            it { is_expected.not_to contain_exec('vas_change_domain') }
            it { is_expected.to contain_file('vas_config') }
            it { is_expected.to contain_file('vas_users_deny') }
            it { is_expected.to contain_file('vas_user_override') }
            it { is_expected.to contain_file('vas_group_override') }
            it { is_expected.to contain_file('keytab') }
            it { is_expected.to contain_service('vasd') }
            it { is_expected.to contain_exec('Process check Vasypd') }
            it { is_expected.to contain_service('vasypd') }
            it { is_expected.to contain_exec('vasinst') }
          end
        end
      end

      context 'with keytab_path set to valid /test/ing' do
        let(:params) { { keytab_path: '/test/ing' } }

        it { is_expected.to contain_file('keytab').with_path('/test/ing') }
        it { is_expected.to contain_exec('vasinst').with_command(%r{-k \/test\/ing}) }
      end

      context 'with keytab_path set to valid /test/ing when unjoin_vas is true' do
        let(:params) do
          {
            keytab_path: '/test/ing',
            unjoin_vas: true,
          }
        end

        it { is_expected.to contain_exec('vas_unjoin').with_onlyif(%r{-f \/test\/ing}) }
      end

      context 'with keytab_path set to valid /test/ing when realm is test.ing and domain_change is true' do
        let(:params) do
          {
            keytab_path: '/test/ing',
            realm: 'test.ing',
            domain_change: true,
          }
        end

        it { is_expected.to contain_exec('vas_change_domain').with_onlyif(%r{-f \/test\/ing}) }
      end

      context 'with vas_conf_update_process set to valid /test/ing' do
        let(:params) { { vas_conf_update_process: '/test/ing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ update-process = /test/ing}) }
      end

      context 'with vas_config_path set to valid /test/ing' do
        let(:params) { { vas_config_path: '/test/ing' } }

        it { is_expected.to contain_file('vas_config').with_path('/test/ing') }
      end

      context 'with vasjoin_logfile set to valid /test/ing' do
        let(:params) { { vasjoin_logfile: '/test/ing' } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{ > \/test\/ing 2>&1}) }
      end

      context 'with vastool_binary set to valid /test/ing' do
        let(:params) { { vastool_binary: '/test/ing' } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{^\/test\/ing }) }
      end

      context 'with vastool_binary set to valid /test/ing when symlink_vastool_binary is true' do
        let(:params) do
          {
            vastool_binary: '/test/ing',
            symlink_vastool_binary: true,
          }
        end

        it { is_expected.to contain_file('vastool_symlink').with_target('/test/ing') }
      end

      context 'with symlink_vastool_binary_target set to valid /test/ing when symlink_vastool_binary is true' do
        let(:params) do
          {
            symlink_vastool_binary_target: '/test/ing',
            symlink_vastool_binary: true,
          }
        end

        it { is_expected.to contain_file('vastool_symlink').with_path('/test/ing') }
      end

      context 'with username set to valid test' do
        let(:params) { { username: 'test' } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{ -u test }) }
      end

      context 'with keytab_owner set to valid test' do
        let(:params) { { keytab_owner: 'test' } }

        it { is_expected.to contain_file('keytab').with_owner('test') }
      end

      context 'with keytab_group set to valid test' do
        let(:params) { { keytab_group: 'test' } }

        it { is_expected.to contain_file('keytab').with_group('test') }
      end

      context 'with nismaps_ou set to valid test' do
        let(:params) { { nismaps_ou: 'test' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ search-base = test}) }
      end

      context 'with vas_conf_group_update_mode set to valid test' do
        let(:params) { { vas_conf_group_update_mode: 'test' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ group-update-mode = test}) }
      end

      context 'with vas_conf_root_update_mode set to valid test' do
        let(:params) { { vas_conf_root_update_mode: 'test' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ root-update-mode = test}) }
      end

      context 'with vas_conf_upm_computerou_attr set to valid test' do
        let(:params) { { vas_conf_upm_computerou_attr: 'test' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ upm-computerou-attr = test}) }
      end

      context 'with vas_conf_prompt_vas_ad_pw set to valid test' do
        let(:params) { { vas_conf_prompt_vas_ad_pw: 'test' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ prompt-vas-ad-pw = test}) }
      end

      context 'with vas_conf_libdefaults_tgs_default_enctypes set to valid test' do
        let(:params) { { vas_conf_libdefaults_tgs_default_enctypes: 'test' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ default_tgs_enctypes = test}) }
      end

      context 'with vas_conf_libdefaults_tkt_default_enctypes set to valid test' do
        let(:params) { { vas_conf_libdefaults_tkt_default_enctypes: 'test' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ default_tkt_enctypes = test}) }
      end

      context 'with vas_conf_libdefaults_default_etypes set to valid test' do
        let(:params) { { vas_conf_libdefaults_default_etypes: 'test' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ default_etypes = test}) }
      end

      context 'with vas_conf_libvas_use_server_referrals_version_switch set to valid 4.1.0.21519 when vas_conf_libvas_use_server_referrals is empty' do
        let(:params) do
          {
            vas_conf_libvas_use_server_referrals_version_switch: '4.1.0.21519',
            vas_conf_libvas_use_server_referrals: '',
          }
        end

        it { is_expected.to contain_file('vas_config').with_content(%r{ use-server-referrals = true}) }
      end

      context 'with vas_conf_libvas_use_server_referrals_version_switch set to valid 4.1.0.21518 when vas_conf_libvas_use_server_referrals is empty' do
        let(:params) do
          {
            vas_conf_libvas_use_server_referrals_version_switch: '4.1.0.21518',
            vas_conf_libvas_use_server_referrals: '',
          }
        end

        it { is_expected.to contain_file('vas_config').with_content(%r{ use-server-referrals = false}) }
      end

      context 'with vas_config_owner set to valid test' do
        let(:params) { { vas_config_owner: 'test' } }

        it { is_expected.to contain_file('vas_config').with_owner('test') }
      end

      context 'with vas_config_group set to valid test' do
        let(:params) { { vas_config_group: 'test' } }

        it { is_expected.to contain_file('vas_config').with_group('test') }
      end

      context 'with vas_user_override_owner set to valid test' do
        let(:params) { { vas_user_override_owner: 'test' } }

        it { is_expected.to contain_file('vas_user_override').with_owner('test') }
      end

      context 'with vas_user_override_group set to valid test' do
        let(:params) { { vas_user_override_group: 'test' } }

        it { is_expected.to contain_file('vas_user_override').with_group('test') }
      end

      context 'with vas_group_override_owner set to valid test' do
        let(:params) { { vas_group_override_owner: 'test' } }

        it { is_expected.to contain_file('vas_group_override').with_owner('test') }
      end

      context 'with vas_group_override_group set to valid test' do
        let(:params) { { vas_group_override_group: 'test' } }

        it { is_expected.to contain_file('vas_group_override').with_group('test') }
      end

      context 'with vas_users_allow_owner set to valid test' do
        let(:params) { { vas_users_allow_owner: 'test' } }

        it { is_expected.to contain_file('vas_users_allow').with_owner('test') }
      end

      context 'with vas_users_allow_group set to valid test' do
        let(:params) { { vas_users_allow_group: 'test' } }

        it { is_expected.to contain_file('vas_users_allow').with_group('test') }
      end

      context 'with vas_users_deny_owner set to valid test' do
        let(:params) { { vas_users_deny_owner: 'test' } }

        it { is_expected.to contain_file('vas_users_deny').with_owner('test') }
      end

      context 'with vas_users_deny_group set to valid test' do
        let(:params) { { vas_users_deny_group: 'test' } }

        it { is_expected.to contain_file('vas_users_deny').with_group('test') }
      end

      context 'with keytab_mode set to valid 0242' do
        let(:params) { { keytab_mode: '0242' } }

        it { is_expected.to contain_file('keytab').with_mode('0242') }
      end

      context 'with vas_config_mode set to valid 0242' do
        let(:params) { { vas_config_mode: '0242' } }

        it { is_expected.to contain_file('vas_config').with_mode('0242') }
      end

      context 'with vas_user_override_mode set to valid 0242' do
        let(:params) { { vas_user_override_mode: '0242' } }

        it { is_expected.to contain_file('vas_user_override').with_mode('0242') }
      end

      context 'with vas_group_override_mode set to valid 0242' do
        let(:params) { { vas_group_override_mode: '0242' } }

        it { is_expected.to contain_file('vas_group_override').with_mode('0242') }
      end

      context 'with vas_users_allow_mode set to valid 0242' do
        let(:params) { { vas_users_allow_mode: '0242' } }

        it { is_expected.to contain_file('vas_users_allow').with_mode('0242') }
      end

      context 'with vas_users_deny_mode set to valid 0242' do
        let(:params) { { vas_users_deny_mode: '0242' } }

        it { is_expected.to contain_file('vas_users_deny').with_mode('0242') }
      end

      context 'with kdc_port set to valid 242' do
        let(:params) { { kdc_port: 242 } }

        it { is_expected.to contain_file('vas_config').without_content(%r{ kdc = }) }
      end

      context 'with kdc_port set to valid 242 when kdcs is set' do
        let(:params) do
          {
            kdc_port: 242,
            kdcs: ['test.ing']
          }
        end

        it { is_expected.to contain_file('vas_config').with_content(%r{ kdc = test.ing:242}) }
      end

      context 'with kpasswd_server_port set to valid 242' do
        let(:params) { { kpasswd_server_port: 242 } }

        it { is_expected.to contain_file('vas_config').without_content(%r{ kpasswd_server =}) }
      end

      context 'with kpasswd_server_port set to valid 242 when kdcs is set' do
        let(:params) do
          {
            kpasswd_server_port: 242,
            kdcs: ['test.ing']
          }
        end

        it { is_expected.to contain_file('vas_config').with_content(%r{ kpasswd_server = test.ing:242}) }
      end

      context 'with realm set to valid test.ing (different then ::vas_domain)' do
        let(:params) { { realm: 'test.ing' } }

        it 'fails' do
          expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{VAS domain mismatch})
        end
      end

      context 'with realm set to valid test.ing when domain_change is set to true' do
        let(:params) do
          {
            realm: 'test.ing',
            domain_change: true,
          }
        end

        it { is_expected.to contain_exec('vas_change_domain') }
        it { is_expected.to contain_exec('vasinst').with_command(%r{test.ing}) }
      end

      context 'with vas_fqdn set to valid test.ing' do
        let(:params) { { vas_fqdn: 'test.ing' } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{ -n test.ing }) }
        it { is_expected.to contain_file('vas_config').with_content(%r{ test.ing = REALM.EXAMPLE.COM}) }
      end

      context 'with vas_conf_vasypd_update_interval set to valid 242' do
        let(:params) { { vas_conf_vasypd_update_interval: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{\[vasypd\].* update-interval = 242.*\[vasd\]}m) }
      end

      context 'with vas_conf_vasd_update_interval set to valid 242' do
        let(:params) { { vas_conf_vasd_update_interval: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{\[vasd\].* update-interval = 242.*\[nss_vas\]}m) }
      end

      context 'with vas_conf_vasd_auto_ticket_renew_interval set to valid 242' do
        let(:params) { { vas_conf_vasd_auto_ticket_renew_interval: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ auto-ticket-renew-interval = 242}) }
      end

      context 'with vas_conf_vasd_lazy_cache_update_interval set to valid 242' do
        let(:params) { { vas_conf_vasd_lazy_cache_update_interval: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ lazy-cache-update-interval = 242}) }
      end

      context 'with vas_conf_libvas_vascache_ipc_timeout set to valid 242' do
        let(:params) { { vas_conf_libvas_vascache_ipc_timeout: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ vascache-ipc-timeout = 242}) }
      end

      context 'with vas_conf_libvas_auth_helper_timeout set to valid 242' do
        let(:params) { { vas_conf_libvas_auth_helper_timeout: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ auth-helper-timeout = 242}) }
      end

      context 'with vas_conf_libvas_mscldap_timeout set to valid 242' do
        let(:params) { { vas_conf_libvas_mscldap_timeout: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ mscldap-timeout = 242}) }
      end

      context 'with kdcs set to valid [test.ing test2.test.ing]' do
        let(:params) { { kdcs: ['kdc1.test.ing', 'kdc2.test.ing'] } }

        it { is_expected.to contain_file('vas_config').with_content(%r{\[realms\].*  kdc = kdc1.test.ing:88 kdc2.test.ing:88}m) }
      end

      context 'with kpasswd_servers set to valid [kpasswd1.test.ing, kpasswd2.test.ing]' do
        let(:params) { { kpasswd_servers: ['kpasswd1.test.ing', 'kpasswd2.test.ing'] } }

        it { is_expected.to contain_file('vas_config').without_content(%r{\[realms\].*  kpasswd_server}m) }
      end

      context 'with kpasswd_servers set to valid [kpasswd1.test.ing, kpasswd2.test.ing] when kdcs is set' do
        let(:params) do
          {
            kpasswd_servers: ['kpasswd1.test.ing', 'kpasswd2.test.ing'],
            kdcs:            ['test.ing'],
          }
        end

        it { is_expected.to contain_file('vas_config').with_content(%r{\[realms\].*  kpasswd_server = kpasswd1.test.ing:464 kpasswd2.test.ing:464}m) }
      end

      context 'with kpasswd_servers not set when kdcs is set to [test.ing test2.test.ing]' do
        let(:params) { { kdcs: ['kdc1.test.ing', 'kdc2.test.ing'] } }

        it { is_expected.to contain_file('vas_config').with_content(%r{\[realms\].*  kpasswd_server = kdc1.test.ing:464 kdc2.test.ing:464}m) }
      end

      context 'with domain_realms set to valid when kdcs is set to {domain.test.ing => test.ing}' do
        let(:params) { { domain_realms: { 'domain.test.ing' => 'test.ing' } } }

        it { is_expected.to contain_file('vas_config').with_content(%r{\[domain_realm]\n domain.test.ing = TEST.ING\n foo.example.com = REALM.EXAMPLE.COM}) }
      end

      context 'with domain_realms set to valid when kdcs is set to {domain1.test.ing => test1.ing, domain2.test.ing => test2.ing}' do
        let(:params) { { domain_realms: { 'domain1.test.ing' => 'test1.ing', 'domain2.test.ing' => 'test2.ing' } } }

        it { is_expected.to contain_file('vas_config').with_content(%r{\[domain_realm]\n domain1.test.ing = TEST1.ING\n domain2.test.ing = TEST2.ING\n foo.example.com = REALM.EXAMPLE.COM}) }
      end

      context 'with package_version set to valid 2.4.2' do
        let(:params) { { package_version: '2.4.2' } }

        it { is_expected.to contain_package('vasclnt').with('ensure' => '2.4.2') }
        it { is_expected.to contain_package('vasyp').with('ensure' => '2.4.2') }
        it { is_expected.to contain_package('vasgp').with('ensure' => '2.4.2') }
      end

      context 'with users_allow_entries set to valid [user1@test.ing, user2@test.ing]' do
        let(:params) { { users_allow_entries: ['user1@test.ing', 'user2@test.ing'] } }

        it { is_expected.to contain_file('vas_users_allow').with_content(header + "user1@test.ing\nuser2@test.ing\n") }
      end

      context 'with users_deny_entries set to valid [user1@test.ing, user2@test.ing]' do
        let(:params) { { users_deny_entries: ['user1@test.ing', 'user2@test.ing'] } }

        it { is_expected.to contain_file('vas_users_deny').with_content(header + "user1@test.ing\nuser2@test.ing\n") }
      end

      context 'with user_override_entries set to valid [user1@test.ing::::::/bin/sh, user2@test.ing::::::/bin/sh]' do
        let(:params) { { user_override_entries: ['user1@test.ing::::::/bin/sh', 'user2@test.ing::::::/bin/sh'] } }

        it { is_expected.to contain_file('vas_user_override').with_content(header + "user1@test.ing::::::/bin/sh\nuser2@test.ing::::::/bin/sh\n") }
      end

      context 'with group_override_entries set to valid [DOMAIN\adgroup:group1::, DOMAIN\adgroup:group2::]' do
        let(:params) { { group_override_entries: ['DOMAIN\adgroup:group1::', 'DOMAIN\adgroup:group2::'] } }

        it { is_expected.to contain_file('vas_group_override').with_content(header + "DOMAIN\\adgroup:group1::\nDOMAIN\\adgroup:group2::\n") }
      end

      context 'with keytab_source set to valid puppet:///test.ing' do
        let(:params) { { keytab_source: 'puppet:///test.ing' } }

        it { is_expected.to contain_file('keytab').with_source('puppet:///test.ing') }
      end

      context 'with nisdomainname set to valid test.ing' do
        let(:params) { { nisdomainname: 'test.ing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ domainname-override = test.ing}) }
      end

      context 'with nisdomainname unset when manage_nis is unset' do
        let(:params) { { manage_nis: :undef } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ domainname-override = example.com}) }
      end

      context 'with nisdomainname unset when manage_nis is unset but nisclient::domainname is set' do
        let(:pre_condition) do
          'class {"nisclient": domainname => "testing.nisclient" }'
        end
        let(:params) { { manage_nis: :undef } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ domainname-override = testing.nisclient}) }
      end

      context 'with vas_conf_disabled_user_pwhash set to valid testing' do
        let(:params) { { vas_conf_disabled_user_pwhash: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ disabled-user-pwhash = testing}) }
      end

      context 'with vas_conf_expired_account_pwhash set to valid testing' do
        let(:params) { { vas_conf_expired_account_pwhash: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ expired-account-pwhash = testing}) }
      end

      context 'with vas_conf_locked_out_pwhash set to valid testing' do
        let(:params) { { vas_conf_locked_out_pwhash: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ locked-out-pwhash = testing}) }
      end

      context 'with license_files set to valid hash' do
        let(:params) do
          {
            license_files: {
              'VAS_license' => {
                'content' => 'VAS license file contents',
              }
            }
          }
        end

        it do
          is_expected.to contain_file('VAS_license').only_with(
            'ensure'  => 'file',
            'path'    => '/etc/opt/quest/vas/.licenses/VAS_license',
            'content' => 'VAS license file contents',
            'require' => 'Package[vasclnt]',
          )
        end
      end

      context 'with license_files set to valid hash with multiple files' do
        let(:params) do
          {
            license_files: {
              'license1' => {
                'content' => 'content1',
                'path'    => '/test/ing/1',
              },
              'license2' => {
                'content' => 'content2',
                'path'    => '/test/ing/2',
              }
            }
          }
        end

        it do
          is_expected.to contain_file('license1').with(
            'content' => 'content1',
            'path'    => '/test/ing/1',
          )
        end

        it do
          is_expected.to contain_file('license2').with(
            'content' => 'content2',
            'path'    => '/test/ing/2',
          )
        end
      end

      context 'with license_files set to valid hash with custom parameters' do
        let(:params) do
          {
            license_files: {
              'VAS_license' => {
                'path'    => '/test/ing',
                'ensure'  => 'present',
                'content' => 'VAS license file contents',
              }
            }
          }
        end

        it do
          is_expected.to contain_file('VAS_license').only_with(
            'ensure'  => 'present',
            'path'    => '/test/ing',
            'content' => 'VAS license file contents',
            'require' => 'Package[vasclnt]',
          )
        end
      end

      context 'with api_users_allow_url set to valid https://test.ing' do
        let(:params) { { api_users_allow_url: 'https://test.ing' } }

        it { is_expected.to contain_file('vas_users_allow').with_content(header) }
      end

      context 'with api_users_allow_url set to valid https://test.ing when api_enable is true' do
        let(:params) do
          {
            api_users_allow_url: 'https://test.ing',
            api_enable:          true,
          }
        end

        it 'fails' do
          expect { is_expected.to contain_class('vas') }.to raise_error(Puppet::Error, %r{api_token missing})
        end
      end

      context 'with api_users_allow_url set to valid https://test.ing when api_enable is true and api_token is set and function_api() returns no data' do
        let(:params) do
          {
            api_users_allow_url: 'https://test.ing',
            api_enable:          true,
            api_token:           'testing',
          }
        end
        let(:pre_condition) do
          'function vas::api_fetch($api_users_allow_url, $api_token, $api_ssl_verify) { return [200, undef] }'
        end

        it do
          is_expected.to contain_file('vas_users_allow').with_content(header + "\n")
        end
      end

      context 'with api_users_allow_url set to valid https://test.ing when api_enable is true and api_token is set and function_api() returns data' do
        let(:params) do
          {
            api_users_allow_url: 'https://test.ing',
            api_enable:          true,
            api_token:           'testing',
          }
        end
        let(:pre_condition) do
          'function vas::api_fetch($api_users_allow_url, $api_token, $api_ssl_verify) { return [200, \'apiuser@test.ing\'] }'
        end

        it do
          is_expected.to contain_file('vas_users_allow').with_content(header + "apiuser@test.ing\n")
        end
      end

      context 'with api_users_allow_url set to valid https://test.ing when api_enable is true and api_token/users_allow_entries are set and function_api() returns no data' do
        let(:params) do
          {
            api_users_allow_url: 'https://test.ing',
            api_enable:          true,
            api_token:           'testing',
            users_allow_entries: ['user1@test.ing', 'user2@test.ing'],
          }
        end
        let(:pre_condition) do
          'function vas::api_fetch($api_users_allow_url, $api_token, $api_ssl_verify) { return [200, undef] }'
        end

        it do
          is_expected.to contain_file('vas_users_allow').with_content(header + "user1@test.ing\nuser2@test.ing\n\n")
        end
      end

      context 'with api_users_allow_url set to valid https://test.ing when api_enable is true and api_token/users_allow_entries are set and function_api() returns data' do
        let(:params) do
          {
            api_users_allow_url: 'https://test.ing',
            api_enable:          true,
            api_token:           'testing',
            users_allow_entries: ['user1@test.ing', 'user2@test.ing'],
          }
        end
        let(:pre_condition) do
          'function vas::api_fetch($api_users_allow_url, $api_token, $api_ssl_verify) { return [200, \'apiuser@test.ing\'] }'
        end

        it do
          is_expected.to contain_file('vas_users_allow').with_content(header + "user1@test.ing\nuser2@test.ing\napiuser@test.ing\n")
        end
      end

      context 'with api_token set to valid testing' do
        let(:params) { { api_token: 'testing' } }

        it { is_expected.to contain_file('vas_users_allow').with_content(header) }
      end

      context 'with api_token set to valid testing when api_enable is true' do
        let(:params) do
          {
            api_token:  'testing',
            api_enable: true,
          }
        end

        it 'fails' do
          expect { is_expected.to contain_class('vas') }.to raise_error(Puppet::Error, %r{api_users_allow_url .* missing})
        end
      end

      context 'with api_token set to valid testing when api_enable is true and api_users_allow_url is set and function_api() returns no data' do
        let(:params) do
          {
            api_token:           'testing',
            api_enable:          true,
            api_users_allow_url: 'https://test.ing',
          }
        end
        let(:pre_condition) do
          'function vas::api_fetch($api_users_allow_url, $api_token, $api_ssl_verify) { return [200, undef] }'
        end

        it do
          is_expected.to contain_file('vas_users_allow').with_content(header + "\n")
        end
      end

      context 'with api_token set to valid testing when api_enable is true and api_users_allow_url is set and function_api() returns data' do
        let(:params) do
          {
            api_token:           'testing',
            api_enable:          true,
            api_users_allow_url: 'https://test.ing',
          }
        end
        let(:pre_condition) do
          'function vas::api_fetch($api_users_allow_url, $api_token, $api_ssl_verify) { return [200, \'apiuser@test.ing\'] }'
        end

        it do
          is_expected.to contain_file('vas_users_allow').with_content(header + "apiuser@test.ing\n")
        end
      end

      context 'with computers_ou set to valid ou=computers,dc=test,dc=ing' do
        let(:params) { { computers_ou: 'ou=computers,dc=test,dc=ing' } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{-c ou=computers,dc=test,dc=ing}) }
      end

      context 'with users_ou set to valid ou=users,dc=test,dc=ing' do
        let(:params) { { users_ou: 'ou=users,dc=test,dc=ing' } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{-p ou=users,dc=test,dc=ing}) }
        it { is_expected.to contain_file('vas_config').with_content(%r{ upm-search-path = ou=users,dc=test,dc=ing}) }
      end

      context 'with users_ou set to valid ou=users,dc=test,dc=ing when upm_search_path is set' do
        let(:params) do
          {
            users_ou:        'ou=users,dc=test,dc=ing',
            upm_search_path: 'ou=UPM,dc=test,dc=ing',
          }
        end

        it { is_expected.to contain_exec('vasinst').with_command(%r{-p ou=UPM,dc=test,dc=ing}) }
        it { is_expected.to contain_file('vas_config').with_content(%r{ upm-search-path = ou=UPM,dc=test,dc=ing}) }
      end

      context 'with user_search_path set to valid ou=user_search,dc=test,dc=ing' do
        let(:params) { { user_search_path: 'ou=user_search,dc=test,dc=ing' } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{-u ou=user_search,dc=test,dc=ing}) }
        it { is_expected.to contain_file('vas_config').with_content(%r{ user-search-path = ou=user_search,dc=test,dc=ing}) }
      end

      context 'with group_search_path set to valid ou=user_search,dc=test,dc=ing' do
        let(:params) { { group_search_path: 'ou=group_search,dc=test,dc=ing' } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{-g ou=group_search,dc=test,dc=ing}) }
        it { is_expected.to contain_file('vas_config').with_content(%r{ group-search-path = ou=group_search,dc=test,dc=ing}) }
      end

      context 'with upm_search_path set to valid ou=user_search,dc=test,dc=ing' do
        let(:params) { { upm_search_path: 'ou=UPM,dc=test,dc=ing' } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{-p ou=UPM,dc=test,dc=ing}) }
        it { is_expected.to contain_file('vas_config').with_content(%r{ upm-search-path = ou=UPM,dc=test,dc=ing}) }
      end

      context 'with sitenameoverride set to valid ou=user_search,dc=test,dc=ing' do
        let(:params) { { sitenameoverride: 'testing' } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{-s testing}) }
        it { is_expected.to contain_file('vas_config').with_content(%r{ site-name-override = testing}) }
      end

      [true, false].each do |value|
        context "with vas_conf_preload_nested_memberships set to valid #{value}" do
          let(:params) { { vas_conf_preload_nested_memberships: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ preload-nested-memberships = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_vasd_cross_domain_user_groups_member_search set to valid #{value}" do
          let(:params) { { vas_conf_vasd_cross_domain_user_groups_member_search: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ cross-domain-user-groups-member-search = #{value}}) }
        end
      end

      context 'with vas_conf_vasd_workstation_mode_users_preload set to valid testing' do
        let(:params) { { vas_conf_vasd_workstation_mode_users_preload: 'testing' } }

        it { is_expected.to contain_file('vas_config').without_content(%r{ workstation-mode-users-preload =}) }
      end

      context 'with vas_conf_vasd_workstation_mode_users_preload set to valid testing when vas_conf_vasd_workstation_mode is true' do
        let(:params) do
          {
            vas_conf_vasd_workstation_mode_users_preload: 'testing',
            vas_conf_vasd_workstation_mode:               true,
          }
        end

        it { is_expected.to contain_file('vas_config').with_content(%r{ workstation-mode-users-preload = testing}) }
      end

      context 'with vas_conf_vasd_username_attr_name set to valid testing' do
        let(:params) { { vas_conf_vasd_username_attr_name: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ username-attr-name = testing}) }
      end

      context 'with vas_conf_vasd_groupname_attr_name set to valid testing' do
        let(:params) { { vas_conf_vasd_groupname_attr_name: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ groupname-attr-name = testing}) }
      end

      context 'with vas_conf_vasd_uid_number_attr_name set to valid testing' do
        let(:params) { { vas_conf_vasd_uid_number_attr_name: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ uid-number-attr-name = testing}) }
      end

      context 'with vas_conf_vasd_gid_number_attr_name set to valid testing' do
        let(:params) { { vas_conf_vasd_gid_number_attr_name: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ gid-number-attr-name = testing}) }
      end

      context 'with vas_conf_vasd_gecos_attr_name set to valid testing' do
        let(:params) { { vas_conf_vasd_gecos_attr_name: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ gecos-attr-name = testing}) }
      end

      context 'with vas_conf_vasd_home_dir_attr_name set to valid testing' do
        let(:params) { { vas_conf_vasd_home_dir_attr_name: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ home-dir-attr-name = testing}) }
      end

      context 'with vas_conf_vasd_login_shell_attr_name set to valid testing' do
        let(:params) { { vas_conf_vasd_login_shell_attr_name: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ login-shell-attr-name = testing}) }
      end

      context 'with vas_conf_vasd_group_member_attr_name set to valid testing' do
        let(:params) { { vas_conf_vasd_group_member_attr_name: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ group-member-attr-name = testing}) }
      end

      context 'with vas_conf_vasd_memberof_attr_name set to valid testing' do
        let(:params) { { vas_conf_vasd_memberof_attr_name: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ memberof-attr-name = testing}) }
      end

      context 'with vas_conf_vasd_unix_password_attr_name set to valid testing' do
        let(:params) { { vas_conf_vasd_unix_password_attr_name: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ unix-password-attr-name = testing}) }
      end

      ['NSS', 'NIS', 'OFF'].each do |value|
        context "with vas_conf_vasd_netgroup_mode set to valid #{value}" do
          let(:params) { { vas_conf_vasd_netgroup_mode: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ netgroup-mode = #{value}}) }
        end
      end

      context 'with vas_conf_pam_vas_prompt_ad_lockout_msg set to valid testing' do
        let(:params) { { vas_conf_pam_vas_prompt_ad_lockout_msg: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ prompt-ad-lockout-msg = "testing"}) }
      end

      context 'with vas_conf_libdefaults_default_cc_name set to valid testing' do
        let(:params) { { vas_conf_libdefaults_default_cc_name: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ default_cc_name = testing}) }
      end

      context 'with vas_conf_client_addrs set to valid testing' do
        let(:params) { { vas_conf_client_addrs: 'testing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ client-addrs = testing}) }
      end

      context 'with vas_conf_client_addrs set to invalid long string (>1024 bytes)' do
        let(:params) { { vas_conf_client_addrs: '1234567890 123456789 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 1234567890 123456789 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 1234567890 123456789 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 1234567890 123456789 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 1234567890 123456789 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 1234567890 123456789 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 1234567890 123456789 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 1234567890 123456789 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 1234567890 123456789 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890 01234567890' } } # rubocop:disable Layout/LineLength

        it 'fails' do
          expect { is_expected.to contain_class('vas') }.to raise_error(Puppet::Error, %r{String\[1, 1024\]})
        end
      end

      context 'with vas_conf_full_update_interval set to valid 242' do
        let(:params) { { vas_conf_full_update_interval: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ full-update-interval = 242}) }
      end

      context 'with vas_conf_vasd_timesync_interval set to valid 242' do
        let(:params) { { vas_conf_vasd_timesync_interval: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ timesync-interval = 242}) }
      end

      context 'with vas_conf_vasd_password_change_script_timelimit set to valid 242' do
        let(:params) { { vas_conf_vasd_password_change_script_timelimit: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ password-change-script-timelimit = 242}) }
      end

      context 'with vas_conf_vasd_deluser_check_timelimit set to valid 242' do
        let(:params) { { vas_conf_vasd_deluser_check_timelimit: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ deluser-check-timelimit = 242}) }
      end

      context 'with vas_conf_vasd_delusercheck_interval set to valid 242' do
        let(:params) { { vas_conf_vasd_delusercheck_interval: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ delusercheck-interval = 242}) }
      end

      context 'with vas_conf_vas_auth_uid_check_limit set to valid 242' do
        let(:params) { { vas_conf_vas_auth_uid_check_limit: 242 } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ uid-check-limit = 242}) }
      end

      context 'with vas_conf_vasd_delusercheck_script set to valid /test/ing' do
        let(:params) { { vas_conf_vasd_delusercheck_script: '/test/ing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ delusercheck-script = /test/ing}) }
      end

      context 'with vas_users_allow_path set to valid /test/ing' do
        let(:params) { { vas_users_allow_path: '/test/ing' } }

        it { is_expected.to contain_file('vas_users_allow').with_path('/test/ing') }
      end

      context 'with vas_users_deny_path set to valid /test/ing' do
        let(:params) { { vas_users_deny_path: '/test/ing' } }

        it { is_expected.to contain_file('vas_users_deny').with_path('/test/ing') }
      end

      context 'with vas_user_override_path set to valid /test/ing' do
        let(:params) { { vas_user_override_path: '/test/ing' } }

        it { is_expected.to contain_file('vas_user_override').with_path('/test/ing') }
      end

      context 'with vas_group_override_path set to valid /test/ing' do
        let(:params) { { vas_group_override_path: '/test/ing' } }

        it { is_expected.to contain_file('vas_group_override').with_path('/test/ing') }
      end

      context 'with vas_conf_vasd_password_change_script set to valid /test/ing' do
        let(:params) { { vas_conf_vasd_password_change_script: '/test/ing' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ password-change-script = /test/ing}) }
      end

      [true, false].each do |value|
        context "with vas_conf_vas_auth_allow_disconnected_auth set to valid #{value}" do
          let(:params) { { vas_conf_vas_auth_allow_disconnected_auth: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ allow-disconnected-auth = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_vas_auth_expand_ac_groups set to valid #{value}" do
          let(:params) { { vas_conf_vas_auth_expand_ac_groups: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ expand-ac-groups = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_lowercase_names set to valid #{value}" do
          let(:params) { { vas_conf_lowercase_names: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ lowercase-names = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with vas_conf_lowercase_homedirs set to valid #{value}" do
          let(:params) { { vas_conf_lowercase_homedirs: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ lowercase-homedirs = #{value}}) }
        end
      end

      [true, false].each do |value|
        context "with use_srv_infocache set to valid #{value}" do
          let(:params) { { use_srv_infocache: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ use-srvinfo-cache = #{value}}) }
        end
      end

      context 'with join_domain_controllers set to valid [dc1.test.ing]' do
        let(:params) { { join_domain_controllers: ['dc1.test.ing'] } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{ dc1.test.ing > /var/tmp/vasjoin.log 2>&1 }) }
      end

      context 'with join_domain_controllers set to valid [dc1.test.ing, dc2.test.ing]' do
        let(:params) { { join_domain_controllers: ['dc1.test.ing', 'dc2.test.ing'] } }

        it { is_expected.to contain_exec('vasinst').with_command(%r{ dc1.test.ing dc2.test.ing > /var/tmp/vasjoin.log 2>&1 }) }
      end

      [true, false].each do |value|
        context "with vas_conf_libvas_use_server_referrals set to valid #{value}" do
          let(:params) { { vas_conf_libvas_use_server_referrals: value } }

          it { is_expected.to contain_file('vas_config').with_content(%r{ use-server-referrals = #{value}}) }
        end
      end

      context 'with vas_conf_libvas_use_server_referrals set to valid empty string when ::vas_version is smaller to vas_conf_libvas_use_server_referrals_version_switch' do
        let(:params) do
          {
            vas_conf_libvas_use_server_referrals: '',
            vas_conf_libvas_use_server_referrals_version_switch: '4.1.0.21519',
          }
        end

        it { is_expected.to contain_file('vas_config').with_content(%r{ use-server-referrals = true}) }
      end

      context 'with vas_conf_libvas_use_server_referrals set to valid empty string when ::vas_version is equal to vas_conf_libvas_use_server_referrals_version_switch' do
        let(:params) { { vas_conf_libvas_use_server_referrals: '' } }

        it { is_expected.to contain_file('vas_config').with_content(%r{ use-server-referrals = false}) }
      end

      context 'with vas_conf_libvas_use_server_referrals set to valid empty string when ::vas_version is greater than vas_conf_libvas_use_server_referrals_version_switch' do
        let(:params) do
          {
            vas_conf_libvas_use_server_referrals: '',
            vas_conf_libvas_use_server_referrals_version_switch: '4.1.0.21517',
          }
        end

        it { is_expected.to contain_file('vas_config').with_content(%r{ use-server-referrals = false}) }
      end
    end
  end
end
