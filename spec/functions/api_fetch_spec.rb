# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe 'vas::api_fetch' do
  headers = {
    'Accept' => 'text/plain',
    'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Authorization' => 'Bearer somesecret',
    'User-Agent' => 'Ruby'
  }

  url = 'https://api.example.local/'
  params = [
    {
      'url'   => url,
      'token' => 'somesecret',
    },
  ]

  describe 'raises an error when parameters are missing' do
    describe 'no arguments' do
      it do
        is_expected.to run
          .with_params
          .and_raise_error(ArgumentError, '\'vas::api_fetch\' expects 1 argument, got none')
      end
    end

    describe 'when required key url is missing in $config' do
      params_missing = [{}]

      it do
        is_expected.to run
          .with_params(params_missing)
          .and_raise_error(ArgumentError, '\'vas::api_fetch\' parameter \'config\' index 0 expects size to be between 1 and 3, got 0')
      end
    end
  end

  describe 'api call' do
    it 'when request times out' do
      stub_request(:get, url).with(
        headers: headers,
      ).to_timeout

      is_expected.to run
        .with_params(params)
        .and_return({ 'errors' => ['https://api.example.local/ connection failed: execution expired'] })
    end

    it 'returns a hash containing key \'content\' with an array of contents' do
      response_body = "line1\nline2"

      stub_request(:get, url).with(
        headers: headers,
      ).to_return(body: response_body, status: 200)

      is_expected.to run
        .with_params(params)
        .and_return({ 'content' => ['line1', 'line2'] })
    end

    it 'returns a hash containing key \'content\' with an empty array' do
      response_body = ''

      stub_request(:get, url).with(
              headers: headers,
            ).to_return(body: response_body, status: 200)

      is_expected.to run
        .with_params(params)
        .and_return({ 'content' => [] })
    end

    it 'returns a hash containing key \'errors\' when non-sucess http response code is received' do
      stub_request(:get, url).with(
              headers: headers,
            ).to_return(body: nil, status: 404)

      is_expected.to run
        .with_params(params)
        .and_return({ 'errors' => ['https://api.example.local/ returns HTTP code: 404'] })
    end

    it 'returns a hash containing key \'errors\' any other error occurs' do
      stub_request(:get, url).with(
              headers: headers,
            ).and_raise(StandardError.new('error'))

      is_expected.to run
        .with_params(params)
        .and_return({ 'errors' => ['https://api.example.local/ connection failed: error'] })
    end
  end
end
