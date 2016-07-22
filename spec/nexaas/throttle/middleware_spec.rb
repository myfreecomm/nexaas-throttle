require "spec_helper"

describe Nexaas::Throttle::Middleware, type: :request do
  let(:configuration) { Nexaas::Throttle.configuration }

  describe ".configuration" do
    it "returns Nexaas::Throttle::Configuration" do
      expect(described_class.configuration).to be(configuration)
    end
  end

  describe "nexass/throttle" do
    pending
  end
end
