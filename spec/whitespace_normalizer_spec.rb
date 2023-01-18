# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Capybara::Node::WhitespaceNormalizer do
  subject do
    klass = Class.new do
      include Capybara::Node::WhitespaceNormalizer
    end

    klass.new
  end

  let(:text_needing_correction) do
    <<~TEXT
      Some     #{described_class::NON_BREAKING_SPACE}text
      #{described_class::RIGHT_TO_LEFT_MARK}
      #{described_class::ZERO_WIDTH_SPACE*30}
      #{described_class::LEFT_TO_RIGHT_MARK}
      Here
    TEXT
  end

  describe '#normalize_spacing' do
    it 'does nothing to text not containing special characters' do
      expect(subject.normalize_spacing('text')).to eq('text')
    end

    it 'compresses excess breaking spacing' do
      new_text =

      expect(
        subject.normalize_spacing(text_needing_correction)
      ).to eq('Some  text Here')
    end
  end

  describe '#normalize_visible_spacing' do
    it 'does nothing to text not containing special characters' do
      expect(subject.normalize_visible_spacing('text')).to eq('text')
    end

    it 'compresses excess breaking visible spacing' do
      expect(
        subject.normalize_visible_spacing(text_needing_correction)
      ).to eq <<~TEXT.chomp
        Some  text
        #{described_class::RIGHT_TO_LEFT_MARK}
        #{described_class::ZERO_WIDTH_SPACE*30}
        #{described_class::LEFT_TO_RIGHT_MARK}
        Here
      TEXT
    end
  end
end
