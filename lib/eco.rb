# frozen_string_literal: true

require 'data/server_stats'
require 'eco/currency'
require 'eco/exhaustion'
require 'eco/order'
require 'eco/owner'
require 'eco/shop'

module Eco
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
        balance: data['Balance'],
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

  def self.parse_server_stats_json(path)
    json = ::JSON.parse(::File.read(path))
    return unless json.key? 'Description'

    Data::ServerStats.info(
      online_players: json['OnlinePlayers'],
      total_players: json['TotalPlayers'],
      days_running: json['DaysRunning'],
      animals: json['Animals'],
      culture: json['TotalCulture'],
      laws: json['Laws'],
      plants: json['Plants'],
    )
  end

  def self.parse_exhaustion_json(path)
    return unless ::File.exist?(path)

    json = ::JSON.parse(::File.read(path))
    return unless json.is_a? ::Hash

    json.each do |name, remaining|
      Exhaustion.add(name, remaining)
    end
  end
end
