#
# api_fetch.rb
#

require 'net/http'
require 'net/https'
require 'openssl'

module Puppet::Parser::Functions
  newfunction(:api_fetch, type: :rvalue) do |args|
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
    https.open_timeout = 2
    https.read_timeout = 2

    begin
      response = https.start do |cx|
        cx.request(req)
      end

      case response
      when Net::HTTPSuccess
        return response.code, response.body.split("\n") unless response.body.to_s.empty?
        return response.code, []
      else
        return response.code, nil
      end
    rescue => error
      return 0, error
    end
  end
end
