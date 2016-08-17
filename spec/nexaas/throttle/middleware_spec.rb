require "spec_helper"

describe Nexaas::Throttle::Middleware do
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use Nexaas::Throttle::Middleware
      run ->(_) { [200, {}, ["It works!"]] }
    end.to_app
  end

  let(:configuration) { Nexaas::Throttle.configuration }

  describe "nexaas/throttle" do
    after do
      configuration.throttle = true
    end

    context "json" do
      context "when throttleable" do
        it "throttles json requests" do
          3.times { get "/hello/world", {}, "Content-Type" => "application/json" }
          expect(last_response.status).to eq(429)
        end

        it "adds Retry-After header" do
          3.times { get "/hello/world", {}, "Content-Type" => "application/json" }
          expect(last_response.headers["Retry-After"]).to eq("60")
        end

        it "adds X-RateLimit-Limit" do
          2.times { get "/hello/world", {}, "Content-Type" => "application/json" }
          expect(last_response.headers["X-RateLimit-Limit"]).to eq("2")
        end

        it "adds X-RateLimit-Remaining" do
          1.times { get "/hello/world", {}, "Content-Type" => "application/json" }
          expect(last_response.headers["X-RateLimit-Remaining"]).to eq("1")
        end

        it "adds X-RateLimit-Reset" do
          allow(Time).to receive(:now).and_return("2016-08-04 15:50:00 UTC".to_time(:utc))
          1.times { get "/hello/world", {}, "Content-Type" => "application/json" }
          expect(last_response.headers["X-RateLimit-Reset"]).to eq("2016-08-04T15:51:00Z")
        end
      end

      context "when not throttleable" do
        it "does not add throttle requests" do
          configuration.throttle = false
          3.times { get "/hello/world", {}, "Content-Type" => "application/json" }
          expect(last_response.status).to eq(200)
        end
      end
    end

    context "xml" do
      context "when throttleable" do
        it "throttles xml requests" do
          3.times { get "/hello/world", {}, "Content-Type" => "application/xml" }
          expect(last_response.status).to eq(429)
        end

        it "adds Retry-After header" do
          3.times { get "/hello/world", {}, "Content-Type" => "application/xml" }
          expect(last_response.headers["Retry-After"]).to eq("60")
        end

        it "adds X-RateLimit-Limit" do
          2.times { get "/hello/world", {}, "Content-Type" => "application/xml" }
          expect(last_response.headers["X-RateLimit-Limit"]).to eq("2")
        end

        it "adds X-RateLimit-Remaining" do
          1.times { get "/hello/world", {}, "Content-Type" => "application/xml" }
          expect(last_response.headers["X-RateLimit-Remaining"]).to eq("1")
        end

        it "adds X-RateLimit-Reset" do
          allow(Time).to receive(:now).and_return("2016-08-04 15:50:00 UTC".to_time(:utc))
          1.times { get "/hello/world", {}, "Content-Type" => "application/xml" }
          expect(last_response.headers["X-RateLimit-Reset"]).to eq("2016-08-04T15:51:00Z")
        end
      end

      context "when not throttleable" do
        it "does not add throttle requests" do
          configuration.throttle = false
          3.times { get "/hello/world", {}, "Content-Type" => "application/xml" }
          expect(last_response.status).to eq(200)
        end
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

  describe "nexaas/track" do
    let(:counter) { double("counter", inc: true) }

    before do
      configuration.track = true
      configuration.throttle = false

      ActiveSupport::Notifications.subscribe("rack.attack") do |_, _, _, _, request|
        if request.env["rack.attack.matched"] == "nexaas/track" && request.env["rack.attack.match_type"] == :track
          counter.inc
        end
      end
    end

    context "json" do
      context "when trackable" do
        it "tracks json requests" do
          3.times { get "/hello/world", {}, "Content-Type" => "application/json" }
          expect(counter).to have_received(:inc).exactly(3).times
        end
      end

      context "when not trackable" do
        it "does not track requests" do
          configuration.track = false
          3.times { get "/hello/world", {}, "Content-Type" => "application/json" }
          expect(counter).not_to have_received(:inc)
        end
      end
    end

    context "xml" do
      context "when trackable" do
        it "tracks xml requests" do
          3.times { get "/hello/world", {}, "Content-Type" => "application/xml" }
          expect(counter).to have_received(:inc).exactly(3).times
        end
      end

      context "when not trackable" do
        it "does not track requests" do
          configuration.track = false
          3.times { get "/hello/world", {}, "Content-Type" => "application/xml" }
          expect(counter).not_to have_received(:inc)
        end
      end
    end

    context "web" do
      it "does not track web requests" do
        3.times { get "/hello/world" }
        expect(counter).not_to have_received(:inc)
      end
    end

    context "assets" do
      it "does not track assets requests" do
        3.times { get "/assets/image.png" }
        expect(counter).not_to have_received(:inc)
      end
    end
  end
end
