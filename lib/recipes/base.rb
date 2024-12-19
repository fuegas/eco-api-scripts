# frozen_string_literal: true

module Recipes
  class Base
    attr_reader :display_name, :quantity, :static

    def initialize(data)
      case data
      when ::Hash
        @display_name = data['DisplayName']
        @quantity = data['Quantity']
        @static = data['isStatic'] == 'true'
      when ::String
        @display_name = data
      else
        raise "Faulty type: #{data.class.name}"
      end
    end

    def matches?(other_display_name)
      display_name == other_display_name
    end

    def node
      raise 'Not implemented!'
    end

    def ref
      @ref ||= "#{self.class::REF_PREFIX}-#{display_name.gsub(/\s+/, '-').downcase}"
    end

    def static?
      static
    end
  end
end
