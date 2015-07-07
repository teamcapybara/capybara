require 'spec_helper'

RSpec.describe "capybara/rspec", type: :view do
  it "allows matchers to be used on strings" do
    expect(%{<h1>Test header</h1>}).to have_css("h1", text: "Test header")
  end
end
