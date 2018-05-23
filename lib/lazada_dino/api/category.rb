module Lazada
  module API
    module Category
      def get_categories
        url = request_url('GetCategoryTree')
        response = self.class.get(url)

        return response['SuccessResponse']['Body'] if response['SuccessResponse']
        response
      end

      def get_category_attributes(primary_category_id)
        url = request_url('GetCategoryAttributes', 'PrimaryCategory' => primary_category_id)
        response = self.class.get(url)

        return response['SuccessResponse']['Body'] if response['SuccessResponse']
        response
      end
    end
  end
end
