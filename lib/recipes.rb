# frozen_string_literal: true

require_relative 'recipes/item'
require_relative 'recipes/recipe'
require_relative 'recipes/tag'

module Recipes
  def self.item_ref(name)
    "i-#{name.gsub(/\s+/, '-').downcase}"
  end

  def self.recipe_ref(name)
    "r-#{name.gsub(/\s+/, '-').downcase}"
  end

  def self.tag_ref(name)
    "t-#{name.gsub(/\s+/, '-').downcase}"
  end

  def self.parse_ingredient(info)
    if info['IsSpecificItem']
      Item.new(info['Name'])
    else
      Tag.new(info['Tag'])
    end
  end
end
