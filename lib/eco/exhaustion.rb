# frozen_string_literal: true

require 'data/exhaustion_data'

module Eco
  class Exhaustion
    attr_reader :name,
                :remaining

    def inspect
      %(<Exhaustion name="#{name}" remaining=#{remaining}>)
    end

    def data
      @data ||= ::Data::ExhaustionData.new(
        name: name,
        remaining: remaining.floor,
      )
    end

    class << self
      def add(name, remaining)
        players[name] = new(name, remaining)
      end

      # Delegated methods
      %i(each map select sort_by reject).each do |name|
        define_method name do |*args, &block|
          players.values.public_send name, *args, &block
        end
      end

      private

      def players
        @players ||= {}
      end
    end

    private

    def initialize(name, remaining)
      @name = name
      @remaining = remaining
    end
  end
end
