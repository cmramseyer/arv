ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "dotenv/load" # Load runtime configuration before Rails boots.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
