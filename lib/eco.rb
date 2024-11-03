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
end
