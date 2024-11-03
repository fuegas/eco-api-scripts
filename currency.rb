#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './lib/boot'

printer = Printer.new

data = Eco::Currency
  .reject(&:credit?)
  .map(&:data)
  .sort_by(&:shops_count)
  .map(&:to_h)

printer.output data.first&.keys, data
