require "spec_helper"

describe Nexaas::Throttle::Guardian do
  let(:request) { double("Request", env: {}) }
  let(:request_identifier_klass) { class_double("RequestIdentifier") }
  let(:request_identifier_instance) { double("RequestIdentifier") }
  let(:configuration) { double(request_identifier: request_identifier_klass, ignored_user_agents: nil) }
  let(:guardian) { described_class.new(request, configuration) }

  before do
    allow(request_identifier_klass).to receive(:new).
      with(request).and_return(request_identifier_instance)
    allow(request_identifier_instance).to receive(:token).
      and_return("42")
  end

  describe "#throttle!" do
    it "ignored with specific User-Agent request" do
      allow(request).to receive(:user_agent).and_return("Google v1.0")
      allow(configuration).to receive(:ignored_user_agents).and_return([/[Gg]oogle/])
      expect(guardian.throttle!).to be_nil
    end

    context "web request" do
      it "returns nil with an asset path" do
        allow(request).to receive(:path).and_return("/assets")
        expect(guardian.throttle!).to be_nil
      end

      it "returns nil with an asset related path" do
        allow(request).to receive(:path).and_return("/something/different.js")
        expect(guardian.throttle!).to be_nil
      end

      it "returns nil with an asset related path with a query string" do
        allow(request).to receive(:query_string).and_return("myparam=something")
        allow(request).to receive(:path).and_return("/something/different.js")
        expect(guardian.throttle!).to be_nil
      end

      it "does not inject token" do
        allow(request).to receive(:path).and_return("/assets")
        guardian.throttle!
        expect(request.env["nexaas.token"]).to be_nil
      end
    end

    context "json request" do
      before do
        allow(request).to receive(:path).and_return("/resource.json")
        allow(request).to receive(:media_type).and_return("application/json")
      end

      it "returns a consumer identifier" do
        expect(guardian.throttle!).to eq("42")
      end

      it "injects token" do
        guardian.throttle!
        expect(request.env["nexaas.token"]).to eq("42")
      end
    end

    context "xml request" do
      before do
        allow(request).to receive(:path).and_return("/resource.xml")
        allow(request).to receive(:media_type).and_return("application/xml")
      end

      it "returns a consumer identifier" do
        expect(guardian.throttle!).to eq("42")
      end

      it "injects token" do
        guardian.throttle!
        expect(request.env["nexaas.token"]).to eq("42")
      end
    end
  end

  describe "#track!" do
    it "ignored with specific User-Agent request" do
      allow(request).to receive(:user_agent).and_return("Google v1.0")
      allow(configuration).to receive(:ignored_user_agents).and_return([/[Gg]oogle/])
      expect(guardian.track!).to be_nil
    end

    context "web request" do
      it "returns nil with an asset path" do
        allow(request).to receive(:path).and_return("/assets")
        expect(guardian.track!).to be_nil
      end

      it "returns nil with an asset related path" do
        allow(request).to receive(:path).and_return("/something/different.js")
        expect(guardian.track!).to be_nil
      end

      it "returns nil with an asset related path with a query string" do
        allow(request).to receive(:query_string).and_return("myparam=something")
        allow(request).to receive(:path).and_return("/something/different.js")
        expect(guardian.track!).to be_nil
      end

      it "does not inject token" do
        allow(request).to receive(:path).and_return("/assets")
        guardian.track!
        expect(request.env["nexaas.token"]).to be_nil
      end
    end

    context "json request" do
      before do
        allow(request).to receive(:path).and_return("a/json/request")
        allow(request).to receive(:media_type).and_return("application/json")
      end

      it "returns a consumer identifier" do
        expect(guardian.track!).to be_truthy
      end

      it "injects token" do
        guardian.track!
        expect(request.env["nexaas.token"]).to eq("42")
      end
    end

    context "xml request" do
      before do
        allow(request).to receive(:path).and_return("a/xml/request")
        allow(request).to receive(:media_type).and_return("application/xml")
      end

      it "returns a consumer identifier" do
        expect(guardian.track!).to be_truthy
      end

      it "injects token" do
        guardian.track!
        expect(request.env["nexaas.token"]).to eq("42")
      end
    end
  end
end
