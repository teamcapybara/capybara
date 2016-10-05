# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Capybara::Selector::FilterSet do
  after do
    Capybara::Selector::FilterSet.remove(:test)
  end

  it "allows node filters" do
    fs = Capybara::Selector::FilterSet.add(:test) do
      filter(:node_test, :boolean) { |node, value| true }
      expression_filter(:expression_test, :boolean) { |expr, value| true }
    end

    expect(fs.node_filters.keys).to include(:node_test)
    expect(fs.node_filters.keys).not_to include(:expression_test)
  end

  it "allows expression filters" do
    fs = Capybara::Selector::FilterSet.add(:test) do
      filter(:node_test, :boolean) { |node, value| true }
      expression_filter(:expression_test, :boolean) { |expr, value| true }
    end

    expect(fs.expression_filters.keys).to include(:expression_test)
    expect(fs.expression_filters.keys).not_to include(:node_test)
  end
end
