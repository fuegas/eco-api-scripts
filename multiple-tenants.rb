#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './lib/boot'

ignorable = [
  'Bank of Irongrad Ferrum',
  'City of Paradise Acquisitions',
  'Dementia Dunes Power Plant',
  'Pasture Prime Government Store',
  'Rosaria Government Store',
].freeze

shops = Eco::Shop
  .select(&:multiple_tenants?)
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
