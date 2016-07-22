require "spec_helper"

describe Nexaas::Throttle::Engine do
  let(:middlewares) { DummyApp.config.middleware.middlewares }

  it "appends Rack::Attack middleware" do
    expect(middlewares).to include(Rack::Attack)
  end

  it "appends Rack::Attack::RateLimit middleware" do
    expect(middlewares).to include(Rack::Attack::RateLimit)
  end
end
