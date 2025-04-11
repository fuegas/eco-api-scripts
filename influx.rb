#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/boot'

# Currency reports
Eco::Currency
  .reject(&:credit?)
  .map(&:data)
  .each { puts _1.to_influx(tag: 'currency') }

Eco::Order
  .reject { _1.currency.credit? || _1.default_price? }
  .map(&:data)
  .each { puts _1.to_influx(tag: 'order') }

Eco::Exhaustion
  .map(&:data)
  .each { puts _1.to_influx(tag: 'exhaustion') }

# Server stats
puts Data::ServerStats.info.to_influx(tag: 'serverstats')
