# frozen_string_literal: true

require 'spec_helper'
nokogumbo_required = begin
                       require 'nokogumbo'
                       true
                     rescue LoadError
                       false
                     end

module TestSessions
  RackTest = Capybara::Session.new(:rack_test, TestApp)
end

skipped_tests = %i[
  js
  modals
  screenshot
  frames
  windows
  send_keys
  server
  hover
  about_scheme
  download
  css
  scroll
]
Capybara::SpecHelper.run_specs TestSessions::RackTest, 'RackTest', capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when /has_css\? should support case insensitive :class and :id options/
    skip "Nokogiri doesn't support case insensitive CSS attribute matchers"
  when /#click_button should follow permanent redirects that maintain method/
    skip "Rack < 2 doesn't support 308" if Gem.loaded_specs['rack'].version < Gem::Version.new('2.0.0')
  end
end

RSpec.describe Capybara::Session do # rubocop:disable RSpec/MultipleDescribes
  context 'with rack test driver' do
    before do
      @session = TestSessions::RackTest
    end

    describe '#driver' do
      it 'should be a rack test driver' do
        expect(@session.driver).to be_an_instance_of(Capybara::RackTest::Driver)
      end
    end

    describe '#mode' do
      it 'should remember the mode' do
        expect(@session.mode).to eq(:rack_test)
      end
    end

    describe '#click_link' do
      after do
        @session.driver.options[:respect_data_method] = false
      end

      it 'should use data-method if option is true' do
        @session.driver.options[:respect_data_method] = true
        @session.visit '/with_html'
        @session.click_link 'A link with data-method'
        expect(@session.html).to include('The requested object was deleted')
      end

      it 'should not use data-method if option is false' do
        @session.driver.options[:respect_data_method] = false
        @session.visit '/with_html'
        @session.click_link 'A link with data-method'
        expect(@session.html).to include('Not deleted')
      end

      it "should use data-method if available even if it's capitalized" do
        @session.driver.options[:respect_data_method] = true
        @session.visit '/with_html'
        @session.click_link 'A link with capitalized data-method'
        expect(@session.html).to include('The requested object was deleted')
      end
    end

    describe '#fill_in' do
      it 'should warn that :fill_options are not supported' do
        allow_any_instance_of(Capybara::RackTest::Node).to receive(:warn)
        @session.visit '/with_html'
        field = @session.fill_in 'test_field', with: 'not_monkey', fill_options: { random: true }
        expect(@session).to have_field('test_field', with: 'not_monkey')
        expect(field.base).to have_received(:warn).with("Options passed to Node#set but the RackTest driver doesn't support any - ignoring")
      end
    end

    describe '#attach_file' do
      context 'with multipart form' do
        it 'should submit an empty form-data section if no file is submitted' do
          @session.visit('/form')
          @session.click_button('Upload Empty')
          expect(@session.html).to include('Successfully ignored empty file field.')
        end
      end

      it 'should not submit an obsolete mime type' do
        @test_jpg_file_path = File.expand_path('fixtures/capybara.csv', File.dirname(__FILE__))
        @session.visit('/form')
        @session.attach_file 'form_document', @test_jpg_file_path
        @session.click_button('Upload Single')
        expect(@session).to have_content('Content-type: text/csv')
      end
    end

    describe '#click' do
      context 'on a label' do
        it 'should toggle the associated checkbox' do
          @session.visit('/form')
          expect(@session).to have_unchecked_field('form_pets_cat')
          @session.find(:label, 'Cat').click
          expect(@session).to have_checked_field('form_pets_cat')
          @session.find(:label, 'Cat').click
          expect(@session).to have_unchecked_field('form_pets_cat')
          @session.find(:label, 'McLaren').click
          expect(@session).to have_checked_field('form_cars_mclaren', visible: :hidden)
        end

        it 'should toggle the associated radio' do
          @session.visit('/form')
          expect(@session).to have_unchecked_field('gender_male')
          @session.find(:label, 'Male').click
          expect(@session).to have_checked_field('gender_male')
          @session.find(:label, 'Female').click
          expect(@session).to have_unchecked_field('gender_male')
        end
      end
    end

    describe '#text' do
      it 'should return original text content for textareas' do
        @session.visit('/with_html')
        @session.find_field('normal', type: 'textarea', with: 'banana').set('hello')
        normal = @session.find(:css, '#normal')
        expect(normal.value).to eq 'hello'
        expect(normal.text).to eq 'banana'
      end
    end

    describe '#style' do
      it 'should raise an error' do
        @session.visit('/with_html')
        el = @session.find(:css, '#first')
        expect { el.style('display') }.to raise_error NotImplementedError, /not process CSS/
      end
    end
  end
