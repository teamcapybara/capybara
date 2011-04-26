require 'spec_helper'
require 'capybara/dsl'
require 'capybara/rspec/matchers'

Capybara.app = TestApp

describe Capybara::RSpecMatchers do
  include Capybara::DSL
  include Capybara::RSpecMatchers

  describe "have_css matcher" do
    it "gives proper description" do
      have_css('h1').description.should == "has css \"h1\""
    end

    context "on a string" do
      context "with should" do
        it "passes if has_css? returns true" do
          "<h1>Text</h1>".should have_css('h1')
        end

        it "fails if has_css? returns false" do
          expect do
            "<h1>Text</h1>".should have_css('h2')
          end.to raise_error(/expected css "h2" to return something/)
        end

        it "passes if matched node count equals expected count" do
          "<h1>Text</h1>".should have_css('h1', :count => 1)
        end

        it "fails if matched node count does not equal expected count" do
          expect do
            "<h1>Text</h1>".should have_css('h1', :count => 2)
          end.to raise_error(/expected css "h1" to return something/)
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          "<h1>Text</h1>".should_not have_css('h2')
        end

        it "fails if has_no_css? returns false" do
          expect do
            "<h1>Text</h1>".should_not have_css('h1')
          end.to raise_error(/expected css "h1" not to return anything/)
        end

        it "passes if matched node count does not equal expected count" do
          "<h1>Text</h1>".should_not have_css('h1', :count => 2)
        end

        it "fails if matched node count equals expected count" do
          expect do
            "<h1>Text</h1>".should_not have_css('h1', :count => 1)
          end.to raise_error(/expected css "h1" not to return anything/)
        end
      end
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_css? returns true" do
          page.should have_css('h1')
        end

        it "fails if has_css? returns false" do
          expect do
            page.should have_css('h1#doesnotexist')
          end.to raise_error(/expected css "h1#doesnotexist" to return something/)
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          page.should_not have_css('h1#doesnotexist')
        end

        it "fails if has_no_css? returns false" do
          expect do
            page.should_not have_css('h1')
          end.to raise_error(/expected css "h1" not to return anything/)
        end
      end
    end
  end

  describe "have_xpath matcher" do
    it "gives proper description" do
      have_xpath('//h1').description.should == "has xpath \"\/\/h1\""
    end

    context "on a string" do
      context "with should" do
        it "passes if has_css? returns true" do
          "<h1>Text</h1>".should have_xpath('//h1')
        end

        it "fails if has_css? returns false" do
          expect do
            "<h1>Text</h1>".should have_xpath('//h2')
          end.to raise_error(%r(expected xpath "//h2" to return something))
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          "<h1>Text</h1>".should_not have_xpath('//h2')
        end

        it "fails if has_no_css? returns false" do
          expect do
            "<h1>Text</h1>".should_not have_xpath('//h1')
          end.to raise_error(%r(expected xpath "//h1" not to return anything))
        end
      end
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_css? returns true" do
          page.should have_xpath('//h1')
        end

        it "fails if has_css? returns false" do
          expect do
            page.should have_xpath("//h1[@id='doesnotexist']")
          end.to raise_error(%r(expected xpath "//h1\[@id='doesnotexist'\]" to return something))
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          page.should_not have_xpath('//h1[@id="doesnotexist"]')
        end

        it "fails if has_no_css? returns false" do
          expect do
            page.should_not have_xpath('//h1')
          end.to raise_error(%r(expected xpath "//h1" not to return anything))
        end
      end
    end
  end

  describe "have_selector matcher" do
    it "gives proper description" do
      have_selector('//h1').description.should == "has xpath \"//h1\""
    end

    context "on a string" do
      context "with should" do
        it "passes if has_css? returns true" do
          "<h1>Text</h1>".should have_selector('//h1')
        end

        it "fails if has_css? returns false" do
          expect do
            "<h1>Text</h1>".should have_selector('//h2')
          end.to raise_error(%r(expected xpath "//h2" to return something))
        end

        it "fails with the selector's failure_message if set" do
          Capybara.add_selector(:monkey) do
            xpath { |num| ".//*[contains(@id, 'monkey')][#{num}]" }
            failure_message { |node, selector| node.all(".//*[contains(@id, 'monkey')]").map { |node| node.text }.sort.join(', ') }
          end
          expect do
            '<h1 id="monkey_paul">Monkey John</h1>'.should have_selector(:monkey, 14)
          end.to raise_error("Monkey John")
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          "<h1>Text</h1>".should_not have_selector(:css, 'h2')
        end

        it "fails if has_no_css? returns false" do
          expect do
            "<h1>Text</h1>".should_not have_selector(:css, 'h1')
          end.to raise_error(%r(expected css "h1" not to return anything))
        end
      end
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_css? returns true" do
          page.should have_selector('//h1', :text => 'test')
        end

        it "fails if has_css? returns false" do
          expect do
            page.should have_selector("//h1[@id='doesnotexist']")
          end.to raise_error(%r(expected xpath "//h1\[@id='doesnotexist'\]" to return something))
        end

        it "includes text in error message" do
          expect do
            page.should have_selector("//h1", :text => 'wrong text')
          end.to raise_error(%r(expected xpath "//h1" with text "wrong text" to return something))
        end

        it "fails with the selector's failure_message if set" do
          Capybara.add_selector(:monkey) do
            xpath { |num| ".//*[contains(@id, 'monkey')][#{num}]" }
            failure_message { |node, selector| node.all(".//*[contains(@id, 'monkey')]").map { |node| node.text }.sort.join(', ') }
          end
          expect do
            page.should have_selector(:monkey, 14)
          end.to raise_error("Monkey John, Monkey Paul")
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          page.should_not have_selector(:css, 'h1#doesnotexist')
        end

        it "fails if has_no_css? returns false" do
          expect do
            page.should_not have_selector(:css, 'h1', :text => 'test')
          end.to raise_error(%r(expected css "h1" with text "test" not to return anything))
        end
      end
    end
  end

  describe "have_content matcher" do
    it "gives proper description" do
      have_content('Text').description.should == "has content \"Text\""
    end

    context "on a string" do
      context "with should" do
        it "passes if has_css? returns true" do
          "<h1>Text</h1>".should have_content('Text')
        end

        it "fails if has_css? returns false" do
          expect do
            "<h1>Text</h1>".should have_content('No such Text')
          end.to raise_error(/expected there to be content "No such Text" in "Text"/)
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          "<h1>Text</h1>".should_not have_content('No such Text')
        end

        it "fails if has_no_css? returns false" do
          expect do
            "<h1>Text</h1>".should_not have_content('Text')
          end.to raise_error(/expected content "Text" not to return anything/)
        end
      end
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_css? returns true" do
          page.should have_content('This is a test')
        end

        it "fails if has_css? returns false" do
          expect do
            page.should have_content('No such Text')
          end.to raise_error(/expected there to be content "No such Text" in "(.*)This is a test(.*)"/)
        end

        context "with default selector CSS" do
          before { Capybara.default_selector = :css }
          it "fails if has_css? returns false" do
            expect do
              page.should have_content('No such Text')
            end.to raise_error(/expected there to be content "No such Text" in "(.*)This is a test(.*)"/)
          end
          after { Capybara.default_selector = :xpath }
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          page.should_not have_content('No such Text')
        end

        it "fails if has_no_css? returns false" do
          expect do
            page.should_not have_content('This is a test')
          end.to raise_error(/expected content "This is a test" not to return anything/)
        end
      end
    end
  end

  describe "have_link matcher" do
    let(:html) { '<a href="#">Just a link</a>' }

    it "gives proper description" do
      have_link('Just a link').description.should == "has link \"Just a link\""
    end

    it "passes if there is such a button" do
      html.should have_link('Just a link')
    end

    it "fails if there is no such button" do
      expect do
        html.should have_link('No such Link')
      end.to raise_error(/expected link "No such Link"/)
    end
  end

  describe "have_button matcher" do
    let(:html) { '<button>A button</button><input type="submit" value="Another button"/>' }

    it "gives proper description" do
      have_button('A button').description.should == "has button \"A button\""
    end

    it "passes if there is such a button" do
      html.should have_button('A button')
    end

    it "fails if there is no such button" do
      expect do
        html.should have_button('No such Button')
      end.to raise_error(/expected button "No such Button"/)
    end
  end

  describe "have_field matcher" do
    let(:html) { '<p><label>Text field<input type="text"/></label></p>' }

    it "gives proper description" do
      have_field('Text field').description.should == "has field \"Text field\""
    end

    it "passes if there is such a field" do
      html.should have_field('Text field')
    end

    it "fails if there is no such field" do
      expect do
        html.should have_field('No such Field')
      end.to raise_error(/expected field "No such Field"/)
    end
  end

  describe "have_checked_field matcher" do
    let(:html) do
      '<label>it is checked<input type="checkbox" checked="checked"/></label>
      <label>unchecked field<input type="checkbox"/></label>'
    end

    it "gives proper description" do
      have_checked_field('it is checked').description.should == "has checked_field \"it is checked\""
    end

    context "with should" do
      it "passes if there is such a field and it is checked" do
        html.should have_checked_field('it is checked')
      end

      it "fails if there is such a field but it is not checked" do
        expect do
          html.should have_checked_field('unchecked field')
        end.to raise_error(/expected checked_field "unchecked field"/)
      end

      it "fails if there is no such field" do
        expect do
          html.should have_checked_field('no such field')
        end.to raise_error(/expected checked_field "no such field"/)
      end
    end

    context "with should not" do
      it "fails if there is such a field and it is checked" do
        expect do
          html.should_not have_checked_field('it is checked')
        end.to raise_error(/expected checked_field "it is checked" not to return anything/)
      end

      it "passes if there is such a field but it is not checked" do
        html.should_not have_checked_field('unchecked field')
      end

      it "passes if there is no such field" do
        html.should_not have_checked_field('no such field')
      end
    end
  end

  describe "have_unchecked_field matcher" do
    let(:html) do
      '<label>it is checked<input type="checkbox" checked="checked"/></label>
      <label>unchecked field<input type="checkbox"/></label>'
    end

    it "gives proper description" do
      have_unchecked_field('unchecked field').description.should == "has unchecked_field \"unchecked field\""
    end

    context "with should" do
      it "passes if there is such a field and it is not checked" do
        html.should have_unchecked_field('unchecked field')
      end

      it "fails if there is such a field but it is checked" do
        expect do
          html.should have_unchecked_field('it is checked')
        end.to raise_error(/expected unchecked_field "it is checked"/)
      end

      it "fails if there is no such field" do
        expect do
          html.should have_unchecked_field('no such field')
        end.to raise_error(/expected unchecked_field "no such field"/)
      end
    end

    context "with should not" do
      it "fails if there is such a field and it is not checked" do
        expect do
          html.should_not have_unchecked_field('unchecked field')
        end.to raise_error(/expected unchecked_field "unchecked field" not to return anything/)
      end

      it "passes if there is such a field but it is checked" do
        html.should_not have_unchecked_field('it is checked')
      end

      it "passes if there is no such field" do
        html.should_not have_unchecked_field('no such field')
      end
    end
  end

  describe "have_select matcher" do
    let(:html) { '<label>Select Box<select></select></label>' }

    it "gives proper description" do
      have_select('Select Box').description.should == "has select \"Select Box\""
    end

    it "passes if there is such a select" do
      html.should have_select('Select Box')
    end

    it "fails if there is no such select" do
      expect do
        html.should have_select('No such Select box')
      end.to raise_error(/expected select "No such Select box"/)
    end
  end

  describe "have_table matcher" do
    let(:html) { '<table><caption>Lovely table</caption></table>' }

    it "gives proper description" do
      have_table('Lovely table').description.should == "has table \"Lovely table\""
    end

    it "passes if there is such a select" do
      html.should have_table('Lovely table')
    end

    it "fails if there is no such select" do
      expect do
        html.should have_table('No such Table')
      end.to raise_error(/expected table "No such Table"/)
    end
  end
end

