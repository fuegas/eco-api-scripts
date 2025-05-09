# frozen_string_literal: true

require 'data/influx'

class Data
  CurrencyData = ::Data.define(
    :name,
    :credit,
    :shops_count,
    :buying_count,
    :buying_value,
    :selling_count,
    :selling_value,
  ) do
    include Influx

    def influx_tags
      %i(
        name
        credit
      )
    end

    def influx_values
      %i(
        shops_count
        buying_count
        buying_value
        selling_count
        selling_value
      )
    end
  end
end
