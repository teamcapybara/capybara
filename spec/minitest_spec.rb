# frozen_string_literal: true
require 'spec_helper'
require 'capybara/minitest'

class MinitestTest < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def setup
    visit('/form')
  end

  def teardown
    Capybara.reset_sessions!
  end

  def test_assert_text
    assert_text('Form')
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
    assert_no_current_path('/not_form')
    refute_current_path('/not_form')
  end

  def test_assert_xpath
    assert_xpath('.//select[@id="form_title"]')
    assert_xpath('.//select', count: 1) { |el| el[:id] == "form_title" }
    assert_no_xpath('.//select[@id="not_form_title"]')
    assert_no_xpath('.//select') { |el| el[:id] == "not_form_title"}
    refute_xpath('.//select[@id="not_form_title"]')
  end

  def test_assert_css
    assert_css('select#form_title')
    assert_no_css('select#not_form_title')
  end

  def test_assert_link
    visit('/with_html')
    assert_link('A link')
    assert_link(count: 1){ |el| el.text == 'A link'}
    assert_no_link('Not on page')
  end

  def test_assert_button
    assert_button('fresh_btn')
    assert_button(count: 1){ |el| el[:id] == 'fresh_btn' }
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
end

RSpec.describe 'capybara/minitest' do
  before do
    Capybara.current_driver = :rack_test
    Capybara.app = TestApp
  end

  it "should support minitest" do
    output = StringIO.new
    reporter = Minitest::SummaryReporter.new(output)
    reporter.start
    MinitestTest.run reporter, {}
    reporter.report
    expect(output.string).to include("15 runs, 42 assertions, 0 failures, 0 errors, 0 skips")
  end
end
