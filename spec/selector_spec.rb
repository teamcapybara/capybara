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

    describe "modfiy_selector" do
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
  end
end
