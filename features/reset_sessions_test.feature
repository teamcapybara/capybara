Feature: Reset sessions test

  @no_reset_sessions
  Scenario: Scenario that doesn't reset session
    When I visit the root page
    Then I should see "Hello world!"

  Scenario: Scenario that resets session
    Then I should see "Hello world!"

  Scenario: Scenario that tests that session is reset
    Then I should be on '' url
