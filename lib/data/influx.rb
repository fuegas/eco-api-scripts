# frozen_string_literal: true

class Data
  module Influx
    def convert_influx_value(value, name:)
      case value
      when Float then value
      when Integer then "#{value}i"
      when String then value.gsub(/[\s=,]/) { "\\#{_1}" }
      when true, false then value.to_s
        # re := regexp.MustCompile(`([\s=,])`)
        # return re.ReplaceAllString(val, "\\$1")
      else
        raise "No idea how to process #{name} with #{value.class.name}: #{value}"
      end
    end

    def convert_influx_fields(*names)
      self.to_h.slice(*names)
        .map { "#{_1}=#{convert_influx_value(_2, name: _1)}" }
        .join(',')
    end

    def to_influx(tag:)
      [
        tag,
        ',',
        convert_influx_fields(*influx_tags),
        ' ',
        convert_influx_fields(*influx_values),
      ].join
    end
  end
end
