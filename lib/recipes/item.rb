# frozen_string_literal: true

require_relative 'base'

module Recipes
  class Item < Base
    REF_PREFIX = 'i'

    def node
      @node ||= "{{ fa:fa-box #{display_name} }}"
    end
  end
end
