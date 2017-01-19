require 'helper'

class TestSidekiqMeteredExceptions < Minitest::Test
  describe 'middleware' do
    before do
      @exception = Exception.new
      @middleware = SidekiqMeteredExceptions::MeteredRavenErrorHandler.new
    end

    # todo: figure out how to use minitest.


  end
end
