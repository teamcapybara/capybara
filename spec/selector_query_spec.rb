# frozen_string_literal: true

require 'uri'
require 'capybara'

RSpec.describe 'near spatial filter' do
  let(:rectangle) { Capybara::Queries::SelectorQuery.const_get(:Rectangle) }

  [0.0, 0].each do |origin|
    it "finds an element 10px beside a tall rectangle with #{origin.class} coordinates" do
      tall = rectangle.new('top' => origin, 'bottom' => origin + 1000,
                           'left' => origin, 'right' => origin + 100)
      small = rectangle.new('top' => origin + 495, 'bottom' => origin + 505,
                            'left' => origin + 110, 'right' => origin + 120)

      expect(tall.distance(small)).to eq(10)
      expect(tall.near?(small)).to be(true)
    end
  end
end
