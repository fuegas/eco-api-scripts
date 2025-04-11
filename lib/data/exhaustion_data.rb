# frozen_string_literal: true

require 'data/influx'

class Data
  ExhaustionData = ::Data.define(
    :name,
    :remaining,
  ) do
    include Influx

    def influx_tags
      %i(name)
    end

    def influx_values
      %i(remaining)
    end
  end
end
