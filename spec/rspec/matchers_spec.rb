require 'spec_helper'
require 'capybara/dsl'
require 'capybara/rspec/matchers'

Capybara.app = TestApp

describe Capybara::RSpecMatchers do
  include Capybara
  include Capybara::RSpecMatchers

  describe "have_css matcher" do
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

  describe "have_link matcher"

  describe "have_button matcher" do
    let(:html) { '<button>A button</button><input type="submit" value="Another button"/>' }

    it "passes if there is such a button" do
      html.should have_button('A button')
    end

    it "fails if there is no such button" do
      expect do
        html.should have_button('No such Button')
      end.to raise_error(/expected there to be a button "No such Button", other buttons: "A button", "Another button"/)
    end
  end

  describe "have_field matcher" do
    let(:html) { '<button>A button</button><button>Another button</button>' }

    it "passes if there is such a button" do
      html.should have_button('A button')
    end

    it "fails if there is no such button" do
      expect do
        html.should have_button('No such Button')
      end.to raise_error(/expected there to be a button "No such Button", other buttons: "A button", "Another button"/)
    end
  end

  describe "have_checked_field matcher"
  describe "have_unchecked_field matcher"
  describe "have_select matcher"
  describe "have_table matcher"
end

