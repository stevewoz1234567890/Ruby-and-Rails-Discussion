# frozen_string_literal: true

module RackSecurity
  # Minimum Rack versions that include the coordinated security fixes shipped
  # on 2026-04-01 (Rack 3.1.21 / 3.2.6 / 2.2.23 per upstream changelog).
  #
  # Only +major.minor+ lines listed here are evaluated; other lines (e.g. 3.0.x)
  # must be checked against https://github.com/rack/rack/security/advisories
  class ReleaseFloor
    FLOORS = {
      [2, 2] => "2.2.23",
      [3, 1] => "3.1.21",
      [3, 2] => "3.2.6"
    }.freeze

    class Result
      attr_reader :code, :message

      def initialize(code, message)
        @code = code
        @message = message
      end

      def ok?
        @code == :ok
      end
    end

    def self.evaluate(version_string)
      new(version_string).evaluate
    end

    def initialize(version_string)
      @version = Gem::Version.new(version_string)
      segs = @version.segments
      @major_minor = [segs[0], segs[1]]
    end

    def evaluate
      floor_s = FLOORS[@major_minor]
      unless floor_s
        return Result.new(
          :unknown,
          "Rack #{@version}: no release floor configured for #{@major_minor.join(".")}.x — " \
          "see https://github.com/rack/rack/security/advisories"
        )
      end

      floor = Gem::Version.new(floor_s)
      if @version >= floor
        Result.new(:ok, "Rack #{@version} meets minimum #{floor} for #{@major_minor.join(".")}.x (2026-04-01 security batch).")
      else
        Result.new(
          :upgrade,
          "Rack #{@version} is below minimum #{floor} for #{@major_minor.join(".")}.x — upgrade rack in Gemfile / Gemfile.lock."
        )
      end
    end
  end
end
