# frozen_string_literal: true
require "yaml"

module Nutribalance
  class FoodsRepo
    def initialize(foods_path:)
      @foods_path = foods_path
    end

    def all_foods
      load_doc.fetch("foods", {})
    end

    def add_food!(key:, label:, per_100g:, overwrite: false)
      raise ArgumentError, "key is empty" if key.to_s.strip.empty?
      raise ArgumentError, "label is empty" if label.to_s.strip.empty?
      validate_per_100g!(per_100g)

      doc = load_doc
      foods = doc["foods"] ||= {}

      if foods.key?(key) && !overwrite
        raise ArgumentError, "Food key already exists: #{key} (use --overwrite to replace)"
      end

      foods[key] = {
        "label" => label,
        "per_100g" => per_100g.transform_values(&:to_f)
      }

      File.write(@foods_path, doc.to_yaml)
      @foods_path
    end

    private

    def load_doc
      unless File.exist?(@foods_path)
        raise ArgumentError, "foods.yml not found: #{@foods_path}"
      end
      YAML.load_file(@foods_path) || {}
    end

    def validate_per_100g!(h)
      raise ArgumentError, "per_100g must be a Hash" unless h.is_a?(Hash)
      raise ArgumentError, "per_100g is empty" if h.empty?
      h.each do |k, v|
        f = Float(v)
        raise ArgumentError, "negative value for #{k}" if f < 0
      rescue ArgumentError, TypeError
        raise ArgumentError, "invalid numeric for #{k}: #{v}"
      end
    end
  end
end
