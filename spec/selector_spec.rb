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
            <div id="#special">
            </div>
            <input id="2checkbox" class="2checkbox" type="checkbox"/>
            <input type="radio"/>
            <label for="my_text_input">My Text Input</label>
            <input type="text" name="form[my_text_input]" placeholder="my text" id="my_text_input"/>
            <input type="file" id="file" class=".special file"/>
            <input type="hidden" id="hidden_field" value="this is hidden"/>
            <input type="submit" value="click me" title="submit button"/>
            <a href="#">link</a>
            <fieldset></fieldset>
            <select id="select">
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

      Capybara.add_selector :custom_css_selector do
        css { |selector| selector }
      end
    end

    describe "adding a selector" do
      it "can set default visiblity" do
        Capybara.add_selector :hidden_field do
          visible :hidden
          css { |_sel| 'input[type="hidden"]' }
        end

        expect(string).to have_no_css('input[type="hidden"]')
        expect(string).to have_selector(:hidden_field)
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
          css { |css_class| "p.#{css_class}" }
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
            link_or_button: ".//a[./@href] | .//input[./@type = 'submit' or ./@type = 'reset' or ./@type = 'image' or ./@type = 'button'] | .//button",
            fillable_field: ".//*[self::input | self::textarea][not(./@type = 'submit' or ./@type = 'image' or ./@type = 'radio' or ./@type = 'checkbox' or ./@type = 'hidden' or ./@type = 'file')]",
            radio_button: ".//input[./@type = 'radio']",
            checkbox: ".//input[./@type = 'checkbox']",
            select: ".//select",
            option: ".//option",
            file_field: ".//input[./@type = 'file']",
            table: ".//table"
          }
          selectors.each do |selector, xpath|
            results = string.all(selector, nil).to_a.map(&:native)
            expect(results.size).to be > 0
            expect(results).to eq string.all(:xpath, xpath).to_a.map(&:native)
          end
        end
      end

      context "with :id option" do
        it "works with compound css selectors" do
          expect(string.all(:custom_css_selector, "div, h1", id: 'page').size).to eq 1
          expect(string.all(:custom_css_selector, "h1, div", id: 'page').size).to eq 1
        end

        it "works with 'special' characters" do
          expect(string.find(:custom_css_selector, "div", id: "#special")[:id]).to eq '#special'
          expect(string.find(:custom_css_selector, "input", id: "2checkbox")[:id]).to eq '2checkbox'
        end
      end

      context "with :class option" do
        it "works with compound css selectors" do
          expect(string.all(:custom_css_selector, "div, h1", class: 'a').size).to eq 2
          expect(string.all(:custom_css_selector, "h1, div", class: 'a').size).to eq 2
        end

        it "works with 'special' characters" do
          expect(string.find(:custom_css_selector, "input", class: ".special")[:id]).to eq 'file'
          expect(string.find(:custom_css_selector, "input", class: "2checkbox")[:id]).to eq '2checkbox'
        end
      end

      # :css, :xpath, :id, :field, :fieldset, :link, :button, :link_or_button, :fillable_field, :radio_button, :checkbox, :select,
      # :option, :file_field, :label, :table, :frame

      describe ":css selector" do
        it "finds by CSS locator" do
          expect(string.find(:css, "input#my_text_input")[:name]).to eq 'form[my_text_input]'
        end
      end

      describe ":xpath selector" do
        it "finds by XPath locator" do
          expect(string.find(:xpath, './/input[@id="my_text_input"]')[:name]).to eq 'form[my_text_input]'
        end
      end

      describe ":id selector" do
        it "finds by locator" do
          expect(string.find(:id, "my_text_input")[:name]).to eq 'form[my_text_input]'
        end
      end

      describe ":field selector" do
        it "finds by locator" do
          expect(string.find(:field, 'My Text Input')[:id]).to eq 'my_text_input'
          expect(string.find(:field, 'my_text_input')[:id]).to eq 'my_text_input'
          expect(string.find(:field, 'form[my_text_input]')[:id]).to eq 'my_text_input'
        end

        it "finds by id" do
          expect(string.find(:field, id: 'my_text_input')[:name]).to eq 'form[my_text_input]'
        end

        it "finds by name" do
          expect(string.find(:field, name: 'form[my_text_input]')[:id]).to eq 'my_text_input'
        end

        it "finds by placeholder" do
          expect(string.find(:field, placeholder: 'my text')[:id]).to eq 'my_text_input'
        end

        it "finds by type" do
          expect(string.find(:field, type: 'file')[:id]).to eq 'file'
          expect(string.find(:field, type: 'select')[:id]).to eq 'select'
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

      describe ":button selector" do
        it "finds by value" do
          expect(string.find(:button, 'click me').value).to eq 'click me'
        end

        it "finds by title" do
          expect(string.find(:button, 'submit button').value).to eq 'click me'
        end

        it "includes non-matching parameters in failure message" do
          expect { string.find(:button, 'click me', title: 'click me') }.to raise_error(/with title click me/)
        end
      end
    end
  end
end
