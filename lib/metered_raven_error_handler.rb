require 'sidekiq'
require 'raven/integrations/sidekiq'

module SidekiqMeteredExceptions
  class MeteredRavenErrorHandler < ::Raven::SidekiqErrorHandler
    def call(ex, original_context)
      ::Rails.logger.debug("MeteredRavenErrorHandler -- Error on Sidekiq job. Exception: #{ex.inspect} - Context: #{original_context.inspect}")

      # symbolize keys so we don't have to worry about strings vs. symbols
      context = original_context.deep_symbolize_keys

      # If the job context has a `retry_count` key, it tells us how many times the job has been REtried so far.
      # If it lacks this key, it has never been retried; this is the first attempt.
      retry_count = (context[:retry_count] || (context[:job] && context[:job][:retry_count])).try(:to_i) || 0

      # Is this a retryable job?
      is_retryable = context[:retry] || (context[:job] && context[:job][:retry])

      # We notify if this job has been retried at least once.
      # Someday we plan to make this number configurable.
      # If this isn't a retryable job, we notify even if this is the first attempt, because there will not be more attempts.
      if retry_count > 0 || !is_retryable
        ::Rails.logger.debug("MeteredRavenErrorHandler -- Current retry count: #{retry_count}. Notifying upstream...")

        super(ex, original_context)
      end
    end
  end
end


