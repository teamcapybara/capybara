## Using Capybara with Cucumber

The `cucumber-rails` gem comes with Capybara support built-in. If you
are not using Rails, manually load the `capybara/cucumber` module:

```ruby
require 'capybara/cucumber'
Capybara.app = MyRackApp
```

You can use the Capybara DSL in your steps, like so:

```ruby
When /I sign in/ do
  within("#session") do
    fill_in 'Login', :with => 'user@example.com'
    fill_in 'Password', :with => 'password'
  end
  click_link 'Sign in'
end
```

You can switch to the `Capybara.javascript_driver` (`:selenium`
by default) by tagging scenarios (or features) with `@javascript`:

```ruby
@javascript
Scenario: do something Ajaxy
  When I click the Ajax link
  ...
```

There are also explicit `@selenium` and `@rack_test`
tags set up for you.
