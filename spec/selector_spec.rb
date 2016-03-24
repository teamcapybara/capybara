# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Capybara do
  describe 'Selectors' do
    let :string do
      Capybara.string <<-STRING
        <html>
          <head>
            <title>selectors</title>
          </head>
          <body>
            <div class="a" id="page">
              <div class="b" id="content">
                <h1 class="a">Totally awesome</h1>
                <p>Yes it is</p>
              </div>
              <p class="b">Some Content</p>
              <p class="b"></p>
            </div>
            <input type="checkbox"/>
            <input type="radio"/>
            <input type="text"/>
            <input type="file"/>
            <a href="#">link</a>
            <fieldset></fieldset>
            <select>
              <option value="a">A</option>
              <option value="b" disabled>B</option>
              <option value="c" selected>C</option>
            </select>
            <table>
              <tr><td></td></tr>
            </table
          </body>
        </html>
      STRING
    end

    before do
      Capybara.add_selector :custom_selector do
        css { |css_class| "div.#{css_class}" }
        filter(:not_empty, boolean: true, default: true, skip_if: :all) { |node, value| value ^ (node.text == '') }
      end
    end

    describe "modify_selector" do
      it "allows modifying a selector" do
        el = string.find(:custom_selector, 'a')
        expect(el.tag_name).to eq 'div'
        Capybara.modify_selector :custom_selector do
          css { |css_class| "h1.#{css_class}" }
        end
        el = string.find(:custom_selector, 'a')
        expect(el.tag_name).to eq 'h1'
      end

      it "doesn't change existing filters" do
        Capybara.modify_selector :custom_selector do
          css { |css_class| "p.#{css_class}"}
        end
        expect(string).to have_selector(:custom_selector, 'b', count: 1)
        expect(string).to have_selector(:custom_selector, 'b', not_empty: false, count: 1)
        expect(string).to have_selector(:custom_selector, 'b', not_empty: :all, count: 2)
      end
    end

    describe "builtin selectors" do
      context "when locator is nil" do
        it "devolves to just finding element types" do
          selectors = {
            field: ".//*[self::input | self::textarea | self::select][not(./@type = 'submit' or ./@type = 'image' or ./@type = 'hidden')]",
            fieldset: ".//fieldset",
            link: ".//a[./@href]",
            link_or_button: ".//a[./@href] | .//input[./@type = 'submit' or ./@type = 'reset' or ./@type = 'image' or ./@type = 'button'] | .//button" ,
            fillable_field: ".//*[self::input | self::textarea][not(./@type = 'submit' or ./@type = 'image' or ./@type = 'radio' or ./@type = 'checkbox' or ./@type = 'hidden' or ./@type = 'file')]",
            radio_button: ".//input[./@type = 'radio']",
            checkbox: ".//input[./@type = 'checkbox']",
            select: ".//select",
            option: ".//option",
            file_field: ".//input[./@type = 'file']",
            table: ".//table"
          }
          selectors.each do |selector, xpath|
            results = string.all(selector,nil).to_a.map &:native
            expect(results.size).to be > 0
            expect(results).to eq string.all(:xpath, xpath).to_a.map(&:native)
          end
        end
      end

      describe ":option selector" do
        it "finds disabled options" do
          expect(string.find(:option, disabled: true).value).to eq 'b'
        end

        it "finds selected options" do
          expect(string.find(:option, selected: true).value).to eq 'c'
        end

        it "finds not selected and not disabled options" do
          expect(string.find(:option, disabled: false, selected: false).value).to eq 'a'
        end
      end
    end
  end
end
