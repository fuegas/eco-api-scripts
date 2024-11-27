#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './lib/boot'

ignorable = [
  'Bacae Ridge Mayors Store',
  'Bank of Irongrad Ferrum',
  'City of Paradise Acquisitions',
  'Dementia Dunes Power Plant',
  'Grand Duke of Rosarias Store',
  'IRONGRAD  Land Allocation Center',
  'King of Valistheas Store',
  'Pasture Prime Government Store',
  'Pasture Prime Power Plant',
  'Rosaria Government Store',
  'Rosaria Opal Distribution',
  'Valisthea Power Plant',
].freeze

shops = Eco::Shop
  .select(&:multiple_tenants?)
  .sort_by { _1.owner.name }
  .reject { ignorable.include? _1.name }

unless shops.any?
  puts 'No store has multiple tenants \o/'
  exit 0
end

shops.each do |shop|
  puts shop.name,
       "  Owner: #{shop.owner.name}",
       '  Tenants:',
       *shop.full_access.map { "  - #{_1}" }
end
