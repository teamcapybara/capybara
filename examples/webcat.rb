session = Webcat::Session.new('http://localhost:3000')

session.visit '/'

session.driver.trigger :click, '//div[@id=foo]//a'
session.driver.trigger :mouseover, '#foo a.bar' # will be ignored by drivers who do not support it

nodelist = session.find 'li#foo a'
nodelist.empty?
nodelist.first.tag_name   # => 'a'
nodelist.first.text       # => 'a cute link'
nodelist.first.html       # => 'a <em>cute</em> link'
nodelist.first.attributes # => { :href => '/blah' }
nodelist.first.trigger :click

session.request.url # => '/blah'
session.response.ok? # => true

# fancy stuff, just builds on the stuff above!

session.click_link 'a cute link'
session.click_button 'an awesome button'
session.within '#foo' do
  click_link 'a cute link'
end
session.fill_in 'foo', :with => 'bar'
session.choose 'Monkey'
session.check 'I am awesome'
session.wait_for '#fooo"

# In cuke:

When 'I am awesome' do
  page.check 'I am awesome'
  page.click_button 'FooBar'
end
