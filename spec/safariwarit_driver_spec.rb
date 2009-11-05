require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Webcat::Driver::SafariWatir do
  before do
    @driver = Webcat::Driver::SafariWatir.new(TestApp)
  end
  
  # it_should_behave_like "driver"
  # it_should_behave_like "driver with javascript support"
end