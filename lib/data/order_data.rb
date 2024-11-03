# frozen_string_literal: true

require 'data/influx'

class Data
  class OrderData < ::Data.define(
    :item,
    :price,
    :quantity,
    :selling,
    # Metadata
    :currency,
    :owner,
    :shop,
  )
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
      )
    end
  end
end
