require 'spec_helper'
require 'capybara/dsl'
require 'capybara/rspec/matchers'

describe Capybara::RSpecMatchers do
  include Capybara::DSL
  include Capybara::RSpecMatchers

  describe "have_css matcher" do
    it "gives proper description" do
      have_css('h1').description.should == "have css \"h1\""
    end

    context "on a string" do
      context "with should" do
        it "passes if has_css? returns true" do
          "<h1>Text</h1>".should have_css('h1')
        end

        it "fails if has_css? returns false" do
          expect do
            "<h1>Text</h1>".should have_css('h2')
          end.to raise_error(/expected to find css "h2" but there were no matches/)
        end

        it "passes if matched node count equals expected count" do
          "<h1>Text</h1>".should have_css('h1', :count => 1)
        end

        it "fails if matched node count does not equal expected count" do
          expect do
            "<h1>Text</h1>".should have_css('h1', count: 2)
          end.to raise_error("expected to find css \"h1\" 2 times, found 1 match: \"Text\"")
        end

        it "fails if matched node count is less than expected minimum count" do
          expect do
            "<h1>Text</h1>".should have_css('p', minimum: 1)
          end.to raise_error("expected to find css \"p\" at least 1 time but there were no matches")
        end

        it "fails if matched node count is more than expected maximum count" do
          expect do
            "<h1>Text</h1><h1>Text</h1><h1>Text</h1>".should have_css('h1', maximum: 2)
          end.to raise_error('expected to find css "h1" at most 2 times, found 3 matches: "Text", "Text", "Text"')
        end

        it "fails if matched node count does not belong to expected range" do
          expect do
            "<h1>Text</h1>".should have_css('h1', between: 2..3)
          end.to raise_error("expected to find css \"h1\" between 2 and 3 times, found 1 match: \"Text\"")
        end

      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          "<h1>Text</h1>".should_not have_css('h2')
        end

        it "fails if has_no_css? returns false" do
          expect do
            "<h1>Text</h1>".should_not have_css('h1')
          end.to raise_error(/expected not to find css "h1"/)
        end

        it "passes if matched node count does not equal expected count" do
          "<h1>Text</h1>".should_not have_css('h1', :count => 2)
        end

        it "fails if matched node count equals expected count" do
          expect do
            "<h1>Text</h1>".should_not have_css('h1', :count => 1)
          end.to raise_error(/expected not to find css "h1"/)
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
          end.to raise_error(/expected to find css "h1#doesnotexist" but there were no matches/)
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          page.should_not have_css('h1#doesnotexist')
        end

        it "fails if has_no_css? returns false" do
          expect do
            page.should_not have_css('h1')
          end.to raise_error(/expected not to find css "h1"/)
        end
      end
    end
  end

  describe "have_xpath matcher" do
    it "gives proper description" do
      have_xpath('//h1').description.should == "have xpath \"\/\/h1\""
    end

    context "on a string" do
      context "with should" do
        it "passes if has_xpath? returns true" do
          "<h1>Text</h1>".should have_xpath('//h1')
        end

        it "fails if has_xpath? returns false" do
          expect do
            "<h1>Text</h1>".should have_xpath('//h2')
          end.to raise_error(%r(expected to find xpath "//h2" but there were no matches))
        end
      end

      context "with should_not" do
        it "passes if has_no_xpath? returns true" do
          "<h1>Text</h1>".should_not have_xpath('//h2')
        end

        it "fails if has_no_xpath? returns false" do
          expect do
            "<h1>Text</h1>".should_not have_xpath('//h1')
          end.to raise_error(%r(expected not to find xpath "//h1"))
        end
      end
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_xpath? returns true" do
          page.should have_xpath('//h1')
        end

        it "fails if has_xpath? returns false" do
          expect do
            page.should have_xpath("//h1[@id='doesnotexist']")
          end.to raise_error(%r(expected to find xpath "//h1\[@id='doesnotexist'\]" but there were no matches))
        end
      end

      context "with should_not" do
        it "passes if has_no_xpath? returns true" do
          page.should_not have_xpath('//h1[@id="doesnotexist"]')
        end

        it "fails if has_no_xpath? returns false" do
          expect do
            page.should_not have_xpath('//h1')
          end.to raise_error(%r(expected not to find xpath "//h1"))
        end
      end
    end
  end

  describe "have_selector matcher" do
    it "gives proper description" do
      matcher = have_selector('//h1')
      "<h1>Text</h1>".should matcher
      matcher.description.should == "have xpath \"//h1\""
    end

    context "on a string" do
      context "with should" do
        it "passes if has_selector? returns true" do
          "<h1>Text</h1>".should have_selector('//h1')
        end

        it "fails if has_selector? returns false" do
          expect do
            "<h1>Text</h1>".should have_selector('//h2')
          end.to raise_error(%r(expected to find xpath "//h2" but there were no matches))
        end
      end

      context "with should_not" do
        it "passes if has_no_selector? returns true" do
          "<h1>Text</h1>".should_not have_selector(:css, 'h2')
        end

        it "fails if has_no_selector? returns false" do
          expect do
            "<h1>Text</h1>".should_not have_selector(:css, 'h1')
          end.to raise_error(%r(expected not to find css "h1"))
        end
      end
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_selector? returns true" do
          page.should have_selector('//h1', :text => 'test')
        end

        it "fails if has_selector? returns false" do
          expect do
            page.should have_selector("//h1[@id='doesnotexist']")
          end.to raise_error(%r(expected to find xpath "//h1\[@id='doesnotexist'\]" but there were no matches))
        end

        it "includes text in error message" do
          expect do
            page.should have_selector("//h1", :text => 'wrong text')
          end.to raise_error(%r(expected to find xpath "//h1" with text "wrong text" but there were no matches))
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          page.should_not have_selector(:css, 'h1#doesnotexist')
        end

        it "fails if has_no_selector? returns false" do
          expect do
            page.should_not have_selector(:css, 'h1', :text => 'test')
          end.to raise_error(%r(expected not to find css "h1" with text "test"))
        end
      end
    end
  end

  describe "have_content matcher" do
    it "gives proper description" do
      have_content('Text').description.should == "text \"Text\""
    end

    context "on a string" do
      context "with should" do
        it "passes if has_content? returns true" do
          "<h1>Text</h1>".should have_content('Text')
        end

        it "passes if has_content? returns true using regexp" do
          "<h1>Text</h1>".should have_content(/ext/)
        end

        it "fails if has_content? returns false" do
          expect do
            "<h1>Text</h1>".should have_content('No such Text')
          end.to raise_error(/expected to find text "No such Text" in "Text"/)
        end
      end

      context "with should_not" do
        it "passes if has_no_content? returns true" do
          "<h1>Text</h1>".should_not have_content('No such Text')
        end

        it "passes because escapes any characters that would have special meaning in a regexp" do
          "<h1>Text</h1>".should_not have_content('.')
        end

        it "fails if has_no_content? returns false" do
          expect do
            "<h1>Text</h1>".should_not have_content('Text')
          end.to raise_error(/expected not to find text "Text" in "Text"/)
        end
      end
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_content? returns true" do
          page.should have_content('This is a test')
        end

        it "passes if has_content? returns true using regexp" do
          page.should have_content(/test/)
        end

        it "fails if has_content? returns false" do
          expect do
            page.should have_content('No such Text')
          end.to raise_error(/expected to find text "No such Text" in "(.*)This is a test(.*)"/)
        end

        context "with default selector CSS" do
          before { Capybara.default_selector = :css }
          it "fails if has_content? returns false" do
            expect do
              page.should have_content('No such Text')
            end.to raise_error(/expected to find text "No such Text" in "(.*)This is a test(.*)"/)
          end
          after { Capybara.default_selector = :xpath }
        end
      end

      context "with should_not" do
        it "passes if has_no_content? returns true" do
          page.should_not have_content('No such Text')
        end

        it "fails if has_no_content? returns false" do
          expect do
            page.should_not have_content('This is a test')
          end.to raise_error(/expected not to find text "This is a test"/)
        end
      end
    end
  end

  describe "have_text matcher" do
    it "gives proper description" do
      have_text('Text').description.should == "text \"Text\""
    end

    context "on a string" do
      context "with should" do
        it "passes if has_text? returns true" do
          "<h1>Text</h1>".should have_text('Text')
        end

        it "passes if has_text? returns true using regexp" do
          "<h1>Text</h1>".should have_text(/ext/)
        end

        it "fails if has_text? returns false" do
          expect do
            "<h1>Text</h1>".should have_text('No such Text')
          end.to raise_error(/expected to find text "No such Text" in "Text"/)
        end

        it "casts Fixnum to string" do
          expect do
            "<h1>Text</h1>".should have_text(3)
          end.to raise_error(/expected to find text "3" in "Text"/)
        end

        it "fails if matched text count does not equal to expected count" do
          expect do
            "<h1>Text</h1>".should have_text('Text', count: 2)
          end.to raise_error(/expected to find text "Text" 2 times in "Text"/)
        end

        it "fails if matched text count is less than expected minimum count" do
          expect do
            "<h1>Text</h1>".should have_text('Lorem', minimum: 1)
          end.to raise_error(/expected to find text "Lorem" at least 1 time in "Text"/)
        end

        it "fails if matched text count is more than expected maximum count" do
          expect do
            "<h1>Text TextText</h1>".should have_text('Text', maximum: 2)
          end.to raise_error(/expected to find text "Text" at most 2 times in "Text TextText"/)
        end

        it "fails if matched text count does not belong to expected range" do
          expect do
            "<h1>Text</h1>".should have_text('Text', between: 2..3)
          end.to raise_error(/expected to find text "Text" between 2 and 3 times in "Text"/)
        end
      end

      context "with should_not" do
        it "passes if has_no_text? returns true" do
          "<h1>Text</h1>".should_not have_text('No such Text')
        end

        it "passes because escapes any characters that would have special meaning in a regexp" do
          "<h1>Text</h1>".should_not have_text('.')
        end

        it "fails if has_no_text? returns false" do
          expect do
            "<h1>Text</h1>".should_not have_text('Text')
          end.to raise_error(/expected not to find text "Text" in "Text"/)
        end
      end
    end

    context "on a page or node" do
      before do
        visit('/with_html')
      end

      context "with should" do
        it "passes if has_text? returns true" do
          page.should have_text('This is a test')
        end

        it "passes if has_text? returns true using regexp" do
          page.should have_text(/test/)
        end

        it "can check for all text" do
          page.should have_text(:all, 'Some of this text is hidden!')
        end

        it "can check for visible text" do
          page.should have_text(:visible, 'Some of this text is')
          page.should_not have_text(:visible, 'Some of this text is hidden!')
        end

        it "fails if has_text? returns false" do
          expect do
            page.should have_text('No such Text')
          end.to raise_error(/expected to find text "No such Text" in "(.*)This is a test(.*)"/)
        end

        context "with default selector CSS" do
          before { Capybara.default_selector = :css }
          it "fails if has_text? returns false" do
            expect do
              page.should have_text('No such Text')
            end.to raise_error(/expected to find text "No such Text" in "(.*)This is a test(.*)"/)
          end
          after { Capybara.default_selector = :xpath }
        end
      end

      context "with should_not" do
        it "passes if has_no_text? returns true" do
          page.should_not have_text('No such Text')
        end

        it "fails if has_no_text? returns false" do
          expect do
            page.should_not have_text('This is a test')
          end.to raise_error(/expected not to find text "This is a test"/)
        end
      end
    end
  end

  describe "have_link matcher" do
    let(:html) { '<a href="#">Just a link</a>' }

    it "gives proper description" do
      have_link('Just a link').description.should == "have link \"Just a link\""
    end

    it "passes if there is such a button" do
      html.should have_link('Just a link')
    end

    it "fails if there is no such button" do
      expect do
        html.should have_link('No such Link')
      end.to raise_error(/expected to find link "No such Link"/)
    end
  end

  describe "have_title matcher" do
    it "gives proper description" do
      have_title('Just a title').description.should == "have title \"Just a title\""
    end

    context "on a string" do
      let(:html) { '<title>Just a title</title>' }

      it "passes if there is such a title" do
        html.should have_title('Just a title')
      end

      it "fails if there is no such title" do
        expect do
          html.should have_title('No such title')
        end.to raise_error(/expected there to be title "No such title"/)
      end
    end

    context "on a page or node" do
      before do
        visit('/with_js')
      end

      it "passes if there is such a title" do
        page.should have_title('with_js')
      end

      it "fails if there is no such title" do
        expect do
          page.should have_title('No such title')
        end.to raise_error(/expected there to be title "No such title"/)
      end
    end
  end

  describe "have_button matcher" do
    let(:html) { '<button>A button</button><input type="submit" value="Another button"/>' }

    it "gives proper description" do
      have_button('A button').description.should == "have button \"A button\""
    end

    it "passes if there is such a button" do
      html.should have_button('A button')
    end

    it "fails if there is no such button" do
      expect do
        html.should have_button('No such Button')
      end.to raise_error(/expected to find button "No such Button"/)
    end
  end

  describe "have_field matcher" do
    let(:html) { '<p><label>Text field<input type="text" value="some value"/></label></p>' }

    it "gives proper description" do
      have_field('Text field').description.should == "have field \"Text field\""
    end

    it "gives proper description for a given value" do
      have_field('Text field', with: 'some value').description.should == "have field \"Text field\" with value \"some value\""
    end

    it "passes if there is such a field" do
      html.should have_field('Text field')
    end

    it "passes if there is such a field with value" do
      html.should have_field('Text field', with: 'some value')
    end

    it "fails if there is no such field" do
      expect do
        html.should have_field('No such Field')
      end.to raise_error(/expected to find field "No such Field"/)
    end

    it "fails if there is such field but with false value" do
      expect do
        html.should have_field('Text field', with: 'false value')
      end.to raise_error(/expected to find field "Text field"/)
    end

    it "treats a given value as a string" do
      class Foo
        def to_s
          "some value"
        end
      end
      html.should have_field('Text field', with: Foo.new)
    end
  end

  describe "have_checked_field matcher" do
    let(:html) do
      '<label>it is checked<input type="checkbox" checked="checked"/></label>
      <label>unchecked field<input type="checkbox"/></label>'
    end

    it "gives proper description" do
      have_checked_field('it is checked').description.should == "have field \"it is checked\""
    end

    context "with should" do
      it "passes if there is such a field and it is checked" do
        html.should have_checked_field('it is checked')
      end

      it "fails if there is such a field but it is not checked" do
        expect do
          html.should have_checked_field('unchecked field')
        end.to raise_error(/expected to find field "unchecked field"/)
      end

      it "fails if there is no such field" do
        expect do
          html.should have_checked_field('no such field')
        end.to raise_error(/expected to find field "no such field"/)
      end
    end

    context "with should not" do
      it "fails if there is such a field and it is checked" do
        expect do
          html.should_not have_checked_field('it is checked')
        end.to raise_error(/expected not to find field "it is checked"/)
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
      have_unchecked_field('unchecked field').description.should == "have field \"unchecked field\""
    end

    context "with should" do
      it "passes if there is such a field and it is not checked" do
        html.should have_unchecked_field('unchecked field')
      end

      it "fails if there is such a field but it is checked" do
        expect do
          html.should have_unchecked_field('it is checked')
        end.to raise_error(/expected to find field "it is checked"/)
      end

      it "fails if there is no such field" do
        expect do
          html.should have_unchecked_field('no such field')
        end.to raise_error(/expected to find field "no such field"/)
      end
    end

    context "with should not" do
      it "fails if there is such a field and it is not checked" do
        expect do
          html.should_not have_unchecked_field('unchecked field')
        end.to raise_error(/expected not to find field "unchecked field"/)
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
      have_select('Select Box').description.should == "have select box \"Select Box\""
    end

    it "passes if there is such a select" do
      html.should have_select('Select Box')
    end

    it "fails if there is no such select" do
      expect do
        html.should have_select('No such Select box')
      end.to raise_error(/expected to find select box "No such Select box"/)
    end
  end

  describe "have_table matcher" do
    let(:html) { '<table><caption>Lovely table</caption></table>' }

    it "gives proper description" do
      have_table('Lovely table').description.should == "have table \"Lovely table\""
    end

    it "passes if there is such a select" do
      html.should have_table('Lovely table')
    end

    it "fails if there is no such select" do
      expect do
        html.should have_table('No such Table')
      end.to raise_error(/expected to find table "No such Table"/)
    end
  end
end
