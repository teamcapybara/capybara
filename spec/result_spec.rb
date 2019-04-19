# frozen_string_literal: true

require 'spec_helper'

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
    string.all '//li', minimum: 0 # pass minimum: 0 so lazy evaluation doesn't get triggered yet
  end

  it 'has a length' do
    expect(result.length).to eq(4)
  end

  it 'has a first element' do
    result.first.text == 'Alpha'
  end

  it 'has a last element' do
    result.last.text == 'Delta'
  end

  it 'can supports values_at method' do
    expect(result.values_at(0, 2).map(&:text)).to eq(%w[Alpha Gamma])
  end

  it 'can return an element by its index' do
    expect(result.at(1).text).to eq('Beta')
    expect(result[2].text).to eq('Gamma')
  end

  it 'can be mapped' do
    expect(result.map(&:text)).to eq(%w[Alpha Beta Gamma Delta])
  end

  it 'can be selected' do
    expect(result.select do |element|
      element.text.include? 't'
    end.length).to eq(2)
  end

  it 'can be reduced' do
    expect(result.reduce('') do |memo, element|
      memo + element.text[0]
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
    expect(result[0, 2].map(&:text)).to eq %w[Alpha Beta]
    expect(result[1..3].map(&:text)).to eq %w[Beta Gamma Delta]
    expect(result[-1].text).to eq 'Delta'
    expect(result[-2, 3].map(&:text)).to eq %w[Gamma Delta]
    expect(result[1..7].map(&:text)).to eq %w[Beta Gamma Delta]
    expect(result[1...3].map(&:text)).to eq %w[Beta Gamma]
    expect(result[2..-1].map(&:text)).to eq %w[Gamma Delta]
    expect(result[2...-1].map(&:text)).to eq %w[Gamma]
    eval <<~TEST, binding, __FILE__, __LINE__ + 1 if RUBY_VERSION.to_f > 2.5
      expect(result[2..].map(&:text)).to eq %w[Gamma Delta]
    TEST
  end

  it 'works with filter blocks' do
    result = string.all('//li') { |node| node.text == 'Alpha' }
    expect(result.size).to eq 1
  end

  # Not a great test but it indirectly tests what is needed
  it 'should evaluate filters lazily for idx' do
    skip 'JRuby has an issue with lazy enumerator evaluation' if jruby_lazy_enumerator_workaround?
    # Not processed until accessed
    expect(result.instance_variable_get('@result_cache').size).to be 0

    # Only one retrieved when needed
    result.first
    expect(result.instance_variable_get('@result_cache').size).to be 1

    # works for indexed access
    result[0]
    expect(result.instance_variable_get('@result_cache').size).to be 1

    result[2]
    expect(result.instance_variable_get('@result_cache').size).to be 3

    # All cached when converted to array
    result.to_a
    expect(result.instance_variable_get('@result_cache').size).to eq 4
  end

  it 'should evaluate filters lazily for range' do
    skip 'JRuby has an issue with lazy enumerator evaluation' if jruby_lazy_enumerator_workaround?
    result[0..1]
    expect(result.instance_variable_get('@result_cache').size).to be 2

    expect(result[0..7].size).to eq 4
    expect(result.instance_variable_get('@result_cache').size).to be 4
  end

  it 'should evaluate filters lazily for idx and length' do
    skip 'JRuby has an issue with lazy enumerator evaluation' if jruby_lazy_enumerator_workaround?
    result[1, 2]
    expect(result.instance_variable_get('@result_cache').size).to be 3

    expect(result[2, 5].size).to eq 2
    expect(result.instance_variable_get('@result_cache').size).to be 4
  end

  it 'should only need to evaluate one result for any?' do
    skip 'JRuby has an issue with lazy enumerator evaluation' if jruby_lazy_enumerator_workaround?
    result.any?
    expect(result.instance_variable_get('@result_cache').size).to be 1
  end

  it 'should evaluate all elements when #to_a called' do
    # All cached when converted to array
    result.to_a
    expect(result.instance_variable_get('@result_cache').size).to eq 4
  end

  context '#each' do
    it 'lazily evaluates' do
      skip 'JRuby has an issue with lazy enumerator evaluation' if jruby_lazy_enumerator_workaround?
      results = []
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
        skip 'JRuby has an issue with lazy enumerator evaluation' if jruby_lazy_enumerator_workaround?
        result.each.with_index do |_el, idx|
          expect(result.instance_variable_get('@result_cache').size).to eq(idx + 1) # 0 indexing
        end
      end
    end
  end

  context 'lazy select' do
    it 'is compatible' do
      # This test will let us know when JRuby fixes lazy select so we can re-enable it in Result
      pending 'JRuby has an issue with lazy enumberator evaluation' if RUBY_PLATFORM == 'java'
      eval_count = 0
      enum = %w[Text1 Text2 Text3].lazy.select do
        eval_count += 1
        true
      end
      expect(eval_count).to eq 0
      enum.next
      sleep 1
      expect(eval_count).to eq 1
    end
  end

  def jruby_lazy_enumerator_workaround?
    (RUBY_PLATFORM == 'java') && (Gem::Version.new(JRUBY_VERSION) < Gem::Version.new('9.2.8.0'))
  end
end
