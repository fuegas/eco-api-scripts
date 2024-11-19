# frozen_string_literal: true

module Eco
  class Shop
    attr_reader :name,
                :currency,
                :owner,
                :full_access,
                :orders

    def add_order(order)
      orders << order
    end

    def multiple_tenants?
      full_access&.any?
    end

    class << self
      def find(name, currency, owner, full_access: [])
        cleaned = clean name
        currency = Currency.find(currency)
        owner = Owner.find(owner)

        shops["#{currency}|#{cleaned}"] ||= new(cleaned, currency, owner, full_access)
      end

      # Delegated methods
      %i(each map select sort_by reject).each do |name|
        define_method name do |*args, &block|
          shops.values.public_send name, *args, &block
        end
      end

      private

      def clean(str)
        str.gsub(/<[^>]+>/, '')
          .gsub(/[^[:alnum:] ]/, '')
      end

      def shops
        @shops ||= {}
      end
    end

    private

    def initialize(name, currency, owner, full_access)
      @name = name
      @currency = currency
      @owner = owner
      @orders = []
      @full_access = full_access

      currency.add_shop self
    end
  end
end
