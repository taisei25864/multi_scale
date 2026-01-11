require "yaml"
require "fileutils"

require_relative "nutribalance/cli"
require_relative "nutribalance/store"
require_relative "nutribalance/nutrition"

module Nutribalance
  APP_DIR = File.join(Dir.home, ".nutribalance")
  STATE_PATH = File.join(APP_DIR, "state.yml")
end
