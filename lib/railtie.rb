module SidekiqMeteredExceptions
  class Railtie < Rails::Railtie
    initializer 'sidekiq_metered_exceptions.add_middleware' do

      ::Sidekiq.configure_server do |config|
        config.server_middleware do |chain|
          chain.add ::SidekiqMeteredExceptions::Middleware
        end
      end

    end
  end
end
