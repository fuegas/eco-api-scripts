# frozen_string_literal: true

require_relative 'base'

module Recipes
  class Recipe < Base
    REF_PREFIX = 'r'

    def node
      @node ||= "[[fa:fa-gears #{display_name} ]]"
    end
  end
end
