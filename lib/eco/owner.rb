# frozen_string_literal: true

module Eco
  class Owner
    attr_reader :name,
                :shops

    def add_shop(shop)
      shops << shop
    end

    def inspect
      %(<Owner name="#{name}" #shops=#{shops.count}>)
    end

    class << self
      def find(name)
        return name if name.is_a?(Owner)

        owners[name] ||= new(name)
      end

      # Delegated methods
      %i(each map select sort_by reject).each do |name|
        define_method name do |*args, &block|
          owners.values.public_send name, *args, &block
        end
      end

      private

      def owners
        @owners ||= {}
      end
    end

    private

    def initialize(name)
      @name = name
      @shops = []
    end
  end
end
