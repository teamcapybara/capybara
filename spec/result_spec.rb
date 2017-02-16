# frozen_string_literal: true
require 'spec_helper'

JRUBY_LAZY_ENUMERATORS_FIX_VERSION = '9.2.0.0'

RSpec.describe Capybara::Result do
  let :string do
    Capybara.string <<-STRING
      <ul>
        <li>Alpha</li>
        <li>Beta</li>
        <li>Gamma</li>
        <li>Delta</li>
      </ul>
    STRING
  end

  let :result do
    string.all '//li'
  end

  it "has a length" do
    expect(result.length).to eq(4)
  end

  it "has a first element" do
    result.first.text == 'Alpha'
  end

  it "has a last element" do
    result.last.text == 'Delta'
  end

  it 'can supports values_at method' do
    expect(result.values_at(0, 2).map(&:text)).to eq(%w(Alpha Gamma))
  end

  it "can return an element by its index" do
    expect(result.at(1).text).to eq('Beta')
    expect(result[2].text).to eq('Gamma')
  end

  it "can be mapped" do
    expect(result.map(&:text)).to eq(%w(Alpha Beta Gamma Delta))
  end

  it "can be selected" do
    expect(result.select do |element|
      element.text.include? 't'
    end.length).to eq(2)
  end

  it "can be reduced" do
    expect(result.reduce('') do |memo, element|
      memo += element.text[0]
    end).to eq('ABGD')
  end

  it 'can be sampled' do
    expect(result).to include(result.sample)
  end

  it 'can be indexed' do
    expect(result.index do |el|
      el.text == 'Gamma'
    end).to eq(2)
  end

  it 'supports all modes of []' do
    expect(result[1].text).to eq 'Beta'
    expect(result[0,2].map(&:text)).to eq ['Alpha', 'Beta']
    expect(result[1..3].map(&:text)).to eq ['Beta', 'Gamma', 'Delta']
    expect(result[-1].text).to eq 'Delta'
  end

  #Not a great test but it indirectly tests what is needed
  it "should evaluate filters lazily" do
    skip 'JRuby has an issue with lazy enumerator next evaluation' if RUBY_PLATFORM == 'java' &&
      Gem::Version.new(JRUBY_VERSION) < Gem::Version.new(JRUBY_LAZY_ENUMERATORS_FIX_VERSION)
    #Not processed until accessed
    expect(result.instance_variable_get('@result_cache').size).to be 0

    #Only one retrieved when needed
    result.first
    expect(result.instance_variable_get('@result_cache').size).to be 1

    #works for indexed access
    result[0]
    expect(result.instance_variable_get('@result_cache').size).to be 1

    result[2]
    expect(result.instance_variable_get('@result_cache').size).to be 3

    #All cached when converted to array
    result.to_a
    expect(result.instance_variable_get('@result_cache').size).to eq 4
  end

  context '#each' do
    it 'lazily evaluates' do
      skip 'JRuby has an issue with lazy enumerator next evaluation' if RUBY_PLATFORM == 'java' &&
        Gem::Version.new(JRUBY_VERSION) < Gem::Version.new(JRUBY_LAZY_ENUMERATORS_FIX_VERSION)
      results=[]
      result.each do |el|
        results << el
        expect(result.instance_variable_get('@result_cache').size).to eq results.size
      end

      expect(results.size).to eq 4
    end

    context 'without a block' do
      it 'returns an iterator' do
        expect(result.each).to be_a(Enumerator)
      end

      it 'lazily evaluates' do
        skip 'JRuby has an issue with lazy enumerator next evaluation' if RUBY_PLATFORM == 'java' &&
          Gem::Version.new(JRUBY_VERSION) < Gem::Version.new(JRUBY_LAZY_ENUMERATORS_FIX_VERSION)
        result.each.with_index do |el, idx|
          expect(result.instance_variable_get('@result_cache').size).to eq(idx+1)  # 0 indexing
        end
      end
    end
  end
end
