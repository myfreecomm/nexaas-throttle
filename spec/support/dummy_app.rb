class DummyApp < Rails::Application
  config.eager_load = false
  config.active_support.test_order = :sorted
end

DummyApp.secrets.secret_key_base = "fake-my-secret"
DummyApp.initialize!
