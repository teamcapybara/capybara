require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Driver::SafariWatir do
  before do
    @driver = Capybara::Driver::SafariWatir.new(TestApp)
  end
  
  # it_should_behave_like "driver"
  # it_should_behave_like "driver with javascript support"
end
