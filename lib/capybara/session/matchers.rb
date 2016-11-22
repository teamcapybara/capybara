# frozen_string_literal: true
module Capybara
  module SessionMatchers
    ##
    # Asserts that the page has the given path.
    # By default this will compare against the path+query portion of the full url
    #
    # @!macro current_path_query_params
    #   @overload $0(string, options = {})
    #     @param string [String]           The string that the current 'path' should equal
    #   @overload $0(regexp, options = {})
    #     @param regexp [Regexp]           The regexp that the current 'path' should match to
    #   @option options [Numeric] :wait (Capybara.default_max_wait_time) Maximum time that Capybara will wait for the current path to eq/match given string/regexp argument
    #   @option options [Boolean] :url  (false)  Whether the compare should be done against the full url
    #   @option options [Boolean] :only_path (false)  Whether the compare should be done against just the path protion of the url
    # @raise [Capybara::ExpectationNotMet] if the assertion hasn't succeeded during wait time
    # @return [true]
    #
    def assert_current_path(path, options={})
      _verify_current_path(path,options) { |query| raise Capybara::ExpectationNotMet, query.failure_message unless query.resolves_for?(self) }
    end

    ##
    # Asserts that the page doesn't have the given path.
    #
    # @macro current_path_query_params
    # @raise [Capybara::ExpectationNotMet] if the assertion hasn't succeeded during wait time
    # @return [true]
    #
    def assert_no_current_path(path, options={})
      _verify_current_path(path,options) { |query| raise Capybara::ExpectationNotMet, query.negative_failure_message if query.resolves_for?(self) }
    end

    ##
    # Checks if the page has the given path.
    #
    # @macro current_path_query_params
    # @return [Boolean]
    #
    def has_current_path?(path, options={})
      assert_current_path(path, options)
    rescue Capybara::ExpectationNotMet
      return false
    end

    ##
    # Checks if the page doesn't have the given path.
    #
    # @macro current_path_query_params
    # @return [Boolean]
    #
    def has_no_current_path?(path, options={})
      assert_no_current_path(path, options)
    rescue Capybara::ExpectationNotMet
      return false
    end

    private

    def _verify_current_path(path, options)
      query = Capybara::Queries::CurrentPathQuery.new(path, options)
      document.synchronize(query.wait) do
        yield(query)
      end
      return true
    end
  end
end
