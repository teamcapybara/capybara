# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Capybara::Session do
  it "verifies a passed app is a rack app" do
    expect do
      Capybara::Session.new(:unknown, { random: "hash"})
    end.to raise_error TypeError, "The second parameter to Session::new should be a rack app if passed."
  end
end
