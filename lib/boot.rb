# frozen_string_literal: true

# Make sure we can require our files
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include? __dir__

require 'json'

require 'eco'
require 'printer'

# Extend number to make them readable
class Numeric
  def humanize
    value = self
    if value.is_a? Float
      value = format '%0.2f', value
    end

    value
      .to_s
      .split('.', 2)
      .then do |left, right|
        [
          left.gsub(/(\d)(?=(\d\d\d)+(?!\d))/) { "#{_1}_" },
          right,
        ].join('.')
      end
  end
end

Eco.parse_stores_json("#{__dir__}/../tmp/stores.json")
