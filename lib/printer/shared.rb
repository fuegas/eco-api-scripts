# frozen_string_literal: true

class Printer
  module Shared
    protected

    def convert_value(value)
      case value
      # when DateTime
      #   value.rfc2822
      when Float
        value.round(2).humanize
      else value
      end
    end
  end
end
