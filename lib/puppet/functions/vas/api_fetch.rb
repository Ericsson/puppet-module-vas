# Query a remote HTTP-based service for entries to be added to users_allow.
Puppet::Functions.create_function(:'vas::api_fetch') do
  require 'net/http'
  require 'net/https'
  require 'openssl'
  # @param config Hash with API configuration
  # @return [Hash] Key 'content' with [Array] if API responds. Key 'errors' with [Array[String]] if errors happens.
  # @example Calling the function
  #   vas::api_fetch([{'url' => "https://host.domain.tld/api/${facts['trusted.certname']}"}])
  # @example Multiple servers with different tokens, ssl_verify enabled
  #   vas::api_fetch([
  #     {'url' => "https://host1.domain.tld/api/${facts['trusted.certname']}", 'token' => 'token123', 'ssl_verify' => true},
  #     {'url' => "https://host2.domain.tld/api/${facts['trusted.certname']}", 'token' => 'token321', 'ssl_verify' => true},
  #   ])
  #
  dispatch :api_fetch do
    param 'Vas::API::Config', :config
    return_type 'Hash'
  end

  def api_fetch(config)
    data = {}

    config.shuffle.each do |entry|
      url = entry['url']
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri.to_s)
      req['Authorization'] = "Bearer #{entry['token']}" if entry.key?('token')
      req['Accept'] = 'text/plain'

      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      # Set SSL::VERIFY_NONE if key ssl_verify is not present or if set to false
      # Should be true by default in next major release
      if !entry.key?('ssl_verify') || !entry['ssl_verify']
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      https.open_timeout = 2
      https.read_timeout = 2

      begin
        response = https.start do |cx|
          cx.request(req)
        end

        case response
        when Net::HTTPSuccess
          data['content'] = if response.body.empty?
                              []
                            else
                              response.body.split("\n")
                            end
          # Successful response received, break loop
          break
        else
          (data['errors'] ||= []) << "#{url} returns HTTP code: #{response.code}"
        end
      rescue => error
        (data['errors'] ||= []) << "#{url} connection failed: #{error.message}"
      end
    end

    data
  end
end
