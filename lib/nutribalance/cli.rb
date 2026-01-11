require_relative "foods_cli"
require "thor"
require "tty-table"

module Nutribalance
  class CLI < Thor
    desc "foods SUBCOMMAND ...ARGS", "Manage food database (add/list/show)"
    subcommand "foods", Nutribalance::FoodsCLI
    desc "add --meal MEAL food:grams ...", "Add meal items (e.g., shokupan:60 yogurt_plain:100)"
    option :meal, required: true, enum: %w[breakfast lunch dinner]
    def add(*items)
      store = Store.new
      store.add_items(meal: options[:meal], items: items)
      puts "Saved: #{options[:meal]} #{items.join(' ')}"
    end

    desc "report", "Show today report and remaining targets"
    def report
      store = Store.new
      report = Nutrition.new(store).daily_report
      puts TTY::Table.new(report[:headers], report[:rows]).render(:unicode)
      puts
      puts TTY::Table.new(report[:remaining_headers], report[:remaining_rows]).render(:unicode)
    end

    desc "reset", "Reset today state"
    def reset
      Store.new.reset!
      puts "Reset done."
    end

    def self.exit_on_failure?
      true
    end
  end
end
