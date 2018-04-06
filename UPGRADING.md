# Upgrading from Capybara 2.x to 3.x

## Server

Capybara 3 changes the default server to <a href="https://github.com/puma/puma">Puma</a>. If you do not use `Puma` in your project you can
revert to the previous default of WEBRick by specifying

```ruby
Capybara.server = :webrick
```

## Finders

The biggest user differences between Capybara 2.x and 3.x are the changes in behavior of `first` and `all`. In Capybara 2.x both methods would, by default, return immediately with nil if no matching elements exist on the page.  In Capybara 3.x this has changed to include the waiting/retrying behavior found in the other Capybara finders and matchers.

`first` will now wait up to `Capybara.default_max_wait_time` seconds for at least one matching element to exist, and return the first matching element.  If no matching elements are found within the time it will now raise a `Capybara::ElementNotFound` error instead of returning nil. If you need to maintain the previous behavior you can pass `minimum: 0` as an option to `first`

```ruby
first('div', minimum: 0)
```

`all` will now wait up to `Capybara.default_max_wait_time' seconds for at least one matching element to exist, and return the matching elements.  If no matching elements are found within the time it will return an empty result set.  If you need to maintain the previous behavior you can pass `wait: false` as an option to `all`

```ruby
all('div', wait: false)
```

## Matchers

`has_text?` (aka. `has_content?`) no longer normalizes whitespace.

```
# 2.18.0
Capybara::Node::Simple.new("<p>foo\nbar</p>").has_text?("foo bar")
#=> true

# 3.0.0
Capybara::Node::Simple.new("<p>foo\nbar</p>").has_text?("foo bar")
#=> false
```
