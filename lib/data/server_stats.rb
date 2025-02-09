# frozen_string_literal: true

require 'data/influx'

class Data
  class ServerStats < ::Data.define(
    :animals,
    :culture,
    :days_running,
    :laws,
    :online_players,
    :plants,
    :total_players,
  )
    include Influx

    def self.info(**opts)
      @info ||= ServerStats.new(**opts)
    end

    def influx_tags
      []
    end

    def influx_values
      %i(
        animals
        culture
        days_running
        laws
        online_players
        plants
        total_players
      )
    end

    # def store(
    #   animals:,
    #   culture:,
    #   days_running:,
    #   laws:,
    #   online_players:,
    #   plants:,
    #   total_players:
    # )
    #   @animals = animals
    #   @culture = culture
    #   @days_running = days_running
    #   @laws = laws
    #   @online_players = online_players
    #   @plants = plants
    #   @total_players = total_players
    # end
  end
end
