# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Capybara::Selenium::Driver do
  it "should exit with a non-zero exit status" do
    browser = Capybara::Selenium::Driver.new(TestApp).browser
    expect(true).to eq(false)
  end
end
