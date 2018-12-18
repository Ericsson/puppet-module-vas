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

    # Added to support both Ruby 1.9 and 1.9+ spec tests.. Net::{Read,Open}Timeout
    # Taken from https://github.com/hashicorp/vault-ruby/blob/d7170032bc0f9d5bf018c62a8deae05ae1ec7b2e/lib/vault/client.rb#L31
    RESCUED_EXCEPTIONS = [].tap do |a|
      # Failure to even open the socket (usually permissions)
      a << SocketError

      # Failed to reach the server (aka bad URL)
      a << Errno::ECONNREFUSED

      # Failed to read body or no response body given
      a << EOFError

      # Timeout (Ruby 1.9-)
      a << Timeout::Error

      # Timeout (Ruby 1.9+) - Ruby 1.9 does not define these constants so we
      # only add them if they are defiend
      a << Net::ReadTimeout if defined?(Net::ReadTimeout)
      a << Net::OpenTimeout if defined?(Net::OpenTimeout)
    end.freeze unless defined? RESCUED_EXCEPTIONS

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

      if response.kind_of? Net::HTTPSuccess and response.body.length > 0
        puts response.body.split("\n")
      end
    rescue RESCUED_EXCEPTIONS
      return Array.new
    end

    return Array.new
  end
end
