require 'sidekiq'
require 'active_support/core_ext/hash'  # for deep_symbolize_keys
require 'raven/integrations/sidekiq'

module SidekiqMeteredExceptions
  class MeteredRavenErrorHandler < ::Raven::SidekiqErrorHandler
    attr_reader :errors_to_ignore_on_first_occurrence

    def initialize(errors_to_ignore_on_first_occurrence: [])
      @errors_to_ignore_on_first_occurrence = errors_to_ignore_on_first_occurrence
    end

    def call(ex, original_context)
      ::Rails.logger.debug("MeteredRavenErrorHandler -- Error on Sidekiq job. Exception: #{ex.inspect} - Context: #{original_context.inspect}")

      # symbolize keys so we don't have to worry about strings vs. symbols
      context = original_context.deep_symbolize_keys

      # If the job context has a `retry_count` key, it tells us how many times the job has been REtried so far.
      # If it lacks this key, it has never been retried; this is the first attempt.
      retry_count = (context[:retry_count] || (context[:job] && context[:job][:retry_count])).try(:to_i) || 0

      # Is this a retryable job?
      is_retryable = context[:retry] || (context[:job] && context[:job][:retry])

      # We notify to Sentry unless:
      # Is not one of the errors that should be ignored on first occurrence
      #             AND
      # This job has not been retried at least once
      #             AND
      # Sidekiq is automatically retrying the job
      #
      unless errors_to_ignore_on_first_occurrence.include?(ex.class) && retry_count < 1 && is_retryable
        ::Rails.logger.debug("MeteredRavenErrorHandler -- Current retry count: #{retry_count}. Notifying upstream...")

        super(ex, original_context)
      end
    end
  end
end


