# frozen_string_literal: true

require 'data/influx'

class Data
  OrderData = ::Data.define(
    :item,
    :price,
    :quantity,
    :selling,
    # Metadata
    :currency,
    :owner,
    :shop,
    :shop_balance,
  ) do
    include Influx

    def influx_tags
      %i(
        item
        selling
        currency
        owner
        shop
      )
    end

    def influx_values
      %i(
        price
        quantity
        shop_balance
      )
    end
  end
end
