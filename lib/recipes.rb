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
    case info['Type']
    when 'ITEM' then Item.new(info)
    when 'TAG' then Tag.new(info)
    else
      raise "Unknown ingredient type: #{info['Type']}"
    end
  end
end
