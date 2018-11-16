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
            <div class="aa" id="page">
              <div class="bb" id="content">
                <h1 class="aa">Totally awesome</h1>
                <p>Yes it is</p>
              </div>
              <p class="bb cc">Some Content</p>
              <p class="bb dd !mine"></p>
            </div>
            <div id="#special">
            </div>
            <div class="some random words" id="random_words">
              Something
            </div>
            <input id="2checkbox" class="2checkbox" type="checkbox"/>
            <input type="radio"/>
            <label for="my_text_input">My Text Input</label>
            <input type="text" name="form[my_text_input]" placeholder="my text" id="my_text_input"/>
            <input type="file" id="file" class=".special file"/>
            <input type="hidden" id="hidden_field" value="this is hidden"/>
            <input type="submit" value="click me" title="submit button"/>
            <input type="button" value="don't click me" title="Other button 1"/>
            <a href="#">link</a>
            <fieldset></fieldset>
            <select id="select">
              <option value="a">A</option>
              <option value="b" disabled>B</option>
              <option value="c" selected>C</option>
            </select>
            <table>
              <tr><td></td></tr>
            </table>
          </body>
        </html>
      STRING
    end

    before do
      Capybara.add_selector :custom_selector do
        css { |css_class| "div.#{css_class}" }
        node_filter(:not_empty, boolean: true, default: true, skip_if: :all) { |node, value| value ^ (node.text == '') }
      end

      Capybara.add_selector :custom_css_selector do
        css(:name, :other_name) do |selector, name: nil, **|
          selector ||= ''
          selector += "[name='#{name}']" if name
          selector
        end

        expression_filter(:placeholder) do |expr, val|
          expr + "[placeholder='#{val}']"
        end

        expression_filter(:value) do |expr, val|
          expr + "[value='#{val}']"
        end

        expression_filter(:title) do |expr, val|
          expr + "[title='#{val}']"
        end
      end

      Capybara.add_selector :custom_xpath_selector do
        xpath(:valid1, :valid2) { |selector| selector }
      end
    end

    it 'supports `filter` as an alias for `node_filter`' do
      expect do
        Capybara.add_selector :filter_alias_selector do
          css { |_unused| 'div' }
          filter(:something) { |_node, _value| true }
        end
      end.not_to raise_error
    end

    describe 'adding a selector' do
      it 'can set default visiblity' do
        Capybara.add_selector :hidden_field do
          visible :hidden
          css { |_sel| 'input[type="hidden"]' }
        end

        expect(string).to have_no_css('input[type="hidden"]')
        expect(string).to have_selector(:hidden_field)
      end
    end

    describe 'modify_selector' do
      it 'allows modifying a selector' do
        el = string.find(:custom_selector, 'aa')
        expect(el.tag_name).to eq 'div'
        Capybara.modify_selector :custom_selector do
          css { |css_class| "h1.#{css_class}" }
        end
        el = string.find(:custom_selector, 'aa')
        expect(el.tag_name).to eq 'h1'
      end

      it "doesn't change existing filters" do
        Capybara.modify_selector :custom_selector do
          css { |css_class| "p.#{css_class}" }
        end
        expect(string).to have_selector(:custom_selector, 'bb', count: 1)
        expect(string).to have_selector(:custom_selector, 'bb', not_empty: false, count: 1)
        expect(string).to have_selector(:custom_selector, 'bb', not_empty: :all, count: 2)
      end
    end

    describe 'xpath' do
      it 'uses filter names passed in' do
        selector = Capybara::Selector.new :test do
          xpath(:something, :other) { |_locator| XPath.descendant }
        end

        expect(selector.expression_filters.keys).to include(:something, :other)
      end

      it 'gets filter names from block if none passed to xpath method' do
        selector = Capybara::Selector.new :test do
          xpath { |_locator, valid3:, valid4: nil| "#{valid3} #{valid4}" }
        end

        expect(selector.expression_filters.keys).to include(:valid3, :valid4)
      end

      it 'ignores block parameters if names passed in' do
        selector = Capybara::Selector.new :test do
          xpath(:valid1) { |_locator, valid3:, valid4: nil| "#{valid3} #{valid4}" }
        end

        expect(selector.expression_filters.keys).to include(:valid1)
        expect(selector.expression_filters.keys).not_to include(:valid3, :valid4)
      end
    end

    describe 'css' do
      it "supports filters specified in 'css' definition" do
        expect(string).to have_selector(:custom_css_selector, 'input', name: 'form[my_text_input]')
        expect(string).to have_no_selector(:custom_css_selector, 'input', name: 'form[not_my_text_input]')
      end

      it 'supports explicitly defined expression filters' do
        expect(string).to have_selector(:custom_css_selector, placeholder: 'my text')
        expect(string).to have_no_selector(:custom_css_selector, placeholder: 'not my text')
        expect(string).to have_selector(:custom_css_selector, value: 'click me', title: 'submit button')
      end

      it 'uses filter names passed in' do
        selector = Capybara::Selector.new :text do
          css(:name, :other_name) { |_locator| '' }
        end

        expect(selector.expression_filters.keys).to include(:name, :other_name)
      end

      it 'gets filter names from block if none passed to css method' do
        selector = Capybara::Selector.new :test do
          css { |_locator, valid3:, valid4: nil| "#{valid3} #{valid4}" }
        end

        expect(selector.expression_filters.keys).to include(:valid3, :valid4)
      end

      it 'ignores block parameters if names passed in' do
        selector = Capybara::Selector.new :test do
          css(:valid1) { |_locator, valid3:, valid4: nil| "#{valid3} #{valid4}" }
        end

        expect(selector.expression_filters.keys).to include(:valid1)
        expect(selector.expression_filters.keys).not_to include(:valid3, :valid4)
      end
    end

    describe 'builtin selectors' do
      context 'when locator is nil' do
        it 'devolves to just finding element types' do
          selectors = {
            field: ".//*[self::input | self::textarea | self::select][not(./@type = 'submit' or ./@type = 'image' or ./@type = 'hidden')]",
            fieldset: './/fieldset',
            link: './/a[./@href]',
            link_or_button: ".//a[./@href] | .//input[./@type = 'submit' or ./@type = 'reset' or ./@type = 'image' or ./@type = 'button'] | .//button",
            fillable_field: ".//*[self::input | self::textarea][not(./@type = 'submit' or ./@type = 'image' or ./@type = 'radio' or ./@type = 'checkbox' or ./@type = 'hidden' or ./@type = 'file')]",
            radio_button: ".//input[./@type = 'radio']",
            checkbox: ".//input[./@type = 'checkbox']",
            select: './/select',
            option: './/option',
            file_field: ".//input[./@type = 'file']",
            table: './/table'
          }
          selectors.each do |selector, xpath|
            results = string.all(selector, nil).to_a.map(&:native)
            expect(results.size).to be > 0
            expect(results).to eq string.all(:xpath, xpath).to_a.map(&:native)
          end
        end
      end

      context 'with :id option' do
        it 'works with compound css selectors' do
          expect(string.all(:custom_css_selector, 'div, h1', id: 'page').size).to eq 1
          expect(string.all(:custom_css_selector, 'h1, div', id: 'page').size).to eq 1
        end

        it "works with 'special' characters" do
          expect(string.find(:custom_css_selector, 'div', id: '#special')[:id]).to eq '#special'
          expect(string.find(:custom_css_selector, 'input', id: '2checkbox')[:id]).to eq '2checkbox'
        end

        it 'accepts XPath expression for xpath based selectors' do
          expect(string.find(:custom_xpath_selector, './/div', id: XPath.contains('peci'))[:id]).to eq '#special'
          expect(string.find(:custom_xpath_selector, './/input', id: XPath.ends_with('box'))[:id]).to eq '2checkbox'
        end

        it 'errors XPath expression for CSS based selectors' do
          expect { string.find(:custom_css_selector, 'div', id: XPath.contains('peci')) }
            .to raise_error(ArgumentError, /not supported/)
        end

        it 'accepts Regexp for xpath based selectors' do
          expect(string.find(:custom_xpath_selector, './/div', id: /peci/)[:id]).to eq '#special'
          expect(string.find(:custom_xpath_selector, './/div', id: /pEcI/i)[:id]).to eq '#special'
        end

        it 'accepts Regexp for css based selectors' do
          expect(string.find(:custom_css_selector, 'div', id: /sp.*al/)[:id]).to eq '#special'
        end
      end

      context 'with :class option' do
        it 'works with compound css selectors' do
          expect(string.all(:custom_css_selector, 'div, h1', class: 'aa').size).to eq 2
          expect(string.all(:custom_css_selector, 'h1, div', class: 'aa').size).to eq 2
        end

        it 'handles negated classes' do
          expect(string.all(:custom_css_selector, 'div, p', class: ['bb', '!cc']).size).to eq 2
          expect(string.all(:custom_css_selector, 'div, p', class: ['!cc', '!dd', 'bb']).size).to eq 1
          expect(string.all(:custom_xpath_selector, XPath.descendant(:div, :p), class: ['bb', '!cc']).size).to eq 2
          expect(string.all(:custom_xpath_selector, XPath.descendant(:div, :p), class: ['!cc', '!dd', 'bb']).size).to eq 1
        end

        it 'handles classes starting with ! by requiring negated negated first' do
          expect(string.all(:custom_css_selector, 'div, p', class: ['!!!mine']).size).to eq 1
          expect(string.all(:custom_xpath_selector, XPath.descendant(:div, :p), class: ['!!!mine']).size).to eq 1
        end

        it "works with 'special' characters" do
          expect(string.find(:custom_css_selector, 'input', class: '.special')[:id]).to eq 'file'
          expect(string.find(:custom_css_selector, 'input', class: '2checkbox')[:id]).to eq '2checkbox'
        end

        it 'accepts XPath expression for xpath based selectors' do
          expect(string.find(:custom_xpath_selector, './/div', class: XPath.contains('dom wor'))[:id]).to eq 'random_words'
          expect(string.find(:custom_xpath_selector, './/div', class: XPath.ends_with('words'))[:id]).to eq 'random_words'
        end

        it 'errors XPath expression for CSS based selectors' do
          expect { string.find(:custom_css_selector, 'div', class: XPath.contains('random')) }
            .to raise_error(ArgumentError, /not supported/)
        end

        it 'accepts Regexp for XPath based selectors' do
          expect(string.find(:custom_xpath_selector, './/div', class: /dom wor/)[:id]).to eq 'random_words'
          expect(string.find(:custom_xpath_selector, './/div', class: /dOm WoR/i)[:id]).to eq 'random_words'
        end

        it 'accepts Regexp for CSS base selectors' do
          expect(string.find(:custom_css_selector, 'div', class: /random/)[:id]).to eq 'random_words'
        end
      end

      # :css, :xpath, :id, :field, :fieldset, :link, :button, :link_or_button, :fillable_field, :radio_button, :checkbox, :select,
      # :option, :file_field, :label, :table, :frame

      describe ':css selector' do
        it 'finds by CSS locator' do
          expect(string.find(:css, 'input#my_text_input')[:name]).to eq 'form[my_text_input]'
        end
      end

      describe ':xpath selector' do
        it 'finds by XPath locator' do
          expect(string.find(:xpath, './/input[@id="my_text_input"]')[:name]).to eq 'form[my_text_input]'
        end
      end

      describe ':id selector' do
        it 'finds by locator' do
          expect(string.find(:id, 'my_text_input')[:name]).to eq 'form[my_text_input]'
          expect(string.find(:id, /my_text_input/)[:name]).to eq 'form[my_text_input]'
          expect(string.find(:id, /_text_/)[:name]).to eq 'form[my_text_input]'
          expect(string.find(:id, /i[nmo]/)[:name]).to eq 'form[my_text_input]'
        end
      end

      describe ':field selector' do
        it 'finds by locator' do
          expect(string.find(:field, 'My Text Input')[:id]).to eq 'my_text_input'
          expect(string.find(:field, 'my_text_input')[:id]).to eq 'my_text_input'
          expect(string.find(:field, 'form[my_text_input]')[:id]).to eq 'my_text_input'
        end

        it 'finds by id string' do
          expect(string.find(:field, id: 'my_text_input')[:name]).to eq 'form[my_text_input]'
        end

        it 'finds by id regexp' do
          expect(string.find(:field, id: /my_text_inp/)[:name]).to eq 'form[my_text_input]'
        end

        it 'finds by name' do
          expect(string.find(:field, name: 'form[my_text_input]')[:id]).to eq 'my_text_input'
        end

        it 'finds by placeholder' do
          expect(string.find(:field, placeholder: 'my text')[:id]).to eq 'my_text_input'
        end

        it 'finds by type' do
          expect(string.find(:field, type: 'file')[:id]).to eq 'file'
          expect(string.find(:field, type: 'select')[:id]).to eq 'select'
        end
      end

      describe ':option selector' do
        it 'finds disabled options' do
          expect(string.find(:option, disabled: true).value).to eq 'b'
        end

        it 'finds selected options' do
          expect(string.find(:option, selected: true).value).to eq 'c'
        end

        it 'finds not selected and not disabled options' do
          expect(string.find(:option, disabled: false, selected: false).value).to eq 'a'
        end
      end

      describe ':button selector' do
        it 'finds by value' do
          expect(string.find(:button, 'click me').value).to eq 'click me'
        end

        it 'finds by title' do
          expect(string.find(:button, 'submit button').value).to eq 'click me'
        end

        it 'includes non-matching parameters in failure message' do
          expect { string.find(:button, 'click me', title: 'click me') }.to raise_error(/with title click me/)
        end
      end

      describe ':element selector' do
        it 'finds by any attributes' do
          expect(string.find(:element, 'input', type: 'submit').value).to eq 'click me'
        end

        it 'supports regexp matching' do
          expect(string.find(:element, 'input', type: /sub/).value).to eq 'click me'
          expect(string.find(:element, 'input', title: /sub\w.*button/).value).to eq 'click me'
          expect(string.find(:element, 'input', title: /sub.* b.*ton/).value).to eq 'click me'
          expect(string.find(:element, 'input', title: /sub.*mit.*/).value).to eq 'click me'
          expect(string.find(:element, 'input', title: /^submit button$/).value).to eq 'click me'
          expect(string.find(:element, 'input', title: /^(?:submit|other) button$/).value).to eq 'click me'
          expect(string.find(:element, 'input', title: /SuB.*mIt/i).value).to eq 'click me'
          expect(string.find(:element, 'input', title: /^Su.*Bm.*It/i).value).to eq 'click me'
          expect(string.find(:element, 'input', title: /^Ot.*he.*r b.*\d/i).value).to eq "don't click me"
        end

        it 'still works with system keys' do
          expect { string.all(:element, 'input', type: 'submit', count: 1) }.not_to raise_error
        end

        it 'works without element type' do
          expect(string.find(:element, type: 'submit').value).to eq 'click me'
        end

        it 'validates attribute presence when true' do
          expect(string.find(:element, name: true)[:id]).to eq 'my_text_input'
        end

        it 'validates attribute absence when false' do
          expect(string.find(:element, 'option', disabled: false, selected: false).value).to eq 'a'
        end

        it 'includes wildcarded keys in description' do
          expect { string.find(:element, 'input', not_there: 'bad', presence: true, absence: false, count: 1) }
            .to(raise_error do |e|
              expect(e).to be_a(Capybara::ElementNotFound)
              expect(e.message).to include 'not_there => bad'
              expect(e.message).to include 'with presence attribute'
              expect(e.message).to include 'without absence attribute'
              expect(e.message).not_to include 'count 1'
            end)
        end

        it 'accepts XPath::Expression' do
          expect(string.find(:element, 'input', type: XPath.starts_with('subm')).value).to eq 'click me'
          expect(string.find(:element, 'input', type: XPath.ends_with('ext'))[:type]).to eq 'text'
          expect(string.find(:element, 'input', type: XPath.contains('ckb'))[:type]).to eq 'checkbox'
          expect(string.find(:element, 'input', title: XPath.contains_word('submit'))[:type]).to eq 'submit'
          expect(string.find(:element, 'input', title: XPath.contains_word('button 1'))[:type]).to eq 'button'
        end
      end

      describe ':link_or_button selector' do
        around(:all) do |example|
          Capybara.modify_selector(:link_or_button) do
            expression_filter(:random) { |xpath, _| xpath } # do nothing filter
          end
          example.run
          Capybara::Selector.all[:link_or_button].expression_filters.delete(:random)
        end

        context 'when modified' do
          it 'should still work' do
            expect(string.find(:link_or_button, 'click me', random: 'blah').value).to eq 'click me'
          end
        end
      end
    end
  end
end
