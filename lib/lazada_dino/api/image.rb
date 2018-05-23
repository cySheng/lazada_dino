module Lazada
  module API
    module Image
      def set_images(params)
        url = request_url('Image')

        params = { 'ProductImage' => params }
        response = self.class.post(url, body: params.to_xml(root: 'Request', skip_types: true))

        response
      end

      def migrate_image(image_url)
        url = request_url('MigrateImage')

        params = { 'Image' => { 'Url' => image_url } }
        response = self.class.post(url, body: params.to_xml(root: 'Request', skip_types: true))

        process_response_errors! response

        response['SuccessResponse'].present? ? response['SuccessResponse']['Body']['Image']['Url'] : ''
      end

      def migrate_images(image_url_list)
        url = request_url('MigrateImages')

        # Allow duplicate keys in dict
        urls = {}.compare_by_identity
        image_url_list.each { |image_url| urls.merge!({ String.new('Url') => image_url }) }

        params = { 'Images' => urls }

        response = self.class.post(url, body: params.to_xml(root: 'Request', skip_types: true))

        process_response_errors! response

        # At the moment of this writing, the API does not seem to be working in Lazada
        # The response is successful, but does not return a body with the details
        # of the migrated images.
        response['SuccessResponse'].present? ? response['SuccessResponse'] : nil
      end

    end
  end
end
