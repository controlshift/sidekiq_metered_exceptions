require 'sidekiq'
require 'raven/integrations/sidekiq'

module SidekiqMeteredExceptions
  class MeteredRavenErrorHandler < ::Raven::SidekiqErrorHandler
    def call(ex, context)
      ::Rails.logger.debug("MeteredRavenErrorHandler -- Error on Sidekiq job. Exception: #{ex.inspect} - Context: #{context.inspect}")

      retry_count = (context['retry_count'] || (context[:job] && context[:job]['retry_count'])).try(:to_i)

      if !retry_count.nil? && retry_count > 0
        ::Rails.logger.debug("MeteredRavenErrorHandler -- Current retry count: #{retry_count}. Notifying upstream...")

        super(ex, context)
      end
    end
  end
end