end

RSpec.describe Capybara::RackTest::Driver do
  before do
    @driver = TestSessions::RackTest.driver
  end

  describe ':headers option' do
    it 'should always set headers' do
      @driver = Capybara::RackTest::Driver.new(TestApp, headers: { 'HTTP_FOO' => 'foobar' })
      @driver.visit('/get_header')
      expect(@driver.html).to include('foobar')
    end

    it 'should keep headers on link clicks' do
      @driver = Capybara::RackTest::Driver.new(TestApp, headers: { 'HTTP_FOO' => 'foobar' })
      @driver.visit('/header_links')
      @driver.find_xpath('.//a').first.click
      expect(@driver.html).to include('foobar')
    end

    it 'should keep headers on form submit' do
      @driver = Capybara::RackTest::Driver.new(TestApp, headers: { 'HTTP_FOO' => 'foobar' })
      @driver.visit('/header_links')
      @driver.find_xpath('.//input').first.click
      expect(@driver.html).to include('foobar')
    end

    it 'should keep headers on redirects' do
      @driver = Capybara::RackTest::Driver.new(TestApp, headers: { 'HTTP_FOO' => 'foobar' })
      @driver.visit('/get_header_via_redirect')
      expect(@driver.html).to include('foobar')
    end
  end

  describe ':follow_redirects option' do
    it 'defaults to following redirects' do
      @driver = Capybara::RackTest::Driver.new(TestApp)

      @driver.visit('/redirect')
      expect(@driver.response.header['Location']).to be_nil
      expect(@driver.current_url).to match %r{/landed$}
    end

    it 'is possible to not follow redirects' do
      @driver = Capybara::RackTest::Driver.new(TestApp, follow_redirects: false)

      @driver.visit('/redirect')
      expect(@driver.response.header['Location']).to match %r{/redirect_again$}
      expect(@driver.current_url).to match %r{/redirect$}
    end
  end

  describe ':redirect_limit option' do
    context 'with default redirect limit' do
      before do
        @driver = Capybara::RackTest::Driver.new(TestApp)
      end

      it 'should follow 5 redirects' do
        @driver.visit('/redirect/5/times')
        expect(@driver.html).to include('redirection complete')
      end

      it 'should not follow more than 6 redirects' do
        expect do
          @driver.visit('/redirect/6/times')
        end.to raise_error(Capybara::InfiniteRedirectError)
      end
    end

    context 'with 21 redirect limit' do
      before do
        @driver = Capybara::RackTest::Driver.new(TestApp, redirect_limit: 21)
      end

      it 'should follow 21 redirects' do
        @driver.visit('/redirect/21/times')
        expect(@driver.html).to include('redirection complete')
      end

      it 'should not follow more than 21 redirects' do
        expect do
          @driver.visit('/redirect/22/times')
        end.to raise_error(Capybara::InfiniteRedirectError)
      end
    end
  end
end

RSpec.describe 'Capybara::String' do
  it 'should use gumbo' do
    skip 'Only  valid if gumbo is included' unless nokogumbo_required
    allow(Nokogiri).to receive(:HTML5).and_call_original
    Capybara.string('<div id=test_div></div>')
    expect(Nokogiri).to have_received(:HTML5)
  end
end

module CSSHandlerIncludeTester
  def dont_extend_css_handler
    raise 'should never be called'
  end
end

RSpec.describe Capybara::RackTest::CSSHandlers do
  include CSSHandlerIncludeTester

  it 'should not be extended by global includes' do
    expect(Capybara::RackTest::CSSHandlers.new).not_to respond_to(:dont_extend_css_handler)
  end
end
