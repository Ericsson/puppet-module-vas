# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe 'vas' do
  test_on = {
    supported_os: [
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['8'],
      },
    ],
  }

  headers = {
    'Accept' => 'text/plain',
    'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Authorization' => 'Bearer somesecret',
    'User-Agent' => 'Ruby'
  }

  on_supported_os(test_on).each do |_os, os_facts|
    describe 'variable data type and content validations' do
      let(:node) { 'data-types.example.com' }
      # set needed custom facts and variables
      let(:facts) do
        os_facts.merge(
          lsbmajdistrelease: os_facts[:os]['release']['major'], # Satisfy nisclient
        )
      end

      validations = {
        'Array[String[1]]' => {
          name:    ['users_allow_entries', 'users_deny_entries', 'user_override_entries', 'group_override_entries', 'kdcs',
                    'kpasswd_servers', 'join_domain_controllers'],
          valid:   [['array', 'of', 'strings']],
          invalid: [[0], 'string', { 'ha' => 'sh' }, 3, 2.42, false, nil],
          message: 'expects an Array|index .* expects a String value',
        },
        'Boolean' => {
          name:    ['manage_nis', 'enable_group_policies', 'domain_change', 'vas_conf_vasd_workstation_mode',
                    'vas_conf_vasd_workstation_mode_group_do_member', 'vas_conf_vasd_workstation_mode_groups_skip_update',
                    'vas_conf_vasd_ws_resolve_uid', 'vas_conf_libdefaults_forwardable', 'vas_conf_libvas_site_only_servers',
                    'vas_conf_libvas_use_dns_srv', 'vas_conf_libvas_use_tcp_only', 'symlink_vastool_binary', 'unjoin_vas'],
          valid:   [true, false],
          invalid: ['true', 'false', ['array'], { 'ha' => 'sh' }, 3, 2.42, nil],
          message: 'expects a Boolean',
        },
        'Boolean/API' => {
          name:    ['api_enable'],
          params:  { api_users_allow_url: 'https://api.example.local', api_token: 'somesecret', },
          valid:   [true, false],
          invalid: ['true', 'false', ['array'], { 'ha' => 'sh' }, 3, 2.42, nil],
          message: 'expects a Boolean',
        },
        'Hash' => {
          name:    ['domain_realms', 'license_files'],
          valid:   [], # valid hashes are to complex to block test them here.
          invalid: ['string', 3, 2.42, ['array'], false, nil],
          message: 'expects a Hash value',
        },
        'Integer' => {
          name:    ['vas_conf_vasypd_update_interval', 'vas_conf_vasd_update_interval', 'vas_conf_vasd_auto_ticket_renew_interval',
                    'vas_conf_vasd_lazy_cache_update_interval', 'vas_conf_libvas_vascache_ipc_timeout',
                    'vas_conf_libvas_auth_helper_timeout', 'vas_conf_libvas_mscldap_timeout'],
          valid:   [3, 242],
          invalid: ['string', ['array'], { 'ha' => 'sh' }, 2.42, false, nil],
          message: 'expects a Integer|Error while evaluating a Resource Statement',
        },
        'Optional[Stdlib::Absolutepath]' => {
          name:    ['vas_conf_vasd_delusercheck_script', 'vas_conf_vasd_password_change_script'],
          valid:   ['/absolute/filepath', '/absolute/directory/', :undef],
          invalid: ['../invalid', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects a Stdlib::Absolutepath',
        },
        'Optional[Stdlib::HTTPSUrl] (api_users_allow_url specific)' => {
          name:    ['api_users_allow_url'],
          params:  { api_enable: true, api_token: 'somesecret', },
          valid:   ['https://test.ing'],
          invalid: ['http://str.ing', 'string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects a match for Stdlib::HTTPSUrl',
        },
        'Optional[Boolean]' => {
          name:    ['vas_conf_preload_nested_memberships', 'vas_conf_vasd_cross_domain_user_groups_member_search',
                    'vas_conf_vas_auth_allow_disconnected_auth', 'vas_conf_vas_auth_expand_ac_groups', 'vas_conf_lowercase_names',
                    'vas_conf_lowercase_homedirs', 'use_srv_infocache'],
          valid:   [true, false, :undef],
          invalid: ['true', 'false', ['array'], { 'ha' => 'sh' }, 3, 2.42, nil],
          message: 'expects a value of type Undef or Boolean',
        },
        'Optional[Enum[NSS, NIS, OFF]]' => {
          name:    ['vas_conf_vasd_netgroup_mode'],
          valid:   ['NSS', 'NIS', 'OFF', :undef],
          invalid: ['invalid', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects an undef value or a match for Pattern|Error while evaluating a Resource Statement',
        },
        'Optional[Integer]' => {
          name:    ['vas_conf_full_update_interval', 'vas_conf_vasd_timesync_interval', 'vas_conf_vasd_password_change_script_timelimit',
                    'vas_conf_vasd_deluser_check_timelimit', 'vas_conf_vasd_delusercheck_interval', 'vas_conf_vas_auth_uid_check_limit'],
          valid:   [3, 242, :undef],
          invalid: ['string', ['array'], { 'ha' => 'sh' }, 2.42, false, nil],
          message: 'expects a value of type Undef or Integer',
        },
        'Optional[String[1]]' => {
          name:    ['nisdomainname', 'vas_conf_disabled_user_pwhash', 'vas_conf_expired_account_pwhash', 'vas_conf_locked_out_pwhash',
                    'api_token', 'computers_ou', 'users_ou', 'user_search_path', 'group_search_path', 'upm_search_path',
                    'sitenameoverride', 'vas_conf_vasd_workstation_mode_users_preload', 'vas_conf_vasd_username_attr_name',
                    'vas_conf_vasd_groupname_attr_name', 'vas_conf_vasd_uid_number_attr_name', 'vas_conf_vasd_gid_number_attr_name',
                    'vas_conf_vasd_gecos_attr_name', 'vas_conf_vasd_home_dir_attr_name', 'vas_conf_vasd_login_shell_attr_name',
                    'vas_conf_vasd_group_member_attr_name', 'vas_conf_vasd_memberof_attr_name', 'vas_conf_vasd_unix_password_attr_name',
                    'vas_conf_pam_vas_prompt_ad_lockout_msg', 'vas_conf_libdefaults_default_cc_name', 'vas_conf_client_addrs',
                    'vas_conf_upm_computerou_attr'],
          valid:   ['string', :undef],
          invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects a value of type Undef or String',
        },
        'Optional[String[1]] (keytab_source specific)' => {
          name:    ['keytab_source'],
          valid:   ['puppet:///test.ing', :undef],
          invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects a value of type Undef or String',
        },
        'Stdlib::Absolutepath' => {
          name:    ['keytab_path', 'vas_conf_update_process', 'vas_config_path', 'vasjoin_logfile', 'vastool_binary',
                    'symlink_vastool_binary_target', 'vas_users_allow_path', 'vas_users_deny_path', 'vas_user_override_path',
                    'vas_group_override_path'],
          valid:   ['/absolute/filepath', '/absolute/directory/'], # cant test undef :(
          invalid: ['relative/path', 3, 2.42, ['array'], { 'ha' => 'sh' }],
          message: 'expects a Stdlib::Absolutepath',
        },
        'Stdlib::Filemode' => {
          name:    ['keytab_mode', 'vas_config_mode', 'vas_user_override_mode', 'vas_group_override_mode',
                    'vas_users_allow_mode', 'vas_users_deny_mode'],
          valid:   ['0644', '0755', '0640', '1740'],
          invalid: [2770, '0844', '00644', 'string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
          message: 'expects a match for Stdlib::Filemode|Error while evaluating a Resource Statement',
        },
        'Stdlib::Fqdn' => {
          name:    ['vas_fqdn'],
          valid:   ['test', 'test.ing', 't.est.ing', '10.2.4.2'],
          invalid: ['test ing', 'http:/test', 'https:/test.ing', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expect.*Stdlib::Fqdn',
        },
        'Stdlib::Host (realm specific)' => {
          name:    ['realm'],
          params:  { domain_change: true },
          valid:   ['test', 'test.ing', 't.est.ing', '10.2.4.2'],
          invalid: ['test ing', 'http:/test', 'https:/test.ing', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expect.*Stdlib::Fqdn.*Stdlib::Compat::Ip_address',
        },
        'Stdlib::Port (optional)' => {
          name:    ['kdc_port', 'kpasswd_server_port'],
          valid:   [0, 242, 65_535, :undef],
          invalid: ['string', ['array'], { 'ha' => 'sh' }, -1, 2.42, 65_536, false],
          message: 'expects a value of type Undef or Array|Error while evaluating a Resource Statement',
        },
        'String[1]' => {
          name:    ['package_version', 'username', 'keytab_owner', 'keytab_group', 'nismaps_ou', 'vas_conf_group_update_mode',
                    'vas_conf_root_update_mode', 'vas_conf_prompt_vas_ad_pw', 'vas_conf_libdefaults_tgs_default_enctypes',
                    'vas_conf_libdefaults_tkt_default_enctypes', 'vas_conf_libdefaults_default_etypes',
                    'vas_conf_libvas_use_server_referrals_version_switch', 'vas_config_owner', 'vas_config_group',
                    'vas_user_override_owner', 'vas_user_override_group', 'vas_group_override_owner', 'vas_group_override_group',
                    'vas_users_allow_owner', 'vas_users_allow_group', 'vas_users_deny_owner', 'vas_users_deny_group'],
          valid:   ['string'],
          invalid: ['', 3, 2.42, ['array'], { 'ha' => 'sh' }],
          message: '(expects a String value|expects a String\[1\] value)',
        },
        'Variant[Boolean, Enum[\'\']]' => {
          name:    ['vas_conf_libvas_use_server_referrals'],
          valid:   [true, false, ''],
          invalid: ['true', 'false', 'string', ['array'], { 'ha' => 'sh' }, 3, 2.42],
          message: 'expects a value of type Boolean or Enum',
        },

      }
      validations.sort.each do |type, var|
        mandatory_params = {} if mandatory_params.nil?
        var[:name].each do |var_name|
          var[:params] = {} if var[:params].nil?
          var[:valid].each do |valid|
            context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
              let(:params) { [mandatory_params, var[:params], { "#{var_name}": valid, }].reduce(:merge) }

              it do
                stub_request(:get, 'https://test.ing/')
                  .with(headers: headers)

                stub_request(:get, 'https://api.example.local')
                  .with(headers: headers)

                is_expected.to compile
              end
            end
          end

          var[:invalid].each do |invalid|
            context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
              let(:params) { [mandatory_params, var[:params], { "#{var_name}": invalid, }].reduce(:merge) }

              it 'fails' do
                expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
              end
            end
          end
        end # var[:name].each
      end # validations.sort.each
    end # describe 'variable type and content validations'
  end
end
