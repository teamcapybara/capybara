## Using the DSL elsewhere

You can mix the DSL into any context by including <tt>Capybara::DSL</tt>:


```ruby
require 'capybara'
require 'capybara/dsl'

Capybara.default_driver = :webkit

module MyModule
  include Capybara::DSL

  def login!
    within("//form[@id='session']") do
      fill_in 'Login', :with => 'user@example.com'
      fill_in 'Password', :with => 'password'
    end
    click_link 'Sign in'
  end
end
```

This enables its use in unsupported testing frameworks, and for general-purpose scripting.

## Using the sessions manually

For ultimate control, you can instantiate and use a
[Session](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session)
manually.

```ruby
require 'capybara'

session = Capybara::Session.new(:webkit, my_rack_app)
session.within("//form[@id='session']") do
  session.fill_in 'Login', :with => 'user@example.com'
  session.fill_in 'Password', :with => 'password'
end
session.click_link 'Sign in'
```

