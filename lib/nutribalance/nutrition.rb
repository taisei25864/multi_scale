require_relative "foods_repo"

module Nutribalance
  class Nutrition
    def initialize(store,
                   foods_path: File.join(__dir__, "../../data/foods.yml"),
                   profile_path: File.join(__dir__, "../../config/profile.yml"),
                   ratios_path: File.join(__dir__, "../../config/meal_ratios.yml"),
                   profile_key: "default_adult")
      @store = store
      @foods_repo = FoodsRepo.new(default_foods_path: foods_path)
      @foods = @foods_repo.all_foods
      @profile = YAML.load_file(profile_path).fetch("profiles").fetch(profile_key)
      @ratios = YAML.load_file(ratios_path).fetch("ratios")
    end

    def daily_report
      state = @store.load_state
      meals = state.fetch("meals", {})

      totals = sum_meals(meals)
      targets = @profile.fetch("targets")
      remaining = subtract(targets, totals)

      {
        headers: ["nutrient", "total"],
        rows: totals.map { |k, v| [k, round(v)] },
        remaining_headers: ["nutrient", "remaining(>0) / over(<0)"],
        remaining_rows: remaining.map { |k, v| [k, round(v)] }
      }
    end

    private

    def sum_meals(meals)
      totals = Hash.new(0.0)
      meals.each_value do |items|
        items.each do |it|
          food = @foods.fetch(it.fetch("food"))
          grams = it.fetch("grams").to_f
          per_100g = food.fetch("per_100g")
          per_100g.each do |nutrient, val|
            totals[nutrient] += val.to_f * grams / 100.0
          end
        end
      end
      totals
    end

    def subtract(targets, totals)
      out = {}
      targets.each do |k, v|
        out[k] = v.to_f - totals.fetch(k, 0.0)
      end
      out
    end

    def round(x) = (x * 10).round / 10.0
  end
end
