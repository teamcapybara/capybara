# frozen_string_literal: true

Capybara::SpecHelper.spec '#find' do
  before do
    @session.visit('/with_html')
  end

  after do
    Capybara::Selector.remove(:monkey)
  end

  it "should find the first element using the given locator" do
    expect(@session.find('//h1').text).to eq('This is a test')
    expect(@session.find("//input[@id='test_field']").value).to eq('monkey')
  end

  it "should find the first element using the given locator and options" do
    expect(@session.find('//a', text: 'Redirect')[:id]).to eq('red')
    expect(@session.find(:css, 'a', text: 'A link came first')[:title]).to eq('twas a fine link')
  end

  it "should raise an error if there are multiple matches" do
    expect { @session.find('//a') }.to raise_error(Capybara::Ambiguous)
  end

  it "should wait for asynchronous load", requires: [:js] do
    @session.visit('/with_js')
    @session.click_link('Click me')
    expect(@session.find(:css, "a#has-been-clicked").text).to include('Has been clicked')
  end

  context "with :text option" do
    it "casts text's argument to string" do
      expect(@session.find(:css, '.number', text: 42)).to have_content("42")
    end
  end

  context "with :wait option", requires: [:js] do
    it "should not wait for asynchronous load when `false` given" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      expect do
        @session.find(:css, "a#has-been-clicked", wait: false)
      end.to raise_error(Capybara::ElementNotFound)
    end

    it "should not find element if it appears after given wait duration" do
      @session.visit('/with_js')
      @session.click_link('Slowly')
      expect do
        @session.find(:css, "a#slow-clicked", wait: 0.2)
      end.to raise_error(Capybara::ElementNotFound)
    end

    it "should find element if it appears before given wait duration" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      expect(@session.find(:css, "a#has-been-clicked", wait: 2.0).text).to include('Has been clicked')
    end
  end

  context "with frozen time", requires: [:js] do
    if defined?(Process::CLOCK_MONOTONIC)
      it "will time out even if time is frozen" do
        @session.visit('/with_js')
        now = Time.now
        allow(Time).to receive(:now).and_return(now)
        expect { @session.find('//isnotthere') }.to raise_error(Capybara::ElementNotFound)
      end
    else
      it "raises an error suggesting that Capybara is stuck in time" do
        @session.visit('/with_js')
        now = Time.now
        allow(Time).to receive(:now).and_return(now)
        expect { @session.find('//isnotthere') }.to raise_error(Capybara::FrozenInTime)
      end
    end
  end

  context "with css selectors" do
    it "should find the first element using the given locator" do
      expect(@session.find(:css, 'h1').text).to eq('This is a test')
      expect(@session.find(:css, "input[id='test_field']").value).to eq('monkey')
    end

    it "should support pseudo selectors" do
      expect(@session.find(:css, 'input:disabled').value).to eq('This is disabled')
    end

    it "should support escaping characters" do
      expect(@session.find(:css, '#\31 escape\.me').text).to eq('needs escaping')
      expect(@session.find(:css, '.\32 escape').text).to eq('needs escaping')
    end
  end

  context "with xpath selectors" do
    it "should find the first element using the given locator" do
      expect(@session.find(:xpath, '//h1').text).to eq('This is a test')
      expect(@session.find(:xpath, "//input[@id='test_field']").value).to eq('monkey')
    end
  end

  context "with custom selector" do
    it "should use the custom selector" do
      Capybara.add_selector(:beatle) do
        xpath { |name| ".//*[@id='#{name}']" }
      end
      expect(@session.find(:beatle, 'john').text).to eq('John')
      expect(@session.find(:beatle, 'paul').text).to eq('Paul')
    end
  end

  context "with custom selector with custom `match` block" do
    it "should use the custom selector when locator matches the block" do
      Capybara.add_selector(:beatle) do
        xpath { |num| ".//*[contains(@class, 'beatle')][#{num}]" }
        match { |value| value.is_a?(Integer) }
      end
      expect(@session.find(:beatle, '2').text).to eq('Paul')
      expect(@session.find(1).text).to eq('John')
      expect(@session.find(2).text).to eq('Paul')
      expect(@session.find('//h1').text).to eq('This is a test')
    end
  end

  context "with custom selector with custom filter" do
    before do
      Capybara.add_selector(:beatle) do
        xpath { |name| ".//li[contains(@class, 'beatle')][contains(text(), '#{name}')]" }
        node_filter(:type) { |node, type| node[:class].split(/\s+/).include?(type) }
        node_filter(:fail) { |_node, _val| raise Capybara::ElementNotFound, 'fail' }
      end
    end

    it "should find elements that match the filter" do
      expect(@session.find(:beatle, 'Paul', type: 'drummer').text).to eq('Paul')
      expect(@session.find(:beatle, 'Ringo', type: 'drummer').text).to eq('Ringo')
    end

    it "ignores filter when it is not given" do
      expect(@session.find(:beatle, 'Paul').text).to eq('Paul')
      expect(@session.find(:beatle, 'John').text).to eq('John')
    end

    it "should not find elements that don't match the filter" do
      expect { @session.find(:beatle, 'John', type: 'drummer') }.to raise_error(Capybara::ElementNotFound)
      expect { @session.find(:beatle, 'George', type: 'drummer') }.to raise_error(Capybara::ElementNotFound)
    end

    it "should not raise an ElementNotFound error from in a filter" do
      expect { @session.find(:beatle, 'John', fail: 'something') }.to raise_error(Capybara::ElementNotFound, /beatle "John"/)
    end
  end

  context "with custom selector with custom filter and default" do
    before do
      Capybara.add_selector(:beatle) do
        xpath { |name| ".//li[contains(@class, 'beatle')][contains(text(), '#{name}')]" }
        node_filter(:type, default: "drummer") { |node, type| node[:class].split(/\s+/).include?(type) }
      end
    end

    it "should find elements that match the filter" do
      expect(@session.find(:beatle, 'Paul', type: 'drummer').text).to eq('Paul')
      expect(@session.find(:beatle, 'Ringo', type: 'drummer').text).to eq('Ringo')
    end

    it "should use default value when filter is not given" do
      expect(@session.find(:beatle, 'Paul').text).to eq('Paul')
      expect { @session.find(:beatle, 'John') }.to raise_error(Capybara::ElementNotFound)
    end

    it "should not find elements that don't match the filter" do
      expect { @session.find(:beatle, 'John', type: 'drummer') }.to raise_error(Capybara::ElementNotFound)
      expect { @session.find(:beatle, 'George', type: 'drummer') }.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with alternate filter set" do
    before do
      Capybara::Selector::FilterSet.add(:value) do
        node_filter(:with) { |node, with| node.value == with.to_s }
      end

      Capybara.add_selector(:id_with_field_filters) do
        xpath { |id| XPath.descendant[XPath.attr(:id) == id.to_s] }
        filter_set(:field)
      end
    end

    it "should allow use of filters from custom filter set" do
      expect(@session.find(:id, 'test_field', filter_set: :value, with: 'monkey').value).to eq('monkey')
      expect { @session.find(:id, 'test_field', filter_set: :value, with: 'not_monkey') }.to raise_error(Capybara::ElementNotFound)
    end

    it "should allow use of filter set from a different selector" do
      expect(@session.find(:id, 'test_field', filter_set: :field, with: 'monkey').value).to eq('monkey')
      expect { @session.find(:id, 'test_field', filter_set: :field, with: 'not_monkey') }.to raise_error(Capybara::ElementNotFound)
    end

    it "should allow importing of filter set into selector" do
      expect(@session.find(:id_with_field_filters, 'test_field', with: 'monkey').value).to eq('monkey')
      expect { @session.find(:id_with_field_filters, 'test_field', with: 'not_monkey') }.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with css as default selector" do
    before { Capybara.default_selector = :css }

    it "should find the first element using the given locator" do
      expect(@session.find('h1').text).to eq('This is a test')
      expect(@session.find("input[id='test_field']").value).to eq('monkey')
    end
    after { Capybara.default_selector = :xpath }
  end

  it "should raise ElementNotFound with a useful default message if nothing was found" do
    expect do
      @session.find(:xpath, '//div[@id="nosuchthing"]').to be_nil
    end.to raise_error(Capybara::ElementNotFound, "Unable to find visible xpath \"//div[@id=\\\"nosuchthing\\\"]\"")
  end

  it "should accept an XPath instance" do
    @session.visit('/form')
    @xpath = Capybara::Selector.all[:fillable_field].call('First Name')
    expect(@xpath).to be_a(::XPath::Union)
    expect(@session.find(@xpath).value).to eq('John')
  end

  context "with :exact option" do
    it "matches exactly when true" do
      expect(@session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("test_field")], exact: true).value).to eq("monkey")
      expect do
        @session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("est_fiel")], exact: true)
      end.to raise_error(Capybara::ElementNotFound)
    end

    it "matches loosely when false" do
      expect(@session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("test_field")], exact: false).value).to eq("monkey")
      expect(@session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("est_fiel")], exact: false).value).to eq("monkey")
    end

    it "defaults to `Capybara.exact`" do
      Capybara.exact = true
      expect do
        @session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("est_fiel")])
      end.to raise_error(Capybara::ElementNotFound)
      Capybara.exact = false
      @session.find(:xpath, XPath.descendant(:input)[XPath.attr(:id).is("est_fiel")])
    end

    it "warns when the option has no effect" do
      expect_any_instance_of(Kernel).to receive(:warn)
        .with('The :exact option only has an effect on queries using the XPath#is method. Using it with the query "#test_field" has no effect.')
      @session.find(:css, '#test_field', exact: true)
    end
  end

  context "with :match option" do
    context "when set to `one`" do
      it "raises an error when multiple matches exist" do
        expect do
          @session.find(:css, ".multiple", match: :one)
        end.to raise_error(Capybara::Ambiguous)
      end
      it "raises an error even if there the match is exact and the others are inexact" do
        expect do
          @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular")], exact: false, match: :one)
        end.to raise_error(Capybara::Ambiguous)
      end
      it "returns the element if there is only one" do
        expect(@session.find(:css, ".singular", match: :one).text).to eq("singular")
      end
      it "raises an error if there is no match" do
        expect do
          @session.find(:css, ".does-not-exist", match: :one)
        end.to raise_error(Capybara::ElementNotFound)
      end
    end

    context "when set to `first`" do
      it "returns the first matched element" do
        expect(@session.find(:css, ".multiple", match: :first).text).to eq("multiple one")
      end
      it "raises an error if there is no match" do
        expect do
          @session.find(:css, ".does-not-exist", match: :first)
        end.to raise_error(Capybara::ElementNotFound)
      end
    end

    context "when set to `smart`" do
      context "and `exact` set to `false`" do
        it "raises an error when there are multiple exact matches" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("multiple")], match: :smart, exact: false)
          end.to raise_error(Capybara::Ambiguous)
        end
        it "finds a single exact match when there also are inexact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular")], match: :smart, exact: false)
          expect(result.text).to eq("almost singular")
        end
        it "raises an error when there are multiple inexact matches" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singul")], match: :smart, exact: false)
          end.to raise_error(Capybara::Ambiguous)
        end
        it "finds a single inexact match" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular but")], match: :smart, exact: false)
          expect(result.text).to eq("almost singular but not quite")
        end
        it "raises an error if there is no match" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("does-not-exist")], match: :smart, exact: false)
          end.to raise_error(Capybara::ElementNotFound)
        end
      end

      context "with `exact` set to `true`" do
        it "raises an error when there are multiple exact matches" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("multiple")], match: :smart, exact: true)
          end.to raise_error(Capybara::Ambiguous)
        end
        it "finds a single exact match when there also are inexact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular")], match: :smart, exact: true)
          expect(result.text).to eq("almost singular")
        end
        it "raises an error when there are multiple inexact matches" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singul")], match: :smart, exact: true)
          end.to raise_error(Capybara::ElementNotFound)
        end
        it "raises an error when there is a single inexact matches" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular but")], match: :smart, exact: true)
          end.to raise_error(Capybara::ElementNotFound)
        end
        it "raises an error if there is no match" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("does-not-exist")], match: :smart, exact: true)
          end.to raise_error(Capybara::ElementNotFound)
        end
      end
    end

    context "when set to `prefer_exact`" do
      context "and `exact` set to `false`" do
        it "picks the first one when there are multiple exact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("multiple")], match: :prefer_exact, exact: false)
          expect(result.text).to eq("multiple one")
        end
        it "finds a single exact match when there also are inexact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular")], match: :prefer_exact, exact: false)
          expect(result.text).to eq("almost singular")
        end
        it "picks the first one when there are multiple inexact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singul")], match: :prefer_exact, exact: false)
          expect(result.text).to eq("almost singular but not quite")
        end
        it "finds a single inexact match" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular but")], match: :prefer_exact, exact: false)
          expect(result.text).to eq("almost singular but not quite")
        end
        it "raises an error if there is no match" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("does-not-exist")], match: :prefer_exact, exact: false)
          end.to raise_error(Capybara::ElementNotFound)
        end
      end

      context "with `exact` set to `true`" do
        it "picks the first one when there are multiple exact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("multiple")], match: :prefer_exact, exact: true)
          expect(result.text).to eq("multiple one")
        end
        it "finds a single exact match when there also are inexact matches" do
          result = @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular")], match: :prefer_exact, exact: true)
          expect(result.text).to eq("almost singular")
        end
        it "raises an error if there are multiple inexact matches" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singul")], match: :prefer_exact, exact: true)
          end.to raise_error(Capybara::ElementNotFound)
        end
        it "raises an error if there is a single inexact match" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("almost_singular but")], match: :prefer_exact, exact: true)
          end.to raise_error(Capybara::ElementNotFound)
        end
        it "raises an error if there is no match" do
          expect do
            @session.find(:xpath, XPath.descendant[XPath.attr(:class).is("does-not-exist")], match: :prefer_exact, exact: true)
          end.to raise_error(Capybara::ElementNotFound)
        end
      end
    end

    it "defaults to `Capybara.match`" do
      Capybara.match = :one
      expect do
        @session.find(:css, ".multiple")
      end.to raise_error(Capybara::Ambiguous)
      Capybara.match = :first
      expect(@session.find(:css, ".multiple").text).to eq("multiple one")
    end

    it "raises an error when unknown option given" do
      expect do
        @session.find(:css, ".singular", match: :schmoo)
      end.to raise_error(ArgumentError)
    end
  end

  it "supports a custom filter block" do
    expect(@session.find(:css, 'input', &:disabled?)[:name]).to eq('disabled_text')
  end

  context "within a scope" do
    before do
      @session.visit('/with_scope')
    end

    it "should find the an element using the given locator" do
      @session.within(:xpath, "//div[@id='for_bar']") do
        expect(@session.find('.//li[1]').text).to match(/With Simple HTML/)
      end
    end

    it "should support pseudo selectors" do
      @session.within(:xpath, "//div[@id='for_bar']") do
        expect(@session.find(:css, 'input:disabled').value).to eq('James')
      end
    end
  end

  it "should raise if selector type is unknown" do
    expect do
      @session.find(:unknown, '//h1')
    end.to raise_error(ArgumentError)
  end
end
