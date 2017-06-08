# frozen_string_literal: true

# Workaround for issue in Ruby 2.4.0 with `def_delegators` -https://bugs.ruby-lang.org/issues/13107?next_issue_id=13106&prev_issue_id=13111
if RUBY_ENGINE=="ruby" && RUBY_VERSION=="2.4.0"
  class Rack::Test::Session
    def last_response
      @rack_mock_session.last_response
    end

    def last_request
      @rack_mock_session.last_request
    end
  end
end