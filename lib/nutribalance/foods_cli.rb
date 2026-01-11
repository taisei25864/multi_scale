# frozen_string_literal: true
require "thor"
require_relative "foods_repo"

module Nutribalance
  class FoodsCLI < Thor
    desc "add --key KEY --label LABEL --per100g k=v ...", "Add a food to data/foods.yml"
    option :key, required: true, type: :string
    option :label, required: true, type: :string
    option :per100g, required: true, type: :array, banner: "nutrient=value nutrient=value ..."
    option :overwrite, type: :boolean, default: false
    def add
      per = parse_kv_list(options[:per100g])
      repo = FoodsRepo.new(foods_path: foods_path)

      path = repo.add_food!(
        key: options[:key],
        label: options[:label],
        per_100g: per,
        overwrite: options[:overwrite]
      )
      puts "Added: #{options[:key]} -> #{path}"
    end

    desc "list", "List all known food keys from data/foods.yml"
    def list
      repo = FoodsRepo.new(foods_path: foods_path)
      repo.all_foods.keys.sort.each { |k| puts k }
    end

    desc "show --key KEY", "Show a food detail from data/foods.yml"
    option :key, required: true, type: :string
    def show
      repo = FoodsRepo.new(foods_path: foods_path)
      food = repo.all_foods[options[:key]]
      raise ArgumentError, "Unknown key: #{options[:key]}" unless food
      puts({ options[:key] => food }.to_yaml)
    end

    desc "search QUERY", "Search food keys by substring in data/foods.yml"
    def search(query)
      repo = FoodsRepo.new(foods_path: foods_path)
      repo.all_foods.keys.sort.select { |k| k.include?(query) }.each { |k| puts k }
    end

    private

    def foods_path
      File.expand_path("../../data/foods.yml", __dir__)
    end

    def parse_kv_list(arr)
      out = {}
      arr.each do |token|
        k, v = token.split("=", 2)
        raise ArgumentError, "Invalid per100g token: #{token} (use nutrient=value)" if k.nil? || v.nil?
        out[k] = v
      end
      out
    end
  end
end
