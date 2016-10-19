@named_test
Feature: an entire feature that uses a driver by tag

  Scenario: should use the named driver without being explicitly told
    Then Capybara should use the "named_test" driver
