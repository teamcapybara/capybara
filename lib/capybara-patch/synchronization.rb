require "capybara-patch/wait_factory"

module Capybara

  module SynchronizationAccess

    # Optional configuration for element synchronization.
    attr_accessor :synchronize_delay,       # Amount of time to wait in between attempts.
    :synchronize_timeout,     # Amount of time to timeout a block.
    :synchronize_log_pathname # Pathname to write a synchronization log.

  end

  module SynchronizeWithWait

    ##
    #
    # This method is Capybara's primary defence agains asynchronicity
    # problems. It works by attempting to run a given block of code until it
    # succeeds. The exact behaviour of this method depends on a number of
    # factors. Basically there are certain exceptions which, when raised
    # from the block, instead of bubbling up, are caught, and the block is
    # re-run.
    #
    # Certain drivers, such as RackTest, have no support for aynchronous
    # processes, these drivers run the block, and any error raised bubbles up
    # immediately. This allows faster turn around in the case where an
    # expectation fails.
    #
    # Only exceptions that are {Capybara::ElementNotFound} or any subclass
    # thereof cause the block to be rerun. Drivers may specify additional
    # exceptions which also cause reruns. This usually occurs when a node is
    # manipulated which no longer exists on the page. For example, the
    # Selenium driver specifies
    # `Selenium::WebDriver::Error::ObsoleteElementError`.
    #
    # As long as any of these exceptions are thrown, the block is re-run,
    # until a certain amount of time passes. The amount of time defaults to
    # {Capybara.default_wait_time} and can be overriden through the `seconds`
    # argument.
    #
    # @param [Integer] seconds          Number of seconds to retry this block
    # @return [Object]                  The result of the given block
    #
    def synchronize(seconds = Capybara.default_wait_time, options = {})
      # If this element is unsynchronized, or if the driver does not support
      # waiting, immediately yield to the block. No exceptions will be
      # rescued, nothing will be retried.
      return(yield) if @unsynchronized or not driver.wait?

      wait = WaitFactory.new(driver, seconds).build
      wait.until do |attempt|
        # If this isn't the first attempt, reload the element (if enabled).
        reload if Capybara.automatic_reload and attempt > 1
        yield
      end
    end

  end

  module Node

    class Base

      include SynchronizeWithWait

    end

    extend SynchronizationAccess

  end

end
