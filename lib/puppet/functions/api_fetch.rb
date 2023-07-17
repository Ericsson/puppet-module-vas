# Query a remote HTTP-based service for entries to be added to users_allow.
Puppet::Functions.create_function(:api_fetch) do
  require 'net/http'
  require 'net/https'
  require 'openssl'
  # @param url URL to connect to
  # @param token Token used for authentication
  # @return [Stdlib::Http::Status, Array[String]] If a valid response and contains entries
  # @return [Stdlib::Http::Status, Array[nil]] If a valid response, but no entries
  # @return [Stdlib::Http::Status, nil] If response is not of SUCCESS status code
  # @return [0, String] If the query is unable to reach server or other error
  # @example Calling the function
  #   vas::api_fetch("https://host.domain.tld/api/${facts['trusted.certname']}")
  dispatch :api_fetch do
    param 'Stdlib::HTTPUrl', :url
    param 'String[1]', :token
  end

  def api_fetch(url, token)
    uri = URI.parse(url)

    req = Net::HTTP::Get.new(uri.to_s)
    req['Authorization'] = "Bearer #{token}"
    req['Accept'] = 'text/plain'

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.open_timeout = 2
    https.read_timeout = 2

    begin
      response = https.start do |cx|
        cx.request(req)
      end

      case response
      when Net::HTTPSuccess
        return response.code, response.body.split("\n") unless response.body.to_s.empty?
        [response.code, []]
      else
        [response.code, nil]
      end
    rescue => error
      [0, error.message]
    end
  end
end
