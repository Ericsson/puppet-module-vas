# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe 'api_fetch' do
  headers = {
    'Accept' => 'text/plain',
    'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Authorization' => 'Bearer somesecret',
    'User-Agent' => 'Ruby'
  }

  url = 'https://api.example.local/'

  describe 'raises an error when arguments are missing' do
    describe 'no arguments' do
      it do
        is_expected.to run
          .with_params
          .and_raise_error(Puppet::ParseError, 'api_fetch(): Wrong number of arguments given (0 for 2)')
      end
    end

    describe 'token argument is missing' do
      it do
        is_expected.to run
          .with_params(url)
          .and_raise_error(Puppet::ParseError, 'api_fetch(): Wrong number of arguments given (1 for 2)')
      end
    end
  end

  describe 'raises an error when url argument is not a string' do
    it do
      is_expected.to run
        .with_params(1, 'somesecret')
        .and_raise_error(%r{Argument must be a string})
    end
  end

  describe 'raises an error when token argument is not a string' do
    it do
      is_expected.to run
        .with_params(url, 1)
        .and_raise_error(%r{Argument must be a string})
    end
  end

  describe 'api call' do
    it 'when request times out' do
      stub_request(:get, url).with(
        headers: headers,
      ).to_timeout

      is_expected.to run
        .with_params(url, 'somesecret')
        .and_return([0, 'execution expired'])
    end

    it 'returns an array containing http response code and body' do
      response_body = "line1\nline2"

      stub_request(:get, url).with(
        headers: headers,
      )
                             .to_return(body: response_body, status: 200)

      is_expected.to run
        .with_params(url, 'somesecret')
        .and_return(['200', ['line1', 'line2']])
    end

    it 'returns an array containing http response code and an empty array when response body is empty' do
      response_body = ''

      stub_request(:get, url).with(
              headers: headers,
            )
                             .to_return(body: response_body, status: 200)

      is_expected.to run
        .with_params(url, 'somesecret')
        .and_return(['200', []])
    end

    it 'returns nil when http response code is not success' do
      stub_request(:get, url).with(
              headers: headers,
            )
                             .to_return(body: nil, status: 404)

      is_expected.to run
        .with_params(url, 'somesecret')
        .and_return(['404', nil])
    end

    it 'returns an array containing 0 and error when error occurs' do
      stub_request(:get, url).with(
              headers: headers,
            )
                             .and_raise(StandardError.new('error'))

      is_expected.to run
        .with_params(url, 'somesecret')
        .and_return([0, 'error'])
    end
  end
end
