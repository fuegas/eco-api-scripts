#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'nokogiri'

laws_json_path = "#{__dir__}/tmp/laws.json"

json = []
begin
  json = JSON.parse ::File.read laws_json_path
rescue JSON::ParserError => e
  puts "Failed to read #{laws_json_path}: #{e}"
  exit 1
end

law = json.first
puts "Law '#{law['Name']}' by #{law['Creator']} (#{law['Id']})"
puts Nokogiri::XML(law['Description'])

