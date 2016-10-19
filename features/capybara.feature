Feature: Capybara's cucumber integration
  In order to integrate with the lovely plain text testing framework
  As Capybara
  I want to integrate successfully with Cucumber

  Scenario: hello world
    When I visit the root page
    Then I should see "Hello world!"

  @javascript
  Scenario: javascript tag should use Capybara.javascript_driver
    When I visit the root page
    Then Capybara should use the "javascript_test" driver

  @named_test
  Scenario: named driver tag
    When I visit the root page
    Then Capybara should use the "named_test" driver

  @named_test
  Scenario Outline: selenium tag with scenario outline
    When I visit the <Page> page
    Then Capybara should use the "named_test" driver

    Examples:
      | Page |
      | root |
      | home |

  Scenario: matchers
    When I visit the root page
    And I use a matcher that fails
    Then the failing exception should be nice
