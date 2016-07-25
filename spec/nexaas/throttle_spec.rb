require "spec_helper"

describe Nexaas::Throttle do
  it "has a version number" do
    expect(Nexaas::Throttle::VERSION).not_to be nil
  end

  describe ".configuration" do
    it "returns a Nexaas::Throttle::Configuration instance" do
      expect(Nexaas::Throttle.configuration).to be_a(Nexaas::Throttle::Configuration)
    end
  end

  describe ".configure" do
    it "sets configuration options" do
      expect { |c| Nexaas::Throttle.configure(&c) }.to yield_with_args
    end

    it "checks :period option presence" do
      expect { Nexaas::Throttle.configure { |c| c.period = nil } }.to raise_error(ArgumentError)
    end

    it "checks :limit option presence" do
      expect { Nexaas::Throttle.configure { |c| c.limit = nil } }.to raise_error(ArgumentError)
    end

    it "checks :request_identifier option presence" do
      expect { Nexaas::Throttle.configure { |c| c.request_identifier = nil } }.to raise_error(ArgumentError)
    end

    it "checks :redis_options option presence" do
      Nexaas::Throttle.configuration.request_identifier = Class.new
      expect { Nexaas::Throttle.configure { |c| c.redis_options = nil } }.to raise_error(ArgumentError)
      expect { Nexaas::Throttle.configure { |c| c.redis_options = {} } }.to raise_error(ArgumentError)
    end
  end
end
