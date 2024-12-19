# frozen_string_literal: true

module Recipes
  class Mermaid
    def initialize(recipes:, tags:)
      @recipes = recipes
      @tags = tags
    end

    def for(name)
      prepare! name

      process_tags_for name
      process_recipes_for name

      add_styling_to_buffer

      buffer.join "\n"
    end

    protected

    # Storage for the mermaid output
    attr_reader :buffer

    # The clickable links for a graph
    attr_reader :click_links

    # Index is used for linkstyle at the end
    # It signals which links should be colored
    attr_reader :colored_links

    # Which nodes should recieve styling?
    # These might be highlighted recipes.
    attr_reader :styled_nodes

    # Data to process
    attr_reader :recipes,
                :tags

    def prepare!(name)
      @buffer = [
        '---',
        "title: Tags and recipes for #{name}",
        '---',
        'flowchart LR',
        'linkStyle default stroke: black',
      ]

      @click_links = {}
      @colored_links = []
      @styled_nodes = {}
    end

    def add_styling_to_buffer
      # Which clickable links do we have?
      buffer.concat click_links.values
      buffer.concat styled_nodes.values

      # Which links should be colored?
      colored_links.each_with_index do |value, index|
        next unless value

        buffer << "linkStyle #{index} stroke: red"
      end
    end

    def process_tags_for(name)
      tags.each do |t_name, items|
        tag = Tag.new t_name

        color_all = false
        if tag.matches? name
          color_all = true
        elsif items.include?(name)
          # Process this tag
        else
          # Skip this tag
          next
        end

        add_click_link tag.ref

        items.each do |info|
          item = Item.new info

          colored_links << (color_all || item.matches?(name))

          buffer << "#{item.ref}#{item.node} --x #{tag.ref}#{tag.node}"
          add_click_link item.ref
        end
      end
    end

    def add_click_link(ref)
      click_links[ref] = %(click #{ref} "#{ref}.html")
    end

    def highlight_node(ref)
      styled_nodes[ref] = %(style #{ref} stroke:red)
    end

    def static_node(ref)
      styled_nodes[ref] = %(style #{ref} fill:#f5e6ab,stroke:yellow)
    end

    def add_ingredient(color:, ingredient:, recipe:)
      buffer << [
        "#{ingredient.ref}#{ingredient.node}",
        "--#{ingredient.quantity}-->",
        "#{recipe.ref}#{recipe.node}",
      ].join(' ')

      if ingredient.static?
        static_node(ingredient.ref)
      end

      colored_links << color
      add_click_link ingredient.ref
    end

    def add_product(color:, product:, recipe:)
      buffer << [
        "#{recipe.ref}#{recipe.node}",
        "--#{product.quantity}-->",
        "#{product.ref}#{product.node}",
      ].join(' ')

      colored_links << color
      add_click_link product.ref
    end

    def process_recipes_for(name)
      recipes.each do |r_name, attrs|
        ingredients = attrs['Ingredients'].map do |info|
          ::Recipes.parse_ingredient info
        end
        products = attrs['Products'].map do |info|
          Item.new info
        end

        recipe = Recipe.new r_name

        color_all = false
        if recipe.matches? name
          color_all = true
        elsif ingredients.any? { _1.matches? name } \
              || products.any? { _1.matches? name }
          # Process this recipe
        else
          # Skip this recipe
          next
        end

        add_click_link recipe.ref

        if color_all
          highlight_node recipe.ref
        end

        ingredients.each do |ingredient|
          add_ingredient(
            color: color_all || ingredient.matches?(name),
            ingredient: ingredient,
            recipe: recipe,
          )
        end

        products.each do |product|
          add_product(
            color: color_all || product.matches?(name),
            product: product,
            recipe: recipe,
          )
        end
      end
    end
  end
end
