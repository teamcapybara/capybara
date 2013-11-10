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
describe "the signin process", :type => :feature do
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
    expect(page).to have_content 'Success'
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
feature "Signing in" do
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
    expect(page).to have_content 'Success'
  end

  given(:other_user) { User.make(:email => 'other@example.com', :password => 'rous') }

  scenario "Signing in as another user" do
    visit '/sessions/new'
    within("#session") do
      fill_in 'Login', :with => other_user.email
      fill_in 'Password', :with => other_user.password
    end
    click_link 'Sign in'
    expect(page).to have_content 'Invalid email or password'
  end
end
```

`feature` is in fact just an alias for `describe ..., :type => :feature`,
`background` is an alias for `before`, `scenario` for `it`, and
`given`/`given!` aliases for `let`/`let!`, respectively.

