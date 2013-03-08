# Capybara

[![Build Status](https://secure.travis-ci.org/jnicklas/capybara.png)](http://travis-ci.org/jnicklas/capybara)
[![Dependency Status](https://gemnasium.com/jnicklas/capybara.png)](https://gemnasium.com/jnicklas/capybara)
[![Code Quality](https://codeclimate.com/badge.png)](https://codeclimate.com/github/jnicklas/capybara)

Capybara helps you test web applications by simulating how a real user would
interact with your app. It is agnostic about the driver running your tests and
comes with Rack::Test and Selenium support built in. WebKit is supported
through an external gem.

**Need help?** Ask on the mailing list (please do not open an issue on
GitHub): http://groups.google.com/group/ruby-capybara

## Key benefits

- **No setup** necessary for Rails and Rack application. Works out of the box.
- **Intuitive API** which mimics the language an actual user would use.
- **Switch the backend** your tests run against from fast headless mode
  to an actual browser with no changes to your tests.
- **Powerful synchronization** features mean you never have to manually wait
  for asynchronous processes to complete.

## Setup

To install, type

```bash
gem install capybara
```

If you are using Rails, add this line to your test helper file:

```ruby
require 'capybara/rails'
```

If you are not using Rails, set Capybara.app to your rack app:

```ruby
Capybara.app = MyRackApp
```

If you need to test JavaScript, or if your app interacts with (or is located at)
a remote URL, you'll need to [use a different driver](#drivers).

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

## Using Capybara with RSpec

Load RSpec 2.x support by adding the following line (typically to your
`spec_helper.rb` file):

```ruby
require 'capybara/rspec'
```

If you are using Rails, put your Capybara specs in `spec/features`.

If you are not using Rails, tag all the example groups in which you want to use
Capybara with `:type => :feature`.

You can now write your specs like so:

```ruby
describe "the signup process", :type => :feature do
  before :each do
    User.make(:email => 'user@example.com', :password => 'caplin')
  end

  it "signs me in" do
    visit '/sessions/new'
    within("#session") do
      fill_in 'Login', :with => 'user@example.com'
      fill_in 'Password', :with => 'password'
    end
    click_link 'Sign in'
    page.should have_content 'Success'
  end
end
```

Use `:js => true` to switch to the `Capybara.javascript_driver`
(`:selenium` by default), or provide a `:driver` option to switch
to one specific driver. For example:

```ruby
describe 'some stuff which requires js', :js => true do
  it 'will use the default js driver'
  it 'will switch to one specific driver', :driver => :webkit
end
```

Finally, Capybara also comes with a built in DSL for creating descriptive acceptance tests:

```ruby
feature "Signing up" do
  background do
    User.make(:email => 'user@example.com', :password => 'caplin')
  end

  scenario "Signing in with correct credentials" do
    visit '/sessions/new'
    within("#session") do
      fill_in 'Login', :with => 'user@example.com'
      fill_in 'Password', :with => 'caplin'
    end
    click_link 'Sign in'
    page.should have_content 'Success'
  end

  given(:other_user) { User.make(:email => 'other@example.com', :password => 'rous') }

  scenario "Signing in as another user" do
    visit '/sessions/new'
    within("#session") do
      fill_in 'Login', :with => other_user.email
      fill_in 'Password', :with => other_user.password
    end
    click_link 'Sign in'
    page.should have_content 'Invalid email or password'
  end
end
```

`feature` is in fact just an alias for `describe ..., :type => :feature`,
`background` is an alias for `before`, `scenario` for `it`, and
`given`/`given!` aliases for `let`/`let!`, respectively.

## Using Capybara with Test::Unit

* If you are using Rails, add `database_cleaner` to your Gemfile:

    ```ruby
    group :test do
      gem 'database_cleaner'
    end
    ```

    Then add the following code in your `test_helper.rb` file to make
    Capybara available in all test cases deriving from
    `ActionDispatch::IntegrationTest`:

    ```ruby
    # Transactional fixtures do not work with Selenium tests, because Capybara
    # uses a separate server thread, which the transactions would be hidden
    # from. We hence use DatabaseCleaner to truncate our test database.
    DatabaseCleaner.strategy = :truncation

    class ActionDispatch::IntegrationTest
      # Make the Capybara DSL available in all integration tests
      include Capybara::DSL

      # Stop ActiveRecord from wrapping tests in transactions
      self.use_transactional_fixtures = false

      teardown do
        DatabaseCleaner.clean       # Truncate the database
        Capybara.reset_sessions!    # Forget the (simulated) browser state
        Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
      end
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

## Using Capybara with MiniTest::Spec

Set up your base class as with Test::Unit. (On Rails, the right base class
could be something other than ActionDispatch::IntegrationTest.)

The capybara_minitest_spec gem ([Github](https://github.com/ordinaryzelig/capybara_minitest_spec),
[rubygems.org](https://rubygems.org/gems/capybara_minitest_spec)) provides MiniTest::Spec
expectations for Capybara. For example:

```ruby
page.must_have_content('Important!')
```

## Drivers

Capybara uses the same DSL to drive a variety of browser and headless drivers.

### Selecting the Driver

By default, Capybara uses the `:rack_test` driver, which is fast but limited: it
does not support JavaScript, nor is it able to access HTTP resources outside of
your Rack application, such as remote APIs and OAuth services. To get around
these limitations, you can set up a different default driver for your features.
For example if you'd prefer to run everything in Selenium, you could do:

```ruby
Capybara.default_driver = :selenium
```

However, if you are using RSpec or Cucumber, you may instead want to consider
leaving the faster `:rack_test` as the __default_driver__, and marking only those
tests that require a JavaScript-capable driver using `:js => true` or
`@javascript`, respectively.  By default, JavaScript tests are run using the
`:selenium` driver. You can change this by setting
`Capybara.javascript_driver`.

You can also change the driver temporarily (typically in the Before/setup and
After/teardown blocks):

```ruby
Capybara.current_driver = :webkit # temporarily select different driver
... tests ...
Capybara.use_default_driver       # switch back to default driver
```

**Note**: switching the driver creates a new session, so you may not be able to
switch in the middle of a test.

### RackTest

RackTest is Capybara's default driver. It is written in pure Ruby and does not
have any support for executing JavaScript. Since the RackTest driver interacts
directly with Rack interfaces, it does not require a server to be started.
However, this means that if your application is not a Rack application (Rails,
Sinatra and most other Ruby frameworks are Rack applications) then you cannot
use this driver. Furthermore, you cannot use the RackTest driver to test a
remote application, or to access remote URLs (e.g., redirects to external
sites, external APIs, or OAuth services) that your application might interact
with.

[capybara-mechanize](https://github.com/jeroenvandijk/capybara-mechanize)
provides a similar driver that can access remote servers.

RackTest can be configured with a set of headers like this:

```ruby
Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :browser => :chrome)
end
```

See the section on adding and configuring drivers.

### Selenium

At the moment, Capybara supports [Selenium 2.0
(Webdriver)](http://seleniumhq.org/docs/01_introducing_selenium.html#selenium-2-aka-selenium-webdriver),
*not* Selenium RC. Provided Firefox is installed, everything is set up for you,
and you should be able to start using Selenium right away.

**Note**: drivers which run the server in a different thread may not work share the
same transaction as your tests, causing data not to be shared between your test
and test server, see "Transactions and database setup" below.

### Capybara-webkit

The [capybara-webkit driver](https://github.com/thoughtbot/capybara-webkit) is for true headless
testing. It uses QtWebKit to start a rendering engine process. It can execute JavaScript as well.
It is significantly faster than drivers like Selenium since it does not load an entire browser.

You can install it with:

```bash
gem install capybara-webkit
```

And you can use it by:

```ruby
Capybara.javascript_driver = :webkit
```

### Poltergeist

[Poltergeist](https://github.com/jonleighton/poltergeist) is another
headless driver which integrates Capybara with
[PhantomJS](http://phantomjs.org/). It is truly headless, so doesn't
require Xvfb to run on your CI server. It will also detect and report
any Javascript errors that happen within the page.

## The DSL

*A complete reference is available at
[rubydoc.info](http://rubydoc.info/github/jnicklas/capybara/master)*.

**Note**: All searches in Capybara are *case sensitive*. This is because
Capybara heavily uses XPath, which doesn't support case insensitivity.

### Navigating

You can use the
[#visit](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#visit-instance_method)
method to navigate to other pages:

```ruby
visit('/projects')
visit(post_comments_path(post))
```

The visit method only takes a single parameter, the request method is **always**
GET.

You can get the [current path](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#current_path-instance_method)
of the browsing session for test assertions:

```ruby
current_path.should == post_comments_path(post)
```

### Clicking links and buttons

*Full reference: [Capybara::Node::Actions](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Actions)*

You can interact with the webapp by following links and buttons. Capybara
automatically follows any redirects, and submits forms associated with buttons.

```ruby
click_link('id-of-link')
click_link('Link Text')
click_button('Save')
click_on('Link Text') # clicks on either links or buttons
click_on('Button Value')
```

### Interacting with forms

*Full reference: [Capybara::Node::Actions](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Actions)*

There are a number of tools for interacting with form elements:

```ruby
fill_in('First Name', :with => 'John')
fill_in('Password', :with => 'Seekrit')
fill_in('Description', :with => 'Really Long Text...')
choose('A Radio Button')
check('A Checkbox')
uncheck('A Checkbox')
attach_file('Image', '/path/to/image.jpg')
select('Option', :from => 'Select Box')
```

### Querying

*Full reference: [Capybara::Node::Matchers](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Matchers)*

Capybara has a rich set of options for querying the page for the existence of
certain elements, and working with and manipulating those elements.

```ruby
page.has_selector?('table tr')
page.has_selector?(:xpath, '//table/tr')

page.has_xpath?('//table/tr')
page.has_css?('table tr.foo')
page.has_content?('foo')
```

**Note:** The negative forms like `has_no_selector?` are different from `not
has_selector?`. Read the section on asynchronous JavaScript for an explanation.

You can use these with RSpec's magic matchers:

```ruby
page.should have_selector('table tr')
page.should have_selector(:xpath, '//table/tr')

page.should have_xpath('//table/tr')
page.should have_css('table tr.foo')
page.should have_content('foo')
```

### Finding

_Full reference: [Capybara::Node::Finders](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Finders)_

You can also find specific elements, in order to manipulate them:

```ruby
find_field('First Name').value
find_link('Hello').visible?
find_button('Send').click

find(:xpath, "//table/tr").click
find("#overlay").find("h1").click
all('a').each { |a| a[:href] }
```

**Note**: `find` will wait for an element to appear on the page, as explained in the
Ajax section. If the element does not appear it will raise an error.

These elements all have all the Capybara DSL methods available, so you can restrict them
to specific parts of the page:

```ruby
find('#navigation').click_link('Home')
find('#navigation').should have_button('Sign out')
```

### Scoping

Capybara makes it possible to restrict certain actions, such as interacting with
forms or clicking links and buttons, to within a specific area of the page. For
this purpose you can use the generic
<tt>[within](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#within-instance_method)</tt>
method. Optionally you can specify which kind of selector to use.

```ruby
within("li#employee") do
  fill_in 'Name', :with => 'Jimmy'
end

within(:xpath, "//li[@id='employee']") do
  fill_in 'Name', :with => 'Jimmy'
end
```

**Note**: `within` will scope the actions to the _first_ (not _any_) element that matches the selector.

There are special methods for restricting the scope to a specific fieldset,
identified by either an id or the text of the fieldset's legend tag, and to a
specific table, identified by either id or text of the table's caption tag.

```ruby
within_fieldset('Employee') do
  fill_in 'Name', :with => 'Jimmy'
end

within_table('Employee') do
  fill_in 'Name', :with => 'Jimmy'
end
```

### Scripting

In drivers which support it, you can easily execute JavaScript:

```ruby
page.execute_script("$('body').empty()")
```

For simple expressions, you can return the result of the script. Note
that this may break with more complicated expressions:

```ruby
result = page.evaluate_script('4 + 4');
```

### Debugging

It can be useful to take a snapshot of the page as it currently is and take a
look at it:

```ruby
save_and_open_page
```

You can also retrieve the current state of the DOM as a string using
<tt>[page.html](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#html-instance_method)</tt>.

```ruby
print page.html
```

This is mostly useful for debugging. You should avoid testing against the
contents of `page.html` and use the more expressive finder methods instead.

Finally, in drivers that support it, you can save a screenshot:

```ruby
page.save_screenshot('screenshot.png')
```

## Matching

It is possible to customize how Capybara finds elements. At your disposal
are two options, `Capybara.exact` and `Capybara.match`.

### Exactness

`Capybara.exact` and the `exact` option work together with the `is` expression
inside the XPath gem. When `exact` is true, all `is` expressions match exactly,
when it is false, they allow substring matches. Many of the selectors built into
Capybara use the `is` expression. This way you can specify whether you want to
allow substring matches or not. `Capybara.exact` is false by default.

For example:

```ruby
click_link("Password") # also matches "Password confirmation"
Capybara.exact = true
click_link("Password") # does not match "Password confirmation"
click_link("Password", exact: false) # can be overridden
```

### Strategy

Using `Capybara.match` and the equivalent `match` option, you can control how
Capybara behaves when multiple elements all match a query. There are currently
four different strategies built into Capybara:

1. **first:** Just picks the first element that matches.
2. **one:** Raises an error if more than one element matches.
3. **smart:** If `exact` is `true`, raises an error if more than one element
   matches, just like `one`. If `exact` is `false`, it will first try to find
   an exact match. An error is raised if more than one element is found. If no
   element is found, a new search is performed which allows partial matches. If
   that search returns multiple matches, an error is raised.
4. **prefer_exact:** If multiple matches are found, some of which are exact,
   and some of which are not, then the first exactly matching element is
   returned.

The default for `Capybara.match` is `:smart`. To emulate the behaviour in
Capybara 2.0.x, set `Capybara.match` to `:one`. To emulate the behaviour in
Capybara 1.x, set `Capybara.match` to `:prefer_exact`.

## Transactions and database setup

Some Capybara drivers need to run against an actual HTTP server. Capybara takes
care of this and starts one for you in the same process as your test, but on
another thread. Selenium is one of those drivers, whereas RackTest is not.

If you are using a SQL database, it is common to run every test in a
transaction, which is rolled back at the end of the test, rspec-rails does this
by default out of the box for example. Since transactions are usually not
shared across threads, this will cause data you have put into the database in
your test code to be invisible to Capybara.

Cucumber handles this by using truncation instead of transactions, i.e. they
empty out the entire database after each test. You can get the same behaviour
by using a gem such as [database_cleaner](https://github.com/bmabey/database_cleaner).

It is also possible to force your ORM to use the same transaction for all
threads.  This may have thread safety implications and could cause strange
failures, so use caution with this approach. It can be implemented in
ActiveRecord through the following monkey patch:

```ruby
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
```

## Asynchronous JavaScript (Ajax and friends)

When working with asynchronous JavaScript, you might come across situations
where you are attempting to interact with an element which is not yet present
on the page. Capybara automatically deals with this by waiting for elements
to appear on the page.

When issuing instructions to the DSL such as:

```ruby
click_link('foo')
click_link('bar')
page.should have_content('baz')
```

If clicking on the *foo* link triggers an asynchronous process, such as
an Ajax request, which, when complete will add the *bar* link to the page,
clicking on the *bar* link would be expected to fail, since that link doesn't
exist yet. However Capybara is smart enough to retry finding the link for a
brief period of time before giving up and throwing an error. The same is true of
the next line, which looks for the content *baz* on the page; it will retry
looking for that content for a brief time. You can adjust how long this period
is (the default is 2 seconds):

```ruby
Capybara.default_wait_time = 5
```

Be aware that because of this behaviour, the following two statements are **not**
equivalent, and you should **always** use the latter!

```ruby
!page.has_xpath?('a')
page.has_no_xpath?('a')
```

The former would immediately fail because the content has not yet been removed.
Only the latter would wait for the asynchronous process to remove the content
from the page.

Capybara's Rspec matchers, however, are smart enough to handle either form.
The two following statements are functionally equivalent:

```ruby
page.should_not have_xpath('a')
page.should have_no_xpath('a')
```

Capybara's waiting behaviour is quite advanced, and can deal with situations
such as the following line of code:

```ruby
find('#sidebar').find('h1').should have_content('Something')
```

Even if JavaScript causes `#sidebar` to disappear off the page, Capybara
will automatically reload it and any elements it contains. So if an AJAX
request causes the contents of `#sidebar` to change, which would update
the text of the `h1` to "Something", and this happened, this test would
pass. If you do not want this behaviour, you can set
`Capybara.automatic_reload` to `false`.

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

## Calling remote servers

Normally Capybara expects to be testing an in-process Rack application, but you
can also use it to talk to a web server running anywhere on the internet, by
setting app_host:

```ruby
Capybara.current_driver = :selenium
Capybara.app_host = 'http://www.google.com'
...
visit('/')
```

**Note**: the default driver (`:rack_test`) does not support running
against a remote server. With drivers that support it, you can also visit any
URL directly:

```ruby
visit('http://www.google.com')
```

By default Capybara will try to boot a rack application automatically. You
might want to switch off Capybara's rack server if you are running against a
remote application:

```ruby
Capybara.run_server = false
```

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

## XPath, CSS and selectors

Capybara does not try to guess what kind of selector you are going to give it,
and will always use CSS by default.  If you want to use XPath, you'll need to
do:

```ruby
within(:xpath, '//ul/li') { ... }
find(:xpath, '//ul/li').text
find(:xpath, '//li[contains(.//a[@href = "#"]/text(), "foo")]').value
```

Alternatively you can set the default selector to XPath:

```ruby
Capybara.default_selector = :xpath
find('//ul/li').text
```

Capybara allows you to add custom selectors, which can be very useful if you
find yourself using the same kinds of selectors very often:

```ruby
Capybara.add_selector(:id) do
  xpath { |id| XPath.descendant[XPath.attr(:id) == id.to_s] }
end

Capybara.add_selector(:row) do
  xpath { |num| ".//tbody/tr[#{num}]" }
end

Capybara.add_selector(:flash_type) do
  css { |type| "#flash.#{type}" }
end
```

The block given to xpath must always return an XPath expression as a String, or
an XPath expression generated through the XPath gem. You can now use these
selectors like this:

```ruby
find(:id, 'post_123')
find(:row, 3)
find(:flash_type, :notice)
```

You can specify an optional match option which will automatically use the
selector if it matches the argument:

```ruby
Capybara.add_selector(:id) do
  xpath { |id| XPath.descendant[XPath.attr(:id) == id.to_s] }
  match { |value| value.is_a?(Symbol) }
end
```

Now use it like this:

```ruby
find(:post_123)
```

This :id selector is already built into Capybara by default, so you don't
need to add it yourself.

## Beware the XPath // trap

In XPath the expression // means something very specific, and it might not be what
you think. Contrary to common belief, // means "anywhere in the document" not "anywhere
in the current context". As an example:

```ruby
page.find(:xpath, '//body').all(:xpath, '//script')
```

You might expect this to find all script tags in the body, but actually, it finds all
script tags in the entire document, not only those in the body! What you're looking
for is the .// expression which means "any descendant of the current node":

```ruby
page.find(:xpath, '//body').all(:xpath, './/script')
```
The same thing goes for within:

```ruby
within(:xpath, '//body') do
  page.find(:xpath, './/script')
  within(:xpath, './/table/tbody') do
  ...
  end
end
```

## Configuring and adding drivers

Capybara makes it convenient to switch between different drivers. It also exposes
an API to tweak those drivers with whatever settings you want, or to add your own
drivers. This is how to switch the selenium driver to use chrome:

```ruby
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
```

However, it's also possible to give this a different name, so tests can switch
between using different browsers effortlessly:

```ruby
Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
```

Whatever is returned from the block should conform to the API described by
Capybara::Driver::Base, it does not however have to inherit from this class.
Gems can use this API to add their own drivers to Capybara.

The [Selenium wiki](http://code.google.com/p/selenium/wiki/RubyBindings) has
additional info about how the underlying driver can be configured.

## Gotchas:

* Access to session and request is not possible from the test, Access to
  response is limited. Some drivers allow access to response headers and HTTP
  status code, but this kind of functionality is not provided by some drivers,
  such as Selenium.

* Access to Rails specific stuff (such as `controller`) is unavailable,
  since we're not using Rails' integration testing.

* Freezing time: It's common practice to mock out the Time so that features
  that depend on the current Date work as expected. This can be problematic,
  since Capybara's Ajax timing uses the system time, resulting in Capybara
  never timing out and just hanging when a failure occurs. It's still possible to
  use gems which allow you to travel in time, rather than freeze time.
  One such gem is [Timecop](http://github.com/travisjeffery/timecop).

* When using Rack::Test, beware if attempting to visit absolute URLs. For
  example, a session might not be shared between visits to `posts_path`
  and `posts_url`. If testing an absolute URL in an Action Mailer email,
  set `default_url_options` to match the Rails default of
  `www.example.com`.

## Development

To set up a development environment, simply do:

```bash
git submodule update --init
bundle install
bundle exec rake  # run the test suite
```

See
[CONTRIBUTING.md](https://github.com/jnicklas/capybara/blob/master/CONTRIBUTING.md)
for how to send issues and pull requests.
