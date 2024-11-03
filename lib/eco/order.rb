# frozen_string_literal: true

require 'data/order_data'

module Eco
  class Order
    attr_reader :item,
                :price,
                :quantity,
                :selling,
                # Metadata
                :currency,
                :owner,
                :shop

    def selling?
      @selling
    end

    def data
      @data ||= ::Data::OrderData.new(
        item: item,
        price: price,
        quantity: quantity,
        selling: selling ? 'selling' : 'buying',
        # Metadata
        currency: currency.name,
        owner: owner.name,
        shop: shop.name,
      )
    end

    def inspect
      [
        '<Order',
        %(item=#{item}),
        %(price=#{price}),
        %(quantity=#{quantity}),
        %(selling=#{selling}),
        %(currency=#{currency.name}),
        %(owner=#{owner.name}),
        %(shop=#{shop.name}),
        '>',
      ].join ' '
    end

    class << self
      def register(...)
        order = new(...)
        orders << order
        order
      end

      # Delegated methods
      %i(each map select sort_by reject).each do |name|
        define_method name do |*args, &block|
          orders.public_send name, *args, &block
        end
      end

      private

      def orders
        @orders ||= []
      end
    end

    private

    def initialize(
      item:,
      price:,
      quantity:,
      selling:,
      # Metadata
      currency:,
      owner:,
      shop:
    )
      @item = item
      @price = price
      @quantity = quantity
      @selling = selling

      @currency = currency
      @owner = owner
      @shop = shop
    end
  end
end
