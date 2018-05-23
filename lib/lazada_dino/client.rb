require 'httparty'
require 'active_support/core_ext/hash'
require 'pry'
require 'pry-byebug'

require 'lazada_dino/api/product'
require 'lazada_dino/api/category'
require 'lazada_dino/api/feed'
require 'lazada_dino/api/image'
require 'lazada_dino/api/order'
require 'lazada_dino/api/response'
require 'lazada_dino/api/brand'
require 'lazada_dino/api/shipment'
require 'lazada_dino/exceptions/lazada'

module Lazada
  class Client
    include HTTParty
    include Lazada::API::Product
    include Lazada::API::Category
    include Lazada::API::Feed
    include Lazada::API::Image
    include Lazada::API::Order
    include Lazada::API::Brand
    include Lazada::API::Shipment

    base_uri 'https://api.sellercenter.lazada.com.my'

    # Valid opts:
    # - tld: Top level domain to use (.com.my, .sg, .th...). Default: com.my
    # - debug: $stdout, Rails.logger. Log http requests
    def initialize(api_key, user_id, opts = {})
      @api_key = api_key
      @user_id = user_id
      @timezone = opts[:timezone] || 'Singapore'
      @raise_exceptions = opts[:raise_exceptions] || true
      @tld = opts[:tld] || ".com.my"

      # Definitely not thread safe, as the base uri is a class variable.
      # self.class.base_uri "https://api.sellercenter.lazada#{opts[:tld]}" if opts[:tld].present?
      self.class.debug_output opts[:debug] if opts[:debug].present?
    end

    protected

    def request_url(action, options = {})
      current_time_zone = @timezone
      timestamp = Time.now.in_time_zone(current_time_zone).iso8601

      # options["filter"] ? filter = options.delete("filter") : filter = ""

      parameters = {
        'Action' => action,
        'Format' => 'JSON',
        'Timestamp' => timestamp,
        'UserID' => @user_id,
        'Version' => '1.0'
      }

      
      parameters = parameters.merge(options) if options.present?
      parameters = Hash[parameters.sort{ |a, b| a[0] <=> b[0] }]
      params     = parameters.to_query
      
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @api_key, params)
      
      "https://api.sellercenter.lazada#{@tld}/?#{params}&Signature=#{signature}"
    end

    def process_response_errors!(response)
      return unless @raise_exceptions

      parsed_response = Lazada::API::Response.new(response)

      if parsed_response.error?
        raise Lazada::APIError.new(
          "Lazada API Error: '#{parsed_response.error_message}'",
          http_code: response.code,
          response: response.inspect,
          error_type: parsed_response.error_type,
          error_code: parsed_response.error_code,
          error_message: parsed_response.error_message,
          error_detail: parsed_response.body_error_messages,
          request_http_method: response&.request&.http_method&.to_s,
          request_uri: response&.request&.uri&.to_s
        )
      end
    end
  end

end
