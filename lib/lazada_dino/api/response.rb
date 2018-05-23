module Lazada
  module API
    class Response
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def request_id
        response.dig('SuccessResponse', 'Head', 'RequestId')
      end

      def success?
        response['SuccessResponse'].present?
      end

      def error?
        response['ErrorResponse'].present?
      end

      def warning?
        response.dig('SuccessResponse', 'Body', 'Warnings').present?
      end

      def warning_messages
        hash = {}
        response.dig('SuccessResponse', 'Body', 'Warnings').each do |warning|
          hash[warning['Field'].dup] = warning['Message']
        end

        hash
      end

      def error_message
        response.dig('ErrorResponse', 'Head', 'ErrorMessage')
      end

      def error_type
        response.dig('ErrorResponse', 'Head', 'ErrorType')
      end

      def error_code
        response.dig('ErrorResponse', 'Head', 'ErrorCode')
      end

      def body_error_messages
        return if response.dig('ErrorResponse').nil?

        # Parent error coming in the header
        hash = { error: error_message }

        # Error coming in the body
        response.dig('ErrorResponse', 'Body', 'Errors')&.each do |error|
          hash[error['Field'].dup] = error['Message']
        end

        hash
      end
    end
  end
end
