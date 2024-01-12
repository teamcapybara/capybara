# frozen_string_literal: true

require 'spec_helper'
require 'capybara/minitest'

class MinitestDSLTest < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def setup
    visit('/form')
  end

  def teardown
    Capybara.reset_sessions!
  end

  def self.test_order
    :sorted
  end

  def test_assert_text
    assert_text('Form', normalize_ws: false)
    assert_no_text('Not on the page')
    refute_text('Also Not on the page')
  end

  def test_assert_title
    visit('/with_title')
    assert_title('Test Title')
    assert_no_title('Not the title')
    refute_title('Not the title')
  end

  def test_assert_current_path
    assert_current_path('/form')
    assert_current_path('/form') { |url| url.query.nil? }
    assert_no_current_path('/not_form')
    refute_current_path('/not_form')
  end

  def test_assert_xpath
    assert_xpath('.//select[@id="form_title"]')
    assert_xpath('.//select', count: 1) { |el| el[:id] == 'form_title' }
    assert_no_xpath('.//select[@id="not_form_title"]')
    assert_no_xpath('.//select') { |el| el[:id] == 'not_form_title' }
    refute_xpath('.//select[@id="not_form_title"]')
  end

  def test_assert_css
    assert_css('select#form_title')
    assert_no_css('select#not_form_title')
  end

  def test_assert_selector
    assert_selector(:css, 'select#form_title')
    assert_selector(:xpath, './/select[@id="form_title"]')
    assert_no_selector(:css, 'select#not_form_title')
    assert_no_selector(:xpath, './/select[@id="not_form_title"]')
    refute_selector(:css, 'select#not_form_title')
  end

  def test_assert_element
    visit('/with_html')
    assert_element('a', text: 'A link')
    assert_element(count: 1) { |el| el.text == 'A link' }
    assert_no_element(text: 'Not on page')
  end

  def test_assert_link
    visit('/with_html')
    assert_link('A link')
    assert_link(count: 1) { |el| el.text == 'A link' }
    assert_no_link('Not on page')
  end

  def test_assert_button
    assert_button('fresh_btn')
    assert_button(count: 1) { |el| el[:id] == 'fresh_btn' }
    assert_no_button('not_btn')
  end

  def test_assert_field
    assert_field('customer_email')
    assert_no_field('not_on_the_form')
  end

  def test_assert_select
    assert_select('form_title')
    assert_no_select('not_form_title')
  end

  def test_assert_checked_field
    assert_checked_field('form_pets_dog')
    assert_no_checked_field('form_pets_cat')
    refute_checked_field('form_pets_snake')
  end

  def test_assert_unchecked_field
    assert_unchecked_field('form_pets_cat')
    assert_no_unchecked_field('form_pets_dog')
    refute_unchecked_field('form_pets_snake')
  end

  def test_assert_table
    visit('/tables')
    assert_table('agent_table')
    assert_no_table('not_on_form')
    refute_table('not_on_form')
  end

  def test_assert_all_of_selectors
    assert_all_of_selectors(:css, 'select#form_other_title', 'input#form_last_name')
  end

  def test_assert_none_of_selectors
    assert_none_of_selectors(:css, 'input#not_on_page', 'input#also_not_on_page')
  end

  def test_assert_any_of_selectors
    assert_any_of_selectors(:css, 'input#not_on_page', 'select#form_other_title')
  end

  def test_assert_matches_selector
    assert_matches_selector(find(:field, 'customer_email'), :field, 'customer_email')
    assert_not_matches_selector(find(:select, 'form_title'), :field, 'customer_email')
    refute_matches_selector(find(:select, 'form_title'), :field, 'customer_email')
  end

  def test_assert_matches_css
    assert_matches_css(find(:select, 'form_title'), 'select#form_title')
    refute_matches_css(find(:select, 'form_title'), 'select#form_other_title')
  end

  def test_assert_matches_xpath
    assert_matches_xpath(find(:select, 'form_title'), './/select[@id="form_title"]')
    refute_matches_xpath(find(:select, 'form_title'), './/select[@id="form_other_title"]')
  end

  def test_assert_matches_style
    skip "Rack test doesn't support style" if Capybara.current_driver == :rack_test
    visit('/with_html')
    assert_matches_style(find(:css, '#second'), display: 'inline')
  end

  def test_assert_ancestor
    option = find(:option, 'Finnish')
    assert_ancestor(option, :css, '#form_locale')
  end

  def test_assert_sibling
    option = find(:css, '#form_title').find(:option, 'Mrs')
    assert_sibling(option, :option, 'Mr')
  end
