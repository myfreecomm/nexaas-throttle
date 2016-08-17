require "spec_helper"

describe Nexaas::Throttle::Configuration do
  let(:configuration) { described_class.new }

  describe ".new" do
    it "initializes @throttle" do
      expect(configuration.throttle).to be_truthy
    end

    it "initializes @track" do
      expect(configuration.track).to be_truthy
    end

    it "initializes @period" do
      expect(configuration.period).to eq(1.minute)
    end

    it "initializes @limit" do
      expect(configuration.limit).to eq(60)
    end

    it "initializes @request_identifier" do
      expect(configuration.request_identifier).to be_nil
    end

    it "initializes @redis_options" do
      expect(configuration.redis_options).to eq(
        host: "localhost",
        port: 6379,
        db: 0,
        namespace: "nexaas:throttle"
      )
    end
  end

  describe "#throttleable?" do
    it "returns true when requests are throttleable" do
      configuration.throttle = true
      expect(configuration.throttleable?).to be_truthy
    end

    it "returns false when requests are not throttleable" do
      configuration.throttle = false
      expect(configuration.throttleable?).to be_falsey
    end
  end

  describe "#trackable?" do
    it "returns true when requests are trackable" do
      configuration.track = true
      expect(configuration.trackable?).to be_truthy
    end

    it "returns false when requests are not trackable" do
      configuration.track = false
      expect(configuration.trackable?).to be_falsey
    end
  end

  describe "#check!" do
    it "requires period to be configured" do
      configuration.period = nil
      expect { configuration.check! }.to raise_error(ArgumentError)
    end

    it "requires limit to be configured" do
      configuration.limit = nil
      expect { configuration.check! }.to raise_error(ArgumentError)
    end

    it "requires request_identifier to be configured" do
      configuration.request_identifier = nil
      expect { configuration.check! }.to raise_error(ArgumentError)
    end

    it "requires redis_options to be configured" do
      configuration.redis_options = {}
      expect { configuration.check! }.to raise_error(ArgumentError)
    end
  end

  describe "#redis_options=" do
    it "merges with default redis options" do
      configuration.redis_options = { namespace: "another:namespace" }
      expect(configuration.redis_options).to eq(
        host: "localhost",
        port: 6379,
        db: 0,
        namespace: "another:namespace"
      )
    end
  end
end
