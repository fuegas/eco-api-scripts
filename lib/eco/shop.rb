# frozen_string_literal: true

module Eco
  class Shop
    attr_reader :name,
                :currency,
                :owner,
                :balance,
                :full_access,
                :orders

    def add_order(order)
      orders << order
    end

    def multiple_tenants?
      full_access&.any?
    end

    class << self
      def find(name, currency, owner, balance: nil, full_access: [])
        cleaned = clean name, owner: owner
        currency = Currency.find(currency)
        owner = Owner.find(owner)

        shops["#{currency}|#{cleaned}"] ||= new(cleaned, currency, owner, balance, full_access)
      end

      # Delegated methods
      %i(each map select sort_by reject).each do |name|
        define_method name do |*args, &block|
          shops.values.public_send name, *args, &block
        end
      end

      private

      def clean(str, owner:)
        cleaned = str.gsub(/<[^>]+>/, '') \
                     .gsub(/[^[:alnum:] ]/, '')

        if cleaned.empty?
          "invalid_store_name_#{owner.name}"
        else
          cleaned
        end
      end

      def shops
        @shops ||= {}
      end
    end

    private

    def initialize(name, currency, owner, balance, full_access)
      @name = name
      @currency = currency
      @owner = owner
      @orders = []
      @balance = balance
      @full_access = full_access

      currency.add_shop self
    end
  end
end
