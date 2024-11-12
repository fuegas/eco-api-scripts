# frozen_string_literal: true

module Eco
  class Shop
    attr_reader :name,
                :currency,
                :owner,
                :orders

    def add_order(order)
      orders << order
    end

    class << self
      def find(name, currency, owner)
        cleaned = clean name
        currency = Currency.find(currency)
        owner = Owner.find(owner)

        shops["#{currency}|#{cleaned}"] ||= new(cleaned, currency, owner)
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

    def initialize(name, currency, owner)
      @name = name
      @currency = currency
      @owner = owner
      @orders = []

      currency.add_shop self
    end
  end
end