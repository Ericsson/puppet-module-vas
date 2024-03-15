# Query a remote HTTP-based service for entries to be added to users_allow.
Puppet::Functions.create_function(:'vas::api_fetch') do
  require 'net/http'
  require 'net/https'
  require 'openssl'
  # @param url URL to connect to
  # @param token Token used for authentication
  # @param ssl_verify Whether TLS connections should be verified or not
  # @return [Hash] Key 'content' with [Array] if API responds. Key 'errors' with [Array[String]] if errors happens.
  # @example Calling the function
  #   vas::api_fetch("https://host.domain.tld/api/${facts['trusted.certname']}")
  dispatch :api_fetch do
    param 'Stdlib::HTTPUrl', :url
    param 'String[1]', :token
    optional_param 'Boolean', :ssl_verify
    return_type 'Hash'
  end

  def api_fetch(url, token, ssl_verify = false)
    uri = URI.parse(url)

    req = Net::HTTP::Get.new(uri.to_s)
    req['Authorization'] = "Bearer #{token}"
    req['Accept'] = 'text/plain'

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    unless ssl_verify
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    https.open_timeout = 2
    https.read_timeout = 2

    data = {}
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
      else
        (data['errors'] ||= []) << "#{url} returns HTTP code: #{response.code}"
      end
    rescue => error
      (data['errors'] ||= []) << "#{url} connection failed: #{error.message}"
    end

    data
  end
end
