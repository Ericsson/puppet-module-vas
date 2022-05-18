# frozen_string_literal: true

require 'spec_helper'

describe 'vas' do
  test_on = {
    supported_os: [
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['6', '7', '8'],
      },
      {
        'operatingsystem'        => 'SLES',
        'operatingsystemrelease' => ['11', '12', '15'],
      },
      {
        'operatingsystem'        => 'Ubuntu',
        'operatingsystemrelease' => ['16.04', '18.04', '20.04'],
      },
    ],
  }

  on_supported_os(test_on).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          lsbmajdistrelease: os_facts[:os]['release']['major'],
        )
      end

      # Service not present in VAS 4 and newer
      it {
        is_expected.not_to contain_service('vasgpd')
      }

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
end
