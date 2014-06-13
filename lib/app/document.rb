module App
  module Document
    extend ActiveSupport::Concern

    included do
      include Mongoid::Document
      include Mongoid::Timestamps
      include ActiveModel::ForbiddenAttributesProtection
      cattr_accessor :has_name_fields
      self.has_name_fields = false
    end

    module ClassMethods
      def name_fields!
        field \
          :description,
          :type => String

        field \
          :slug,
          :type => String

        index(
          { :slug => 1 },
          { :unique => true }
        )

        field \
          :title,
          :type => String

        self.has_name_fields = true
      end

      def not_found_klass
        Mongoid::Errors::DocumentNotFound
      end

      # THIS DOES NOT CREATE A COMPOUND INDEX
      def unique!( *fields )
        fields.each do | field |
          index(
            { field => 1 },
            { :unique => true }
          )
        end
      end

      def validations
        validators.inject( Hash.new ) do | memo , validator |
          validator.attributes.each do | attribute |
            memo[ attribute ] ||= Array.new
            memo[ attribute ].push validator
          end
          memo
        end
      end
    end
  end
end
