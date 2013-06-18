require 'sidekiq'
require 'middleware'

::Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add ::SidekiqMeteredExceptions::Middleware
  end
end