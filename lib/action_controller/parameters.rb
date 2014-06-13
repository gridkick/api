module ActionController
  class Parameters
    ##
    # This method is used to both `require` and `permit` in
    # a single step. The signature accepts arguments the same way
    # that `permit` does. It returns the same value that `permit`
    # would, a new `ActionController::Parameters` instance that
    # is filtered as defined.
    #
    def require!(*filters)
      filters.each do |filter|
        case filter
        when Symbol, String
          self.require filter
        when Hash then
          required_hash_filter filter
        end
      end

      permit *filters
    end

  private

    def required_hash_filter( filter )
      filter = filter.with_indifferent_access

      # Slicing filters out non-declared keys.
      slice(*filter.keys).each do |key, value|
        if filter[key] == []
          # Declaration {:comment_ids => []}.
          self.require key
        else
          # Declaration {:user => :name} or {:user => [:name, :age, {:adress => ...}]}.
          each_element(value) do |element, index|
            if element.is_a?(Hash)
              element = self.class.new(element) unless element.respond_to?(:permit)
              element.require!(*Array.wrap(filter[key]))
            elsif filter[key].is_a?(Hash) && filter[key][index] == []
              ##
              # HERE BE DRAGONS!!
              #
              # Not sure what case this handles
              #
              self.class.new( value ).require index
            end
          end
        end
      end
    end
  end
end
