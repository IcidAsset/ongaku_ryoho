module S3
  class Bucket

    def list_bucket(options = {})
      response = bucket_request(:get, :params => options)
      max_keys = options[:max_keys]
      objects_attributes = parse_list_bucket_result(response.body)

      # If there are more than 1000 objects S3 truncates listing and
      # we need to request another listing for the remaining objects.
      while parse_is_truncated(response.body)
        next_request_options = { :marker => URI.escape(objects_attributes.last[:key]) }

        if max_keys
          break if objects_attributes.length >= max_keys
          next_request_options[:max_keys] = max_keys - objects_attributes.length
        end

        response = bucket_request(:get, :params => options.merge(next_request_options))
        objects_attributes += parse_list_bucket_result(response.body)
      end

      objects_attributes.map { |object_attributes| Object.send(:new, self, object_attributes) }
    end

  end
end
