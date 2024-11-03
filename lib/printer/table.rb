# frozen_string_literal: true

require 'printer/shared'

class Printer
  class Table
    include Shared

    def initialize(*); end

    def output(headers = [], list = [])
      # Stop if we have no items
      if list.empty?
        puts 'No results'
        return
      end

      # Convert values of list to strings, this might change their length
      list.each { |item| item.transform_values! { |value| convert_value value } }

      # Find largest items per column
      sizes = column_sizes headers, list
      pattern = "| #{sizes.map { |s| "%#{s}s" }.join(' | ')} |\n"

      printf pattern, *headers
      printf pattern, *sizes.map { '---:' }
      list.each { |item| printf pattern, *item.values }
    end

    private

    def column_sizes(headers, list)
      sizes = headers.map(&:length)
      list.each do |item|
        item.values.map { |v| v.to_s.length }.each_with_index do |size, column|
          sizes[column] = size if size > sizes[column]
        end
      end

      sizes
    end
  end
end
