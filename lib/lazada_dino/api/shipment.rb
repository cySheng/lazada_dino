module Lazada
  module API
    module Shipment
      def get_shipment_providers
        url = request_url('GetShipmentProviders')
        response = self.class.get(url)

        process_response_errors! response

        return response['SuccessResponse']['Body'] if response['SuccessResponse']
        Lazada::API::Response.new(response)
      end

      def set_status_to_packed(params)
        url = request_url('SetStatusToPackedByMarketplace', params)
        response = self.class.get(url)

        process_response_errors! response

        return response['SuccessResponse']['Body'] if response['SuccessResponse']
        Lazada::API::Response.new(response)
      end

      def set_status_to_shipped(params)
        url = request_url('SetStatusToReadyToShip', params)
        response = self.class.get(url)

        process_response_errors! response

        return response['SuccessResponse']['Body'] if response['SuccessResponse']
        Lazada::API::Response.new(response)
      end
    end
  end
end
