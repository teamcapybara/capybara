require 'spec_helper'

describe Capybara::Result do
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
    expect(result.length).to be_eql 4
  end

  it "has a first element" do
    expect(result.first.text).to be_eql 'Alpha'
  end

  it "has a last element" do
    expect(result.last.text).to be_eql 'Delta'
  end

  it 'can supports values_at method' do
    expect(result.values_at(0, 2).map(&:text)).to be_eql %w(Alpha Gamma)
  end

  it "can return an element by its index" do
    expect(result.at(1).text).to be_eql 'Beta'
    expect(result[2].text).to be_eql 'Gamma'
  end

  it "can be mapped" do
    expect(result.map(&:text)).to be_eql %w(Alpha Beta Gamma Delta)
  end

  it "can be selected" do
    expect(result.select { |element| element.text.include? 't'}.length).to be_eql 2
  end

  it "can be reduced" do
    expect(result.reduce('') { |memo, element| memo += element.text[0] }).to be_eql 'ABGD'
  end

  it 'can be sampled' do
    expect(result).to include(result.sample)
  end

  it 'can be indexed' do
    expect(result.index { |el| el.text == 'Gamma' }).to be_eql 2
  end
end
