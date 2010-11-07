require 'spec_helper'
require 'capybara/dsl'
require 'capybara/rspec'

describe RSpec::Core::Example do

  before do
    @group = RSpec::Core::ExampleGroup.describe
  end

  it 'should call Capybara.using_driver' do
    Capybara.should_receive(:using_driver).with(:selenium)
    @group.example("does something", {:driver => :selenium}).run
  end

  it "does not show the original aliased method" do
    methods = @group.example("without public aliased method").methods
    methods.should_not include('__run_before_swinger')
  end

end
