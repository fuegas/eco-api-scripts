# frozen_string_literal: true

require 'printer/shared'

class Printer
  class Csv
    include Shared

    def initialize(*)
      require 'csv' unless defined?(::CSV)
    end

    def output(headers = [], list = [])
      # Stop if we have no items
      if list.empty?
        puts 'No results'
        return
      end

      puts headers.to_csv
      list.each do |vm|
        puts vm.values.map { convert_value(_1) }.to_csv
      end
    end
  end
end
