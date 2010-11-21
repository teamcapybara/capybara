require 'spec_helper'

describe Capybara do
  describe '.string' do
    let :string do
      Capybara.string <<-STRING
        <div id="page">
          <div id="content">
            <h1 data="fantastic">Awesome</h1>
            <p>Yes it is</p>
          </div>

          <div id="footer" style="display: none">
            <p>c2010</p>
            <p>Jonas Nicklas</p>
            <input type="text" name="foo" value="bar"/>
            <select name="animal">
              <option>Monkey</option>
              <option selected="selected">Capybara</option>
            </select>
          </div>
        </div>
      STRING
    end

    it "allows using matchers" do
      string.should have_css('#page')
      string.should_not have_css('#does-not-exist')
    end

    it "allows using custom matchers" do
      Capybara.add_selector :lifeform do
        xpath { |name| "//option[contains(.,'#{name}')]" }
      end
      string.should have_selector(:page)
      string.should_not have_selector(:'does-not-exist')
      string.should have_selector(:lifeform, "Monkey")
      string.should_not have_selector(:lifeform, "Gorilla")
    end

    it "allows using matchers with text option" do
      string.should have_css('h1', :text => 'Awesome')
      string.should_not have_css('h1', :text => 'Not so awesome')
    end

    it "allows finding only visible nodes" do
      string.all('//p', :text => 'c2010', :visible => true).should be_empty
      string.all('//p', :text => 'c2010', :visible => false).should have(1).element
    end

    it "allows finding elements and extracting text from them" do
      string.find('//h1').text.should == 'Awesome'
    end

    it "allows finding elements and extracting attributes from them" do
      string.find('//h1')[:data].should == 'fantastic'
    end

    it "allows finding elements and extracting the tag name from them" do
      string.find('//h1').tag_name.should == 'h1'
    end

    it "allows finding elements and extracting the path" do
      string.find('//h1').path.should == '/html/body/div/div[1]/h1'
    end

    it "allows finding elements and extracting the path" do
      string.find('//input').value.should == 'bar'
      string.find('//select').value.should == 'Capybara'
    end

    it "allows finding elements and checking if they are visible" do
      string.find('//h1').should be_visible
      string.find('//input').should_not be_visible
    end
  end
end
