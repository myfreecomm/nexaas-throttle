class DummyApp < Rails::Application
  config.eager_load = false
  config.active_support.test_order = :sorted
end

Rails.application.initialize!
