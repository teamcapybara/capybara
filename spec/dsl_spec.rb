require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'webcat/dsl'

describe Webcat do

  before do
    Webcat.app = TestApp
  end

  after do
    Webcat.default_driver = nil
    Webcat.use_default_driver
  end

  describe '#default_driver' do
    it "should default to rack_test" do
      Webcat.default_driver.should == :rack_test
    end

    it "should be changeable" do
      Webcat.default_driver = :culerity
      Webcat.default_driver.should == :culerity
    end
  end

  describe '#current_driver' do
    it "should default to the default driver" do
      Webcat.current_driver.should == :rack_test
      Webcat.default_driver = :culerity
      Webcat.current_driver.should == :culerity
    end

    it "should be changeable" do
      Webcat.current_driver = :culerity
      Webcat.current_driver.should == :culerity
    end
  end

  describe '#use_default_driver' do
    it "should restore the default driver" do
      Webcat.current_driver = :culerity
      Webcat.use_default_driver
      Webcat.current_driver.should == :rack_test
    end
  end

  describe '#app' do
    it "should be changeable" do
      Webcat.app = "foobar"
      Webcat.app.should == 'foobar'
    end
  end

  describe '#current_session' do
    it "should choose a session object of the current driver type" do
      Webcat.current_session.should be_a(Webcat::Session)
    end

    it "should use #app as the application" do
      Webcat.app = proc {}
      Webcat.current_session.app.should == Webcat.app
    end

    it "should change with the current driver" do
      Webcat.current_session.mode.should == :rack_test
      Webcat.current_driver = :culerity
      Webcat.current_session.mode.should == :culerity
    end

    it "should be persistent even across driver changes" do
      object_id = Webcat.current_session.object_id
      Webcat.current_session.object_id.should == object_id
      Webcat.current_driver = :culerity
      Webcat.current_session.mode.should == :culerity
      Webcat.current_session.object_id.should_not == object_id

      Webcat.current_driver = :rack_test
      Webcat.current_session.object_id.should == object_id
    end

    it "should change when changing application" do
      object_id = Webcat.current_session.object_id
      Webcat.current_session.object_id.should == object_id
      Webcat.app = proc {}
      Webcat.current_session.object_id.should_not == object_id
      Webcat.current_session.app.should == Webcat.app
    end
  end

  describe 'the DSL' do
    before do
      @session = Webcat
    end

    it_should_behave_like "session"

    it "should be possible to include it in another class" do
      klass = Class.new do
        include Webcat
      end
      foo = klass.new
      foo.visit('/with_html')
      foo.click_link('ullamco')
      foo.body.should include('Another World')
    end
    
    it "should provide a 'page' shortcut for more expressive tests" do
      klass = Class.new do
        include Webcat
      end
      foo = klass.new
      foo.page.visit('/with_html')
      foo.page.click_link('ullamco')
      foo.page.body.should include('Another World')
    end
  end

end
