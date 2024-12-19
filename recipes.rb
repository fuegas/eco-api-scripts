#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

require_relative 'lib/recipes'
require_relative 'lib/recipes/context'
require_relative 'lib/recipes/mermaid'
require_relative 'lib/recipes/renderer'

# Load data from cached jsons
recipes = JSON.parse(
  File.read("#{__dir__}/tmp/recipes.json"),
)

tags = JSON.parse(
  File.read("#{__dir__}/tmp/tags.json"),
)['Tags']

# Preprocess tags
# We're not interested in trashables
tags.reject! { _1.include? 'Trashable' }
# Soooo many items are food...
# It makes other overview unreadable
tags.delete 'Food'

# Gather information
curated_items = {}
recipes.each_value do |recipe|
  recipe['Ingredients'].each do |item|
    next unless item['Type'] == 'ITEM'

    name = item['DisplayName']
    curated_items[Recipes.item_ref(name)] = name
  end

  recipe['Products'].each do |item|
    name = item['DisplayName']
    curated_items[Recipes.item_ref(name)] = name
  end
end

skill_recipes = {}
recipes.each do |name, recipe|
  ref = Recipes.recipe_ref(name)

  recipe['SkillsNeeded'].each do |info|
    (skill_recipes[info['Skill']] ||= {})[ref] = name
  end
end

curated_skill_recipes = skill_recipes.sort.to_h
curated_skill_recipes.transform_values! do |values|
  values.sort.to_h
end

curated_tags = tags
  .keys
  .sort
  .to_h { |name| [Recipes.tag_ref(name), name] }

# Render pages
renderer = Recipes::Renderer.new(
  templates_path: "#{__dir__}/templates/recipes",
  output_path: "#{__dir__}/recipes",
)

# Index
renderer.render_with_layout(
  'index',
  output: 'index.html',
  items: curated_items,
  skill_recipes: curated_skill_recipes,
  tags: curated_tags,
)

mermaid = Recipes::Mermaid.new(
  recipes: recipes,
  tags: tags,
)

# Page for each tag
curated_tags.each_value do |name|
  renderer.render_with_layout(
    'mermaid',
    output: "#{Recipes.tag_ref(name)}.html",
    mermaid: mermaid.for(name),
  )
end

# Page for each item
curated_items.each_value do |name|
  renderer.render_with_layout(
    'mermaid',
    output: "#{Recipes.item_ref(name)}.html",
    mermaid: mermaid.for(name),
  )
end

# Page for each recipe
recipes.each_key do |name|
  renderer.render_with_layout(
    'mermaid',
    output: "#{Recipes.recipe_ref(name)}.html",
    mermaid: mermaid.for(name),
  )
end

# Done!
puts '', 'ok'