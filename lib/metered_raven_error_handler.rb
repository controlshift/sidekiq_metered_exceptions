require 'sidekiq'
require 'raven/integrations/sidekiq'

module SidekiqMeteredExceptions
  class MeteredRavenErrorHandler < ::Raven::Sidekiq
    def call(ex, context)
      retry_count = (context['retry_count'] || (context['job'] && context['job']['retry_count']))

      if retry_count.nil? || retry_count > 1
        super(ex, context)
      end
    end
  end
end


