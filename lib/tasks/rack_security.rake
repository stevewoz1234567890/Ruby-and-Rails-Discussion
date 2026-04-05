# frozen_string_literal: true

# Rails: copy lib/rack_security/ and this file into your app, or add this repo's
# lib/ to your load path, then:
#   bundle exec rake rack:security_check

namespace :rack do
  desc "Check loaded Rack gem against 2026-04-01 security release floors"
  task security_check: :environment do
    lib = Rails.root.join("lib")
    $LOAD_PATH.unshift(lib.to_s) unless $LOAD_PATH.include?(lib.to_s)
    require "rack_security/release_floor"

    spec = Gem.loaded_specs["rack"]
    unless spec
      abort "rack is not loaded. Run: bundle exec rake rack:security_check"
    end

    result = RackSecurity::ReleaseFloor.evaluate(spec.version.to_s)
    puts result.message
    abort if result.code == :upgrade
  end
end
