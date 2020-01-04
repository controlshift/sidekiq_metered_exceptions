require 'spec_helper'

class Rails
end

describe SidekiqMeteredExceptions::MeteredRavenErrorHandler do
  describe '#initialize' do
    it 'should not raise if errors_to_ignore_on_first_occurrence argument not provided' do
      expect { SidekiqMeteredExceptions::MeteredRavenErrorHandler.new }.not_to raise_error
    end

    it 'should set errors_to_ignore_on_first_occurrence if provided' do
      subject = SidekiqMeteredExceptions::MeteredRavenErrorHandler.new(errors_to_ignore_on_first_occurrence: [StandardError, RuntimeError])
      expect(subject.errors_to_ignore_on_first_occurrence).to eq([StandardError, RuntimeError])
    end
  end

  describe '#call' do
    before :each do
      allow(::Rails).to receive(:logger).and_return(double(debug: true))
    end

    context 'without any exceptions being reported on first occurrence' do
      let(:exception) { Exception.new }

      subject { SidekiqMeteredExceptions::MeteredRavenErrorHandler.new }

      it 'should capture exception if it is first occurrence' do
        expect(Raven).to receive(:capture_exception).with(exception, anything)

        subject.call(exception, { 'retry_count' => 0, 'retry' => true })
      end

      it 'should capture exception if has been retried at least once' do
        expect(Raven).to receive(:capture_exception).with(exception, anything)

        subject.call(exception, { 'retry_count' => 1, 'retry' => true })
      end
    end

    context 'with collection of exceptions being reported on first occurrence' do
      let(:exceptions_reported_on_first_occurrence) { [ZeroDivisionError, NameError] }

      subject { SidekiqMeteredExceptions::MeteredRavenErrorHandler.new(errors_to_ignore_on_first_occurrence: exceptions_reported_on_first_occurrence) }

      it 'should not capture exception if it is first occurrence and is included in errors_to_ignore_on_first_occurrence' do
        expect(Raven).not_to receive(:capture_exception)

        subject.call(ZeroDivisionError.new, { 'retry_count' => 0, 'retry' => true })
      end

      it 'should capture exception if it is first occurrence and is not included in errors_to_ignore_on_first_occurrence' do
        exception = StandardError.new
        expect(Raven).to receive(:capture_exception).with(exception, anything)

        subject.call(exception, { 'retry_count' => 0, 'retry' => true })
      end

      it 'should capture exception if it is first occurrence, it is not retryable and is included in errors_to_ignore_on_first_occurrence' do
        exception = ZeroDivisionError.new
        expect(Raven).to receive(:capture_exception).with(exception, anything)

        subject.call(exception, { 'retry_count' => 0, 'retry' => false })
      end

      it 'should capture exception if it has been retried at least once and is included in errors_to_ignore_on_first_occurrence' do
        exception = ZeroDivisionError.new
        expect(Raven).to receive(:capture_exception).with(exception, anything)

        subject.call(exception, { 'retry_count' => 1, 'retry' => true })
      end
    end
  end
end
