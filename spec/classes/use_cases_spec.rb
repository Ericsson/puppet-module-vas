require 'spec_helper'
describe 'vas' do
  required_params = {
    keytab_source: 'puppet:///files/vas/vasinit.key',
    computers_ou: 'ou=computers,dc=domain,dc=tld',
  }

  on_supported_os.each do |os, os_facts|
    context "on #{os} when value of vas_domain is an empty string (vasclnt package installed but not joined to an AD)" do
      let(:facts) do
        os_facts.merge(
          vas_domain: '',
          lsbmajdistrelease: os_facts[:os]['release']['major'], # Satisfy nisclient
        )
      end
      let(:params) do
        required_params
      end

      it { is_expected.to compile }
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os} when value of vas_domain is undef (vasclnt package installed but not joined to an AD)" do
      let(:facts) do
        os_facts.merge(
          vas_domain: nil,
          lsbmajdistrelease: os_facts[:os]['release']['major'], # Satisfy nisclient
        )
      end
      let(:params) do
        required_params
      end

      it { is_expected.to compile }
    end
  end
end