end

class MinitestAssertionsTest < Minitest::Test
  include Capybara::Minitest::Assertions

  attr_reader :page

  def self.test_order
    :sorted
  end

  def render(html)
    @page = Capybara.string(html)
  end

  def test_assert_text
    render <<~HTML
      Form
    HTML

    assert_text('Form', normalize_ws: false)
    assert_no_text('Not on the page')
    refute_text('Also Not on the page')
  end

  def test_assert_title
    render <<~HTML
      <html>
        <head><title>Test Title</title></head>
      </html>
    HTML

    assert_title('Test Title')
    assert_no_title('Not the title')
    refute_title('Not the title')
  end

  def test_assert_xpath
    render <<~HTML
      <select id="form_title"></select>
    HTML

    assert_xpath('.//select[@id="form_title"]')
    assert_xpath('.//select', count: 1) { |el| el[:id] == 'form_title' }
    assert_no_xpath('.//select[@id="not_form_title"]')
    assert_no_xpath('.//select') { |el| el[:id] == 'not_form_title' }
    refute_xpath('.//select[@id="not_form_title"]')
  end

  def test_assert_css
    render <<~HTML
      <select id="form_title"></select>
    HTML

    assert_css('select#form_title')
    assert_no_css('select#not_form_title')
  end

  def test_assert_selector
    render <<~HTML
      <select id="form_title"></select>
    HTML

    assert_selector(:css, 'select#form_title')
    assert_selector(:xpath, './/select[@id="form_title"]')
    assert_no_selector(:css, 'select#not_form_title')
    assert_no_selector(:xpath, './/select[@id="not_form_title"]')
    refute_selector(:css, 'select#not_form_title')
  end

  def test_assert_element
    render <<~HTML
      <a href="with_html">A link</a>
    HTML

    assert_element('a', text: 'A link')
    assert_element(count: 1) { |el| el.text == 'A link' }
    assert_no_element(text: 'Not on page')
  end

  def test_assert_link
    render <<~HTML
      <a href="with_html">A link</a>
    HTML

    assert_link('A link')
    assert_link(count: 1) { |el| el.text == 'A link' }
    assert_no_link('Not on page')
  end

  def test_assert_button
    render <<~HTML
      <input type="button" id="fresh_btn">
    HTML

    assert_button('fresh_btn')
    assert_button(count: 1) { |el| el[:id] == 'fresh_btn' }
    assert_no_button('not_btn')
  end

  def test_assert_field
    render <<~HTML
      <input id="customer_email">
    HTML

    assert_field('customer_email')
    assert_no_field('not_on_the_form')
  end

  def test_assert_select
    render <<~HTML
      <select id="form_title"></select>
    HTML

    assert_select('form_title')
    assert_no_select('not_form_title')
  end

  def test_assert_checked_field
    render <<~HTML
      <input type="checkbox" id="form_pets_dog" checked="checked">
      <input type="checkbox" id="form_pets_cat">
    HTML

    assert_checked_field('form_pets_dog')
    assert_no_checked_field('form_pets_cat')
    refute_checked_field('form_pets_snake')
  end

  def test_assert_unchecked_field
    render <<~HTML
      <input type="checkbox" id="form_pets_dog" checked="checked">
      <input type="checkbox" id="form_pets_cat">
    HTML

    assert_unchecked_field('form_pets_cat')
    assert_no_unchecked_field('form_pets_dog')
    refute_unchecked_field('form_pets_snake')
  end

  def test_assert_table
    render <<~HTML
      <table id="agent_table"></table>
    HTML

    assert_table('agent_table')
    assert_no_table('not_on_form')
    refute_table('not_on_form')
  end

  def test_assert_all_of_selectors
    render <<~HTML
      <select id="form_other_title"></select>
      <input id="form_last_name">
    HTML

    assert_all_of_selectors(:css, 'select#form_other_title', 'input#form_last_name')
  end

  def test_assert_none_of_selectors
    render('')

    assert_none_of_selectors(:css, 'input#not_on_page', 'input#also_not_on_page')
  end

  def test_assert_any_of_selectors
    render <<~HTML
      <select id="form_other_title"></select>
    HTML

    assert_any_of_selectors(:css, 'input#not_on_page', 'select#form_other_title')
  end

  def test_assert_matches_selector
    render <<~HTML
      <select id="form_title"></select>
      <input id="customer_email">
    HTML

    assert_matches_selector(page.find(:field, 'customer_email'), :field, 'customer_email')
    assert_not_matches_selector(page.find(:select, 'form_title'), :field, 'customer_email')
    refute_matches_selector(page.find(:select, 'form_title'), :field, 'customer_email')
  end

  def test_assert_matches_css
    render <<~HTML
      <select id="form_title"></select>
      <select id="form_other_title"></select>
    HTML

    assert_matches_css(page.find(:select, 'form_title'), 'select#form_title')
    refute_matches_css(page.find(:select, 'form_title'), 'select#form_other_title')
  end

  def test_assert_matches_xpath
    render <<~HTML
      <select id="form_title"></select>
      <select id="form_other_title"></select>
    HTML

    assert_matches_xpath(page.find(:select, 'form_title'), './/select[@id="form_title"]')
    refute_matches_xpath(page.find(:select, 'form_title'), './/select[@id="form_other_title"]')
  end

  def test_assert_ancestor
    render <<~HTML
      <select id="form_locale">
        <option>Finnish</option>
      </select>
    HTML

    option = page.find(:option, 'Finnish')
    assert_ancestor(option, :css, '#form_locale')
  end

  def test_assert_sibling
    render <<~HTML
      <select id="form_title">
        <option class="title">Mrs</option>
        <option class="title">Mr</option>
      </select>
    HTML

    option = page.find(:css, '#form_title').find(:option, 'Mrs')
    assert_sibling(option, :option, 'Mr')
  end

  def test_within
    render <<~HTML
      <div id="outside">Outside</div>
      <div id="parent">
        Inside
        <div id="child">Child</div>
        <div id="sibling">Sibling</div>
      </div>
    HTML

    within :element, id: 'parent' do
      assert_text 'Inside'
      assert_text 'Child'
      assert_text 'Sibling'
      assert_no_text 'Outside'

      within :element, id: 'child' do
        assert_text 'Child'
        assert_no_text 'Inside'
        assert_no_text 'Outside'
        assert_no_text 'Sibling'
      end

      assert_raises Capybara::ElementNotFound do
        within :element, id: 'outside'
      end
    end
  end
end

RSpec.describe 'capybara/minitest' do
  before do
    Capybara.current_driver = :rack_test
    Capybara.app = TestApp
  end

  after do
    Capybara.use_default_driver
  end

  it 'should support minitest with DSL' do
    output = StringIO.new
    reporter = Minitest::SummaryReporter.new(output)
    reporter.start
    MinitestDSLTest.run reporter, {}
    reporter.report
    expect(output.string).to include('23 runs, 56 assertions, 0 failures, 0 errors, 1 skips')
  end

  it 'should support minitest with assertions' do
    output = StringIO.new
    reporter = Minitest::SummaryReporter.new(output)
    reporter.start
    MinitestAssertionsTest.run reporter, {}
    reporter.report
    expect(output.string).to include('22 runs, 61 assertions, 0 failures, 0 errors, 0 skips')
  end
end
