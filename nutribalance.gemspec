# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "nutribalance"
  spec.version = "0.1.0"

  spec.summary = "Nutrition balance CLI"
  spec.authors = ["taisei"]

  spec.files = Dir["lib/**/*", "bin/*", "data/**/*", "config/**/*", "README.md"]
  spec.bindir = "bin"
  spec.executables = ["nutribalance"]
  spec.require_paths = ["lib"]

  # 実行に必要な依存
  spec.add_dependency "thor"
  spec.add_dependency "tty-table"
  # spec.add_dependency "tty-prompt"  # 使うなら

  # 開発用（任意）
  # spec.add_development_dependency "rspec"
end
