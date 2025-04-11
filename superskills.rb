#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative 'lib/recipes'
require_relative 'lib/recipes/context'
require_relative 'lib/recipes/renderer'

# Load data from cached json
recipes = JSON.parse(
  File.read("#{__dir__}/tmp/recipes.json"),
)['Recipes']

tags = JSON.parse(
  File.read("#{__dir__}/tmp/tags.json"),
)['Tags']

# Preprocess tags
# We're not interested in trashables
tags.reject! { _1.include? 'Trashable' }

# Categories and known skills
# rubocop:disable Style/WordArray
categories = {
  'Carpenter' => [
    'Carpentry',
    'Composites',
    'Logging',
    'Paper Milling',
    'Shipwright',
  ],
  'Chef' => [
    'Advanced Baking',
    'Advanced Cooking',
    'Baking',
    'Cooking',
    'Cutting Edge Cooking',
    'Campfire Cooking',
  ],
  'Engineer' => [
    'Basic Engineering',
    'Electronics',
    'Industry',
    'Mechanics',
  ],
  'Farmer' => [
    'Farming',
    'Fertilizers',
    'Milling',
    'Gathering',
  ],
  'Hunter' => [
    'Hunting',
    'Butchery',
  ],
  'Mason' => [
    'Advanced Masonry',
    'Glassworking',
    'Masonry',
    'Pottery',
    'Mining',
  ],
  'Scientist' => [
    'Oil Drilling',
    'Painting',
  ],
  'Smith' => [
    'Advanced Smelting',
    'Blacksmith',
    'Smelting',
  ],
  'Tailor' => [
    'Tailoring',
  ],
}
# rubocop:enable Style/WordArray

# Items anyone can make
items_anyone_can_make = [
  'Adobe',
  'Spoiled Food',
  'Store',
]

items_we_can_ignore = [
  'Acorn',
  'Clam',
  'Cloth',
  'Compost',
  'Creosote Flower',
  'Kelp',
  'Orchid',
  'Pacific Sardine',
  'Peat',
  'Trillium Flower',
  'Urchin',
]

craft_tags_to_ignore = [
  'Basic Research',
  'Advanced Research',
  'Modern Research',
]

craft_items_to_ignore = [
  *craft_tags_to_ignore.map { tags[_1] }.flatten,
]

# Preload dependencies with items from skill usage
dependencies = {
  'Gathering' => {
    produces: [
      *tags['Raw Food'],
      'Amanita Mushrooms',
      'Cotton Boll',
      'Flax Stem',
      'Sunflower',
    ],
    uses: [],
  },
  'Hunting' => {
    produces: [
      *tags['Large Fish'],
      *tags['Medium Carcass'],
      *tags['Medium Fish'],
      *tags['Medium Leather Carcass'],
      *tags['Medium Wooly Carcass'],
      *tags['Small Carcass'],
      *tags['Small Fish'],
      *tags['Tiny Carcass'],
      *tags['Tiny Fur Carcass'],
      *tags['Tiny Leather Carcass'],
      'Bison Carcass',
    ],
    uses: [],
  },
  'Logging' => {
    produces: [
      *tags['Wood'],
    ],
    uses: [],
  },
  'Mining' => {
    produces: [
      *tags['Ore'],
      *tags['Rock'],
      'Sulfur',
    ],
    uses: [],
  },
}

# Process recipes to identify dependencies
recipes.each do |recipe|
  recipe['SkillNeeds'].each do |skill_info|
    skill = skill_info['Skill']
    dependency = dependencies[skill] ||= {
      produces: [],
      uses: [],
    }

    recipe['Variants'].each do |variant|
      variant['Ingredients'].each do |ingredient|
        if ingredient['IsSpecificItem']
          name = ingredient['Name']
          next if craft_items_to_ignore.include? name

          dependency[:uses] << name
        else
          tag = ingredient['Tag']
          next if craft_tags_to_ignore.include? tag

          tags[tag].each do |name|
            dependency[:uses] << name
          end
        end
      end

      variant['Products'].each do |product|
        name = product['Name']
        next if craft_items_to_ignore.include? name

        dependency[:produces] << name
      end
    end
  end
end

# Dedup and sort info
dependencies.each_value do |info|
  info[:produces].sort!.uniq!
  info[:uses].sort!.uniq!
end

#
# Which items are used but seemingly not produced?
#

accounted = \
  dependencies.map { _2[:produces] }.flatten.uniq

unaccounted = \
  dependencies.map { _2[:uses] }.flatten.uniq \
  - accounted \
  - items_anyone_can_make \
  - items_we_can_ignore

if unaccounted.any?
  puts '', '=> Used items not produces by a skill', *unaccounted.sort
end

if (obsolete = (items_we_can_ignore & accounted)).any?
  puts '', '=> Items we ignore, but are produced in recipes', *obsolete.sort
end

# Remove skill everyone has
dependencies.delete 'Self Improvement'

#
# Which skills have we seen or are we missing?
#

skills_known = categories.values.flatten
(dependencies.keys - skills_known).tap do |unknown|
  next unless unknown.any?

  puts '', '=> Unknown skills found', *unknown.sort
end
(skills_known - dependencies.keys).tap do |superfluous|
  next unless superfluous.any?

  puts '', '=> Superfluous skills found', *superfluous.sort
end

#
# Generate superskills
#

superskills = {}

# First all users
dependencies.sort.each do |skill, info|
  superskill = superskills[skill] ||= {}

  info[:produces].each do |name|
    dependencies
      .select { _2[:uses].include? name }
      .each_key do |user|
        (superskill[user] ||= []) << \
          "#{skill} produces #{name}"
      end
  end
end

# Then all producers to keep superskill explanation consistent
dependencies.sort.each do |skill, info| # rubocop:disable Style/CombinableLoops
  superskill = superskills[skill] ||= {}

  info[:uses].each do |name|
    dependencies
      .select { _2[:produces].include? name }
      .each_key do |producer|
        (superskill[producer] ||= []) << \
          "#{producer} produces #{name}"
      end
  end
end

# Render superskill HTML

renderer = Recipes::Renderer.new(
  templates_path: "#{__dir__}/templates/superskills",
  output_path: "#{__dir__}/superskills",
)

renderer.render_with_layout(
  'index',
  output: 'index.html',
  categories: categories,
  superskills: superskills,
)

puts '=> Superskill chart generated'

# puts '=> Dependencies', ::JSON.pretty_generate(dependencies)
