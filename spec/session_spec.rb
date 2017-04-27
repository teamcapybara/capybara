# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Capybara::Session do
  it "verifies a passed app is a rack app" do
    expect do
      Capybara::Session.new(:unknown, { random: "hash"})
    end.to raise_error TypeError, "The second parameter to Session::new should be a rack app if passed."
  end

  context "current_driver" do
    it "is global when threadsafe false" do
      Capybara.threadsafe = false
      Capybara.current_driver = :selenium
      thread = Thread.new do
        Capybara.current_driver = :random
      end
      thread.join
      expect(Capybara.current_driver).to eq :random
    end

    it "is thread specific threadsafe true" do
      Capybara.threadsafe = true
      Capybara.current_driver = :selenium
      thread = Thread.new do
        Capybara.current_driver = :random
      end
      thread.join
      expect(Capybara.current_driver).to eq :selenium
    end
  end

  context "session_name" do
    it "is global when threadsafe false" do
      Capybara.threadsafe = false
      Capybara.session_name = "sess1"
      thread = Thread.new do
        Capybara.session_name = "sess2"
      end
      thread.join
      expect(Capybara.session_name).to eq "sess2"
    end

    it "is thread specific when threadsafe true" do
      Capybara.threadsafe = true
      Capybara.session_name = "sess1"
      thread = Thread.new do
        Capybara.session_name = "sess2"
      end
      thread.join
      expect(Capybara.session_name).to eq "sess1"
    end
  end
end
