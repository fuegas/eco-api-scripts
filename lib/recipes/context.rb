# frozen_string_literal: true

module Recipes
  class Context
    def initialize(data)
      @context = data
    end

    def [](name)
      @context[name]
    end
  end
end
