require "spec_helper"

describe Nexaas::Throttle::Controller do
  let(:request) { double("Request") }
  let(:controller) { described_class.new(request) }

  describe "#evaluate!" do
    let(:request_identifier_klass) { class_double("RequestIdentifier") }
    let(:request_identifier_instance) { double("RequestIdentifier") }

    before do
      allow(request_identifier_klass).to receive(:new).
        and_return(request_identifier_instance)
      allow(request_identifier_instance).to receive(:token).
        and_return("42")
    end

    context "web request" do
      it "returns nil with an asset request" do
        allow(request).to receive(:path).and_return("/assets")
        expect(controller.evaluate!(request_identifier_klass)).to be_nil
      end

      it "returns nil with non api request" do
        allow(request).to receive(:path).and_return("a/web/request")
        allow(request).to receive(:media_type).and_return("text/html")
        expect(controller.evaluate!(request_identifier_klass)).to be_nil
      end
    end

    context "json request" do
      it "returns a consumer identifier" do
        allow(request).to receive(:path).and_return("a/json/request")
        allow(request).to receive(:media_type).and_return("application/json")
        expect(controller.evaluate!(request_identifier_klass)).to eq("42")
      end
    end

    context "xml request" do
      it "returns a consumer identifier" do
        allow(request).to receive(:path).and_return("a/xml/request")
        allow(request).to receive(:media_type).and_return("application/xml")
        expect(controller.evaluate!(request_identifier_klass)).to eq("42")
      end
    end
  end
end
