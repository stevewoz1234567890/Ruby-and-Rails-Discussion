#!/usr/bin/env ruby
# frozen_string_literal: true

# Compare the resolved Rack version to release floors for the 2026-04-01 batch.
#
# Run from your application root (where Gemfile.lock lives):
#   bundle exec ruby script/check_rack_security.rb
#
# Or copy lib/rack_security/*.rb + this script into your repo and adjust paths.

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "rack_security/release_floor"

def rack_version_from_lockfile
  require "bundler"
  root = Bundler.root
  path = root.join("Gemfile.lock")
  return nil unless path.file?

  lock = Bundler::LockfileParser.new(Bundler.read_file(path))
  lock.specs.find { |s| s.name == "rack" }&.version&.to_s
end

def rack_version_from_loaded_spec
  Gem.loaded_specs["rack"]&.version&.to_s
end

version = rack_version_from_loaded_spec || rack_version_from_lockfile

if version.nil?
  warn "Could not determine rack version."
  warn "Run from a directory with Gemfile.lock, ideally: bundle exec ruby script/check_rack_security.rb"
  exit 2
end

result = RackSecurity::ReleaseFloor.evaluate(version)
puts result.message
exit(1) if result.code == :upgrade
exit(0)
