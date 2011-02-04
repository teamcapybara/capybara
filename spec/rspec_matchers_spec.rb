require 'spec_helper'
require 'capybara/dsl'
require 'capybara/rspec_matchers'

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
          page.should have_selector('//h1')
        end

        it "fails if has_css? returns false" do
          expect do
            page.should have_selector("//h1[@id='doesnotexist']")
          end.to raise_error(%r(expected xpath "//h1\[@id='doesnotexist'\]" to return something))
        end
      end

      context "with should_not" do
        it "passes if has_no_css? returns true" do
          page.should_not have_selector(:css, 'h1#doesnotexist')
        end

        it "fails if has_no_css? returns false" do
          expect do
            page.should_not have_selector(:css, 'h1')
          end.to raise_error(%r(expected css "h1" not to return anything))
        end
      end
    end
  end
end

