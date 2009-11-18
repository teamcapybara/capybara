# capybara

* http://github.com/jnicklas/capybara

## Description:

Capybara aims to simplify the process of integration testing Rack applications,
such as Rails, Sinatra or Merb. It is inspired by and aims to replace Webrat as
a DSL for interacting with a webapplication. It is agnostic about the driver
running your tests and currently comes bundled with rack-test, Culerity and
Selenium support built in.

## Disclaimer:

Capybara is alpha level software, don't use it unless you're prepared to get
your hands dirty.

## Using Capybara with Cucumber

Capybara is built to work nicely with Cucumber. The API is very similar to
Webrat, so if you know Webrat you should feel right at home. Remove any
references to Webrat from your `env.rb`, if you're using Rails, make sure to set

    Cucumber::Rails::World.use_transactional_fixtures = false

Capybara uses DatabaseCleaner to truncate the database. Require Capybara in your
env.rb. For Rails do this:

    require 'capybara/rails'
    require 'capybara/cucumber'

For other frameworks, you'll need to set the Rack app manually:

    require 'capybara/cucumber'
    Capybara.app = MyRackApp

Now you can use it in your steps:

    When /I sign in/ do
      within("//form[@id='session']") do
        fill_in 'Login', :with => 'user@example.com'
        fill_in 'Password', :with => 'password'
      end
      click_link 'Sign in'
    end

## Default and current driver

You can set up a default driver for your features. For example if you'd prefer
to run Selenium, you could do:

    require 'capybara/rails'
    require 'capybara/cucumber'
    Capybara.default_driver = :selenium

You can change the driver temporarily:

    Capybara.current_driver = :culerity
    Capybara.use_default_driver

## Cucumber and Tags

Capybara sets up some [tags](http://wiki.github.com/aslakhellesoy/cucumber/tags)
for you to use in Cucumber. Often you'll want to use run only some scenarios
with a driver that supports JavaScript, Capybara makes this easy: simply tag the
scenario (or feature) with `@javascript`:

    @javascript
    Scenario: do something AJAXy
      When I click the AJAX link
      ...

You can change which driver Capybara uses for JavaScript:

    Capybara.javascript_driver = :culerity

There are also explicit `@selenium`, `@culerity` and `@rack_test` tags set up
for you.

## The API

Navigation:

    visit – The only way to get to anywhere.

Scoping:

    within – Takes a block which executes in the given scope

Interaction:

    click_link
    click_button
    fill_in – Currently broken with password fields under Culerity
    choose
    check
    uncheck – Currently broken under Culerity
    attach_file
    select

Querying:

    body
    has_xpath? – Checks if given XPath exists, takes text and count options
    has_css? – Checks if given CSS exists, takes text and count options
    has_content? – Checks if the given content is on the page
    find_field
    find_link
    find_button
    field_labeled

Debugging:

    save_and_open_page

## Using the DSL outside cucumber

You can mix the DSL into any context, for example you could use it in RSpec
examples. Just load the dsl and include it anywhere:

    require 'capybara'
    require 'capybara/dsl'

    include Capybara
    Capybara.default_driver = :culerity

    within("//form[@id='session']") do
      fill_in 'Login', :with => 'user@example.com'
      fill_in 'Password', :with => 'password'
    end
    click_link 'Sign in'

## Using the sessions manually

For ultimate control, you can instantiate and use a session manually.

    require 'capybara'

    session = Capybara::Session.new(:culerity, my_rack_app)
    session.within("//form[@id='session']") do
      session.fill_in 'Login', :with => 'user@example.com'
      session.fill_in 'Password', :with => 'password'
    end
    session.click_link 'Sign in'

## Install:

Capybara is hosted on Gemcutter, install it with:

    sudo gem install capybara

## Gotchas:

* Everything is *case sensitive*. Capybara heavily relies on XPath, which
  doesn't support case insensitive searches.

* The `have_tag` and `have_text` matchers in RSpec-Rails are not supported.
  You should use `page.should have_css('#header p')`,
  `page.should have_xpath('//ul/li')` and `page.should have_content('Monkey')`
  instead.

* Unchecking checkboxes and filling in password fields is currently broken under
  Culerity.

* Domain names (including subdomains) don't work under rack-test. Since it's a
  pain to set up subdomains for the other drivers anyway, you should consider an
  alternate solution. You might use
  [default_url_options](https://gist.github.com/643a758320a2926bd2ed) in Rails
  for example.

* The `set_hidden_field` method from Webrat is not implemented, since it doesn't
  work in any of the browser based drivers (Culerity, Selenium)

* Access to session, request and response from the test is not possible. Maybe
  we'll do response headers at some point in the future, but the others really
  shouldn't be touched in an integration test anyway.

* Access to Rails specific stuff (such as `controller`) is unavailable, since
  we're not using Rails' integration testing.

* `<a href="#">` Will cause problems under rack-test, please do
  `<a href="/same/url#">` instead. You can achieve this in Rails with
  `link_to('foo', :anchor => '')`

## License:

(The MIT License)

Copyright (c) 2009 Jonas Nicklas

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.