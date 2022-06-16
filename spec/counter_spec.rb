# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Capybara::Server::Middleware::Counter do
  let(:counter) { Capybara::Server::Middleware::Counter.new  }
  let(:uri) { '/example' }

  context '#increment' do
    it 'successfully' do
      counter.increment(uri)
      expect(counter.positive?).to be true
    end
  end

  context 'decrement' do
    before do
      counter.increment(uri)
      expect(counter.positive?).to be true
    end

    context 'successfully' do
      it 'with same uri' do
        counter.decrement(uri)
        expect(counter.positive?).to be false
      end

      it 'with changed uri' do
        counter.decrement('/')
        expect(counter.positive?).to be false
      end
    end
  end
end
