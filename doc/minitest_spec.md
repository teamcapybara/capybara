## Using Capybara with MiniTest::Spec

Set up your base class as with [Test::Unit](test_unit.md). (On Rails, the right base class
could be something other than ActionDispatch::IntegrationTest.)

The capybara_minitest_spec gem ([Github](https://github.com/ordinaryzelig/capybara_minitest_spec),
[rubygems.org](https://rubygems.org/gems/capybara_minitest_spec)) provides MiniTest::Spec
expectations for Capybara. For example:

```ruby
page.must_have_content('Important!')
```
