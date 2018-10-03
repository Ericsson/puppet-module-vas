#
# api_fetch.rb
#

require 'net/http'
require 'net/https'
require 'openssl'

module Puppet::Parser::Functions
  newfunction(:api_fetch, :type => :rvalue) do |args|
    raise(Puppet::ParseError, "api_fetch(): Wrong number of arguments given (#{args.size} for 2)") if args.size < 2

    url = args[0]
    token = args[1]

    unless url.is_a?(String)
      raise(Puppet::ParseError, 'api_fetch(): Argument must be a string')
    end

    unless token.is_a?(String)
      raise(Puppet::ParseError, 'api_fetch(): Argument must be a string')
    end

    uri = URI.parse(url)

    req = Net::HTTP::Get.new(uri.to_s)
    req['Authorization'] = "Bearer #{token}"
    req['Accept'] = 'text/plain'

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.open_timeout = 5
    https.read_timeout = 5

    begin
      response = https.start() do |cx|
        cx.request(req)
      end

      case response
      when Net::HTTPSuccess
        if response.body.length > 0
          puts response.body.split("\n")
        end
      end
    rescue Net::OpenTimeout, Net::ReadTimeout
      return Array.new
    end

    return Array.new
  end
end
