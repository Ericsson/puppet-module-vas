# frozen_string_literal: true

require 'spec_helper'

describe 'vas' do
  test_on = {
    supported_os: [
      {
        'operatingsystem'        => 'Solaris',
        'operatingsystemrelease' => ['9', '10', '11'],
      },
    ],
  }

  on_supported_os(test_on).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      if os_facts[:kernel] == '5.9'
        deps = ['rpc']
        hasstatus = false
      else
        deps = ['rpc/bind']
        hasstatus = true
      end

      it {
        is_expected.to contain_file('/tmp/generic-pkg-response').with_content('CLASSES= run\n')
      }

      it {
        is_expected.to contain_service('vas_deps').with(
          'ensure'    => 'running',
          'name'      => deps,
          'enable'    => true,
          'hasstatus' => hasstatus,
          'notify'    => 'Service[vasypd]',
        )
      }

      # Service not present in VAS 4 and newer
      it {
        is_expected.not_to contain_service('vasgpd')
      }

      describe 'with VAS version 3.x' do
        let(:facts) do
          os_facts.merge(
            vas_version: '3.1.2',
          )
        end

        it {
          is_expected.to contain_service('vasgpd').with(
            'ensure' => 'running',
            'enable' => true,
            'provider' => 'init',
            'require' => 'Service[vasd]',
          )
        }
      end
    end
  end
end
