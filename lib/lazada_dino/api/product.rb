module Lazada
  module API
    module Product
      def get_products(params = {})
        converted_params = get_product_params(params)
        url = request_url('GetProducts', converted_params)
        response = self.class.get(url)

        process_response_errors! response

        response['SuccessResponse']['Body']['Products']
      end

      def create_product(params)
        url = request_url('CreateProduct')

        params = { 'Product' => product_params(params) }

        response = self.class.post(url, body: params.to_xml(root: 'Request', skip_types: true, dasherize: false))

        Lazada::API::Response.new(response)
      end

      def update_product(params)
        url = request_url('UpdateProduct')

        params = { 'Product' => product_params(params) }
        response = self.class.post(url, body: params.to_xml(root: 'Request', skip_types: true, dasherize: false))

        process_response_errors! response

        Lazada::API::Response.new(response)
      end

      def remove_product(seller_sku)
        url = request_url('RemoveProduct')

        params = {
          'Product' => {
            'Skus' => {
              'Sku' => {
                'SellerSku' => seller_sku
              }
            }
          }
        }

        response = self.class.post(url, body: params.to_xml(root: 'Request', skip_types: true))

        Lazada::API::Response.new(response)
      end

      def get_qc_status
        url = request_url('GetQcStatus')

        response = self.class.get(url)

        process_response_errors! response

        response['SuccessResponse']['Body']['Status']
      end

      private

      def get_product_params(object)
        params = {}
        params["CreatedAfter"] = object[:created_after] if object[:created_after].present?
        params["CreatedBefore"] = object[:created_before] if object[:created_before].present?
        params["UpdatedAfter"] = object[:updated_after] if object[:updated_after].present?
        params["UpdatedBefore"] = object[:updated_before] if object[:updated_before].present?
        params["Search"] = object[:search] if object[:search].present?
        object[:filter] = "all" unless object[:filter].present?
        params["Filter"] = object[:filter] if object[:filter].present?
        params["Limit"] = object[:limit] if object[:limit].present?
        params["Options"] = object[:options] if object[:options].present?
        params["Offset"] = object[:offset] if object[:offset].present?
        params["SkuSellerList"] = object[:sku_seller_list] if object[:sku_seller_list].present?
        params
      end

      def product_params(object)
        params = {}
        params['PrimaryCategory'] = object.delete("primary_category")
        params['SPUId'] = ''
        params['AssociatedSku'] = ''

        params['Skus'] = {}
        params['Skus'].compare_by_identity

        # start variant START
        object["variants"].each do |variant|
          variant_params = {}
          
          variant.delete_if { |k, v| v.empty? || v.nil? }

          variant_params['Images'] = {}
          variant_params['Images'].compare_by_identity
          
          if variant['Images'].present? 
            variant['Images'].each do |image|
              url = migrate_image(image)
              variant_params['Images']['Image'.dup] = url
            end
          end

          variant.delete("Images")

          variant.merge!(variant_params)

          params['Skus']['Sku'.dup] = variant
        end

        object.delete("variants")

        params['Attributes'] = {}

        params['Attributes'] = {
          'name' => object.delete("title") || object.delete("name") ,
          'name_ms' => object.delete("name_ms") || object.delete("name") || object.delete("title"),
          'description' => object.delete("description"),
          'short_description' => object.delete("short_description") || object.delete("highlights"),
          'brand' => object.delete("brand") || 'Unbranded',
          'warranty_type' => object.delete("warranty_type") || 'No Warranty',
          'model' => object.delete("model"),
          'package_content' => object.delete("package_content") || object.delete("box_content")
        }

        params['Attributes'].merge!(object)
        params['Attributes'].delete("2_in_1_type") 
        params
      end
    end
  end
end
