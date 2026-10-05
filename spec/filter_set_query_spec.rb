# frozen_string_literal: true

require 'uri'
require 'capybara'

RSpec.describe 'filter_set expression filters' do
  before do
    Capybara::Selector::FilterSet.add(:href_filter_test) do
      expression_filter(:href_is) { |css, href| "#{css}[href='#{href}']" }
    end
  end

  after { Capybara::Selector::FilterSet.remove(:href_filter_test) }

  it 'applies the filter only when the filter set is selected' do
    page = Capybara.string('<a href="/1">one</a><a href="/2">two</a>')

    expect(page.all(:css, 'a', filter_set: :href_filter_test, href_is: '/2').map(&:text)).to eq(['two'])
    expect { page.all(:css, 'a', href_is: '/2') }.to raise_error(ArgumentError, /Invalid option/)
  end
end
