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
    result.length.should == 4
  end

  it "has a first element" do
    result.first.text == 'Alpha'
  end

  it "has a last element" do
    result.last.text == 'Delta'
  end

  it 'can supports values_at method' do
    result.values_at(0, 2).map(&:text).should == %w(Alpha Gamma)
  end

  it "can return an element by its index" do
    result.at(1).text.should == 'Beta'
    result[2].text.should == 'Gamma'
  end

  it "can be mapped" do
    result.map(&:text).should == %w(Alpha Beta Gamma Delta)
  end

  it "can be selected" do
    result.select do |element|
      element.text.include? 't'
    end.length.should == 2
  end

  it "can be reduced" do
    result.reduce('') do |memo, element|
      memo += element.text[0]
    end.should == 'ABGD'
  end

  it 'can be sampled' do
    result.should include(result.sample)
  end

  it 'can be indexed' do
    result.index do |el|
      el.text == 'Gamma'
    end.should == 2
  end
end
