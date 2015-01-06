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
end
