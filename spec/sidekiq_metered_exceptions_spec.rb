require 'spec_helper'

describe SidekiqMeteredExceptions::MeteredRavenErrorHandler do
  # describe 'initialize' do
  #   it 'should set errors_to_ignore_on_first_occurrence if provided' do
  #     @middleware = SidekiqMeteredExceptions::MeteredRavenErrorHandler.new(errors_to_ignore_on_first_occurrence: [StandardError, RuntimeError])
  #     _(@middleware.errors_to_ignore_on_first_occurrence).must_equal [StandardError, RuntimeError]
  #   end

  # end

  # describe 'call' do
  #   it 'should capture exception if has been retried at least once' do
  #     exception = Exception.new
  #     middleware = SidekiqMeteredExceptions::MeteredRavenErrorHandler.new

  #     Raven.stub(:capture_exception, exception) do
  #       middleware.call(exception, { 'retry_count' => 1, 'retry' => true })
  #     end
  #   end
  # end
end
