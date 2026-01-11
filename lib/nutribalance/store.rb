require "date"

module Nutribalance
  class Store
    def initialize(state_path: STATE_PATH)
      @state_path = state_path
      FileUtils.mkdir_p(File.dirname(@state_path))
    end

    def load_state
      return {"meals" => {}} unless File.exist?(@state_path)
      YAML.load_file(@state_path) || {"meals" => {}}
    end

    def save_state(state)
      File.write(@state_path, state.to_yaml)
    end

    def add_items(meal:, items:)
      state = load_state
      state["date"] ||= Date.today.to_s
      state["meals"] ||= {}
      state["meals"][meal] ||= []

      items.each do |token|
        key, grams = token.split(":")
        raise ArgumentError, "Invalid item format: #{token}" unless key && grams
        state["meals"][meal] << {"food" => key, "grams" => grams.to_f}
      end

      save_state(state)
    end

    def reset!
      File.delete(@state_path) if File.exist?(@state_path)
    end
  end
end
