# frozen_string_literal: true

require 'eco/currency'
require 'eco/order'
require 'eco/owner'
require 'eco/shop'

module Eco
  def self.parse_json(path, selling:)
    ::JSON.parse(::File.read(path)).each do |data|
      next if data['ForSale'] != selling

      owner = Owner.find(data['StoreOwner'])
      currency = Currency.find(data['Currency'])
      shop = Shop.find(data['StoreName'], currency, owner)

      order = Order.register(
        item: data['tagItemName'],
        price: data['Price'],
        quantity: data['Quantity'],
        selling: selling,
        # Metadata
        currency: currency,
        owner: owner,
        shop: shop,
      )

      shop.add_order(order)
    end
  end

  def self.parse_stores_json(path)
    json = ::JSON.parse(::File.read(path))
    return unless json.key? 'Stores'

    json['Stores'].each do |data|
      # Skip barter shops
      next if data['CurrencyName'] == 'Barter'
      # Skip unknown owners
      next if data['Owner'].nil?

      owner = Owner.find(data['Owner'])
      currency = Currency.find(data['CurrencyName'])
      shop = Shop.find(
        data['Name'],
        currency,
        owner,
        full_access: data['FullAccessUsers'],
      )

      data['AllOffers'].each do |offer|
          order = Order.register(
          item: offer['ItemName'],
          price: offer['Price'],
          quantity: offer['Quantity'],
          selling: !offer['Buying'],
          # Metadata
          currency: currency,
          owner: owner,
          shop: shop,
        )

        shop.add_order(order)
      end
    end
  end
end
