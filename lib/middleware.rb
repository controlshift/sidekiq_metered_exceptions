module SidekiqMeteredExceptions
  class Middleware

    def call(worker, job, queue)
      begin
        yield
      rescue StandardError => ex
        # do not notify on the first occurrence of an exception
        raise(ex) if job['retry_count'] == nil || job['retry_count'] > 0
      end
    end
  end
end
