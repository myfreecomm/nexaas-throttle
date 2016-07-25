require "spec_helper"

describe Nexaas::Throttle::Middleware do
  include Rack::Test::Methods

  def app
    Rack::Builder.new {
      use Nexaas::Throttle::Middleware
      run lambda {|env| [200, {}, ["It works!"]]}
    }.to_app
  end

  let(:configuration) { Nexaas::Throttle.configuration }

  describe ".configuration" do
    it "returns Nexaas::Throttle::Configuration" do
      expect(described_class.configuration).to be(configuration)
    end
  end

  describe "nexass/throttle" do
    context "json" do
      it "throttles json requests" do
        3.times { get "/hello/world", {}, {"Content-Type" => "application/json"} }
        expect(last_response.status).to eq(429)
      end
    end

    context "xml" do
      it "throttles xml requests" do
        3.times { get "/hello/world", {}, {"Content-Type" => "application/xml"} }
        expect(last_response.status).to eq(429)
      end
    end

    context "web" do
      it "does not throttle web requests" do
        3.times { get "/hello/world" }
        expect(last_response.status).to eq(200)
      end
    end

    context "assets" do
      it "does not throttle assets requests" do
        3.times { get "/assets/image.png" }
        expect(last_response.status).not_to eq(429)
      end
    end
  end
end
