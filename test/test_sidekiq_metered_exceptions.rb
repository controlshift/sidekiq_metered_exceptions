require 'helper'

class TestSidekiqMeteredExceptions < Minitest::Test
  describe 'middleware' do
    before do
      @middleware = SidekiqMeteredExceptions::Middleware.new
    end

    it 'should propagate exception if there is no retry count' do
      assert_raises(Exception) { @middleware.call('worker', {}, 'queue') { raise Exception.new }}
    end

    it 'should propagate the exception if the retry count is greater than zero' do
      assert_raises(Exception) { @middleware.call('worker', {'retry_count' => 1}, 'queue') { raise Exception.new }}
    end

    it 'should not propagate exception if the retry count is zero' do
      @middleware.call('worker', {'retry_count' => 0}, 'queue') { raise Exception.new }
    end

    it "should not interfere with successful jobs" do
      assert( @middleware.call('worker', {'retry_count' =>1}, 'queue') { return true })
    end

  end
end
