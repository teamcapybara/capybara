# frozen_string_literal: true
require 'spec_helper'
require 'capybara/dsl'

class TestClass
  include Capybara::DSL
end

Capybara::SpecHelper.run_specs TestClass.new, "DSL", capybara_skip: [
  :js,
  :modals,
  :screenshot,
  :frames,
  :windows,
  :send_keys,
  :server,
  :hover,
  :about_scheme,
]

RSpec.describe Capybara::DSL do
  after do
    Capybara.session_name = nil
    Capybara.default_driver = nil
    Capybara.javascript_driver = nil
    Capybara.use_default_driver
    Capybara.app = TestApp
  end

  describe '#default_driver' do
    it "should default to rack_test" do
      expect(Capybara.default_driver).to eq(:rack_test)
    end

    it "should be changeable" do
      Capybara.default_driver = :culerity
      expect(Capybara.default_driver).to eq(:culerity)
    end
  end

  describe '#current_driver' do
    it "should default to the default driver" do
      expect(Capybara.current_driver).to eq(:rack_test)
      Capybara.default_driver = :culerity
      expect(Capybara.current_driver).to eq(:culerity)
    end

    it "should be changeable" do
      Capybara.current_driver = :culerity
      expect(Capybara.current_driver).to eq(:culerity)
    end
  end

  describe '#javascript_driver' do
    it "should default to selenium" do
      expect(Capybara.javascript_driver).to eq(:selenium)
    end

    it "should be changeable" do
      Capybara.javascript_driver = :culerity
      expect(Capybara.javascript_driver).to eq(:culerity)
    end
  end

  describe '#use_default_driver' do
    it "should restore the default driver" do
      Capybara.current_driver = :culerity
      Capybara.use_default_driver
      expect(Capybara.current_driver).to eq(:rack_test)
    end
  end

  describe '#using_driver' do
    before do
      expect(Capybara.current_driver).not_to eq(:selenium)
    end

    it 'should set the driver using Capybara.current_driver=' do
      driver = nil
      Capybara.using_driver(:selenium) { driver = Capybara.current_driver }
      expect(driver).to eq(:selenium)
    end

    it 'should return the driver to default if it has not been changed' do
      Capybara.using_driver(:selenium) do
        expect(Capybara.current_driver).to eq(:selenium)
      end
      expect(Capybara.current_driver).to eq(Capybara.default_driver)
    end

    it 'should reset the driver even if an exception occurs' do
      driver_before_block = Capybara.current_driver
      begin
        Capybara.using_driver(:selenium) { raise "ohnoes!" }
      rescue Exception
      end
      expect(Capybara.current_driver).to eq(driver_before_block)
    end

    it 'should return the driver to what it was previously' do
      Capybara.current_driver = :selenium
      Capybara.using_driver(:culerity) do
        Capybara.using_driver(:rack_test) do
          expect(Capybara.current_driver).to eq(:rack_test)
        end
        expect(Capybara.current_driver).to eq(:culerity)
      end
      expect(Capybara.current_driver).to eq(:selenium)
    end

    it 'should yield the passed block' do
      called = false
      Capybara.using_driver(:selenium) { called = true }
      expect(called).to eq(true)
    end
  end

  describe '#using_wait_time' do
    before do
      @previous_wait_time = Capybara.default_max_wait_time
    end

    after do
      Capybara.default_max_wait_time = @previous_wait_time
    end

    it "should switch the wait time and switch it back" do
      in_block = nil
      Capybara.using_wait_time 6 do
        in_block = Capybara.default_max_wait_time
      end
      expect(in_block).to eq(6)
      expect(Capybara.default_max_wait_time).to eq(@previous_wait_time)
    end

    it "should ensure wait time is reset" do
      expect do
        Capybara.using_wait_time 6 do
          raise "hell"
        end
      end.to raise_error(RuntimeError, "hell")
      expect(Capybara.default_max_wait_time).to eq(@previous_wait_time)
    end
  end

  describe '#app' do
    it "should be changeable" do
      Capybara.app = "foobar"
      expect(Capybara.app).to eq('foobar')
    end
  end

  describe '#current_session' do
    it "should choose a session object of the current driver type" do
      expect(Capybara.current_session).to be_a(Capybara::Session)
    end

    it "should use #app as the application" do
      Capybara.app = proc {}
      expect(Capybara.current_session.app).to eq(Capybara.app)
    end

    it "should change with the current driver" do
      expect(Capybara.current_session.mode).to eq(:rack_test)
      Capybara.current_driver = :selenium
      expect(Capybara.current_session.mode).to eq(:selenium)
    end

    it "should be persistent even across driver changes" do
      object_id = Capybara.current_session.object_id
      expect(Capybara.current_session.object_id).to eq(object_id)
      Capybara.current_driver = :selenium
      expect(Capybara.current_session.mode).to eq(:selenium)
      expect(Capybara.current_session.object_id).not_to eq(object_id)

      Capybara.current_driver = :rack_test
      expect(Capybara.current_session.object_id).to eq(object_id)
    end

    it "should change when changing application" do
      object_id = Capybara.current_session.object_id
      expect(Capybara.current_session.object_id).to eq(object_id)
      Capybara.app = proc {}
      expect(Capybara.current_session.object_id).not_to eq(object_id)
      expect(Capybara.current_session.app).to eq(Capybara.app)
    end

    it "should change when the session name changes" do
      object_id = Capybara.current_session.object_id
      Capybara.session_name = :administrator
      expect(Capybara.session_name).to eq(:administrator)
      expect(Capybara.current_session.object_id).not_to eq(object_id)
      Capybara.session_name = :default
      expect(Capybara.session_name).to eq(:default)
      expect(Capybara.current_session.object_id).to eq(object_id)
    end
  end

  describe "#using_session" do
    it "should change the session name for the duration of the block" do
      expect(Capybara.session_name).to eq(:default)
      Capybara.using_session(:administrator) do
        expect(Capybara.session_name).to eq(:administrator)
      end
      expect(Capybara.session_name).to eq(:default)
    end

    it "should reset the session to the default, even if an exception occurs" do
      begin
        Capybara.using_session(:raise) do
          raise
        end
      rescue Exception
      end
      expect(Capybara.session_name).to eq(:default)
    end

    it "should yield the passed block" do
      called = false
      Capybara.using_session(:administrator) { called = true }
      expect(called).to eq(true)
    end

    it "should be nestable" do
      Capybara.using_session(:outer) do
        expect(Capybara.session_name).to eq(:outer)
        Capybara.using_session(:inner) do
          expect(Capybara.session_name).to eq(:inner)
        end
        expect(Capybara.session_name).to eq(:outer)
      end
      expect(Capybara.session_name).to eq(:default)
    end
  end

  describe "#session_name" do
    it "should default to :default" do
      expect(Capybara.session_name).to eq(:default)
    end
  end

  describe 'the DSL'   do
    before do
      @session = Class.new { include Capybara::DSL }.new
    end

    module Shadower
      def all; end
      def within; end
    end

    it "should be possible to include it in another class" do
      @session.visit('/with_html')
      @session.click_link('ullamco')
      expect(@session.body).to include('Another World')
    end

    it "should provide a 'page' shortcut for more expressive tests" do
      @session.page.visit('/with_html')
      @session.page.click_link('ullamco')
      expect(@session.page.body).to include('Another World')
    end

    it "should provide an 'using_session' shortcut" do
      expect(Capybara).to receive(:using_session).with(:name)
      @session.using_session(:name)
    end

    it "should provide a 'using_wait_time' shortcut" do
      expect(Capybara).to receive(:using_wait_time).with(6)
      @session.using_wait_time(6)
    end

    it "should warn if another module shadows its methods" do
      expect_any_instance_of(Kernel).to receive(:warn).with(/Capybara::DSL methods \[:all, :within\] are shadowed by Shadower/)
      @session.class.class_eval do
        include Shadower
      end
    end

    it "should not warn if all methods marked as expected to be shadowed" do
      Capybara.expected_shadowed_dsl_methods = [:within, :all]
      expect_any_instance_of(Kernel).not_to receive(:warn)
      @session.class.class_eval do
        include Shadower
      end
    end

    it "should not warn about methods marked as expected" do
      Capybara.expected_shadowed_dsl_methods = [:within]
      expect_any_instance_of(Kernel).to receive(:warn).with(/Capybara::DSL methods \[:all\] are shadowed by Shadower/)
      @session.class.class_eval do
        include Shadower
      end
    end

    it "should not warn if expected is set to nil" do
      Capybara.expected_shadowed_dsl_methods = nil
      expect_any_instance_of(Kernel).not_to receive(:warn)
      @session.class.class_eval do
        include Shadower
      end
    end
  end
end
