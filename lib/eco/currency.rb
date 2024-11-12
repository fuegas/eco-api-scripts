# frozen_string_literal: true

require 'data/currency_data'

module Eco
  class Currency
    attr_reader :name,
                :shops

    def add_shop(shop)
      shops << shop
    end

    def credit?
      @credit ||= name.end_with? ' Credit'
    end

    def data
      @data ||= begin
        buying_count = selling_count = 0
        buying_value = selling_value = 0.0

        shops.each do |shop|
          shop.orders.each do |order|
            next if order.default_price?

            if order.selling?
              selling_count += 1
              selling_value += order.quantity * order.price
            else
              buying_count += 1
              buying_value += order.quantity * order.price
            end
          end
        end

        ::Data::CurrencyData.new(
          name: name,
          credit: credit?,
          shops_count: shops.count,
          buying_count: buying_count,
          buying_value: buying_value.round(2),
          selling_count: selling_count,
          selling_value: selling_value.round(2),
        )
      end
    end

    def inspect
      [
        '<Currency',
        %(name="#{name}"),
        %(credit="#{credit? ? 'yes' : 'no'}"),
        %(#shops=#{shops.count}),
        %(#buying=#{data.buying_count.humanize}),
        %($buying=#{data.buying_value.humanize}),
        %(#selling=#{data.selling_count.humanize}),
        %($selling=#{data.selling_value.humanize}>),
        '>',
      ].join(' ')
    end

    class << self
      def find(name)
        return name if name.is_a?(Currency)

        currencies[name] ||= new(name)
      end

      # Delegated methods
      %i(each map select sort_by reject).each do |name|
        define_method name do |*args, &block|
          currencies.values.public_send name, *args, &block
        end
      end

      private

      def currencies
        @currencies ||= {}
      end
    end

    private

    def initialize(name)
      @name = name
      @shops = []
    end
  end
end
