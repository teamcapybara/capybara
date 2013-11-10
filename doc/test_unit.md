## Using Capybara with Test::Unit

* If you are using Rails, add the following code in your `test_helper.rb`
    file to make Capybara available in all test cases deriving from
    `ActionDispatch::IntegrationTest`:

    ```ruby
    class ActionDispatch::IntegrationTest
      # Make the Capybara DSL available in all integration tests
      include Capybara::DSL
    end
    ```

* If you are not using Rails, define a base class for your Capybara tests like
  so:

    ```ruby
    class CapybaraTestCase < Test::Unit::TestCase
      include Capybara::DSL

      def teardown
        Capybara.reset_sessions!
        Capybara.use_default_driver
      end
    end
    ```

    Remember to call `super` in any subclasses that override
    `teardown`.

To switch the driver, set `Capybara.current_driver`. For instance,

```ruby
class BlogTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver # :selenium by default
  end

  test 'shows blog posts' do
    # ... this test is run with Selenium ...
  end
end
```

