require "spec_helper"

describe Nexaas::Throttle::Middleware do
  include Rack::Test::Methods

  def app
    Rack::Builder.new {
      use Nexaas::Throttle::Middleware
      run lambda { |env| [200, {}, ["It works!"]] }
    }.to_app
  end

  let(:configuration) { Nexaas::Throttle.configuration }

  describe "nexaas/throttle" do
    context "json" do
      it "throttles json requests" do
        3.times { get "/hello/world", {}, {"Content-Type" => "application/json"} }
        expect(last_response.status).to eq(429)
      end

      it "adds Retry-After header" do
        3.times { get "/hello/world", {}, {"Content-Type" => "application/json"} }
        expect(last_response.headers["Retry-After"]).to eq("60")
      end

      it "adds X-RateLimit-Limit" do
        2.times { get "/hello/world", {}, {"Content-Type" => "application/json"} }
        expect(last_response.headers["X-RateLimit-Limit"]).to eq("2")
      end

      it "adds X-RateLimit-Remaining" do
        1.times { get "/hello/world", {}, {"Content-Type" => "application/json"} }
        expect(last_response.headers["X-RateLimit-Remaining"]).to eq("1")
      end

      it "adds X-RateLimit-Reset" do
        allow(Time).to receive(:now).and_return("2016-08-04 15:50:00 UTC".to_time(:utc))
        1.times { get "/hello/world", {}, {"Content-Type" => "application/json"} }
        expect(last_response.headers["X-RateLimit-Reset"]).to eq("2016-08-04T15:51:00Z")
      end
    end

    context "xml" do
      it "throttles xml requests" do
        3.times { get "/hello/world", {}, {"Content-Type" => "application/xml"} }
        expect(last_response.status).to eq(429)
      end

      it "adds Retry-After header" do
        3.times { get "/hello/world", {}, {"Content-Type" => "application/xml"} }
        expect(last_response.headers["Retry-After"]).to eq("60")
      end

      it "adds X-RateLimit-Limit" do
        2.times { get "/hello/world", {}, {"Content-Type" => "application/xml"} }
        expect(last_response.headers["X-RateLimit-Limit"]).to eq("2")
      end

      it "adds X-RateLimit-Remaining" do
        1.times { get "/hello/world", {}, {"Content-Type" => "application/xml"} }
        expect(last_response.headers["X-RateLimit-Remaining"]).to eq("1")
      end

      it "adds X-RateLimit-Reset" do
        allow(Time).to receive(:now).and_return("2016-08-04 15:50:00 UTC".to_time(:utc))
        1.times { get "/hello/world", {}, {"Content-Type" => "application/xml"} }
        expect(last_response.headers["X-RateLimit-Reset"]).to eq("2016-08-04T15:51:00Z")
      end
    end

    context "web" do
      it "does not throttle web requests" do
        3.times { get "/hello/world" }
        expect(last_response.status).not_to eq(429)
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
