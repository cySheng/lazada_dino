module Lazada

  class LazadaError < StandardError
    def initialize(message = nil)
      super message
    end

    def detailed_description
      s =  "Message: '#{self.to_s}'"

      self.instance_variables.each do |iv|
        s += ", #{iv.to_s.gsub(/@/, '')}: '#{self.instance_variable_get(iv)}'"
      end
  
      s
    end
  end

  class APIError < LazadaError
    attr_reader :http_code
    attr_reader :response

    attr_reader :error_type
    attr_reader :error_code
    attr_reader :error_message
    attr_reader :error_detail

    def initialize(message = nil, params = {})
      super message

      @http_code           = params[:http_code]
      @response            = params[:response]

      @error_type          = params[:error_type]
      @error_code          = params[:error_code]
      @error_message       = params[:error_message]
      @error_detail        = params[:error_detail]
      @request_http_method = params[:request_http_method]
      @request_uri         = params[:request_uri]
    end
  end
end
