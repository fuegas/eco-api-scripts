# frozen_string_literal: true

require_relative 'base'

module Recipes
  class Tag < Base
    REF_PREFIX = 't'

    def node
      @node ||= "[/fa:fa-tag #{display_name} \\]"
    end
  end
end
