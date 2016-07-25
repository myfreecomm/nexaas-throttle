require "spec_helper"

describe Nexaas::Throttle::Engine do
  let(:middlewares) { DummyApp.config.middleware.middlewares }

  it "appends Nexaas::Throttle::Middleware" do
    expect(middlewares).to include(Nexaas::Throttle::Middleware)
  end
end
