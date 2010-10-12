require 'capybara/spec/test_app'
require 'nokogiri'

Dir[File.dirname(__FILE__)+'/session/*'].each { |group| require group }

shared_examples_for "session" do
  def extract_results(session)
    YAML.load Nokogiri::HTML(session.body).xpath("//pre[@id='results']").first.text
  end

  after do
    @session.reset!
  end

  describe '#app' do
    it "should remember the application" do
      @session.app.should == TestApp
    end
  end

  describe '#visit' do
    it "should fetch a response from the driver" do
      @session.visit('/')
      @session.body.should include('Hello world!')
      @session.visit('/foo')
      @session.body.should include('Another World')
    end
  end

  describe '#body' do
    it "should return the unmodified page body" do
      @session.visit('/')
      @session.body.should include('Hello world!')
    end
  end

  describe '#source' do
    it "should return the unmodified page source" do
      @session.visit('/')
      @session.source.should include('Hello world!')
    end
  end

  it_should_behave_like "all"
  it_should_behave_like "attach_file"
  it_should_behave_like "check"
  it_should_behave_like "choose"
  it_should_behave_like "click_link_or_button"
  it_should_behave_like "click_button"
  it_should_behave_like "click_link"
  it_should_behave_like "fill_in"
  it_should_behave_like "find_button"
  it_should_behave_like "find_field"
  it_should_behave_like "find_link"
  it_should_behave_like "find_by_id"
  it_should_behave_like "find"
  it_should_behave_like "has_content"
  it_should_behave_like "has_css"
  it_should_behave_like "has_css"
  it_should_behave_like "has_selector"
  it_should_behave_like "has_xpath"
  it_should_behave_like "has_link"
  it_should_behave_like "has_button"
  it_should_behave_like "has_field"
  it_should_behave_like "has_select"
  it_should_behave_like "has_table"
  it_should_behave_like "select"
  it_should_behave_like "uncheck"
  it_should_behave_like "unselect"
  it_should_behave_like "within"
  it_should_behave_like "current_url"

  it "should encode complex field names, like array[][value]" do
    @session.visit('/form')
    @session.fill_in('address1_city', :with =>'Paris')
    @session.fill_in('address1_street', :with =>'CDG')
    @session.fill_in('address2_city', :with => 'Mikolaiv')
    @session.fill_in('address2_street', :with => 'PGS')
    @session.click_button "awesome"

    addresses=extract_results(@session)["addresses"]
    addresses.should have(2).addresses

    addresses[0]["street"].should == 'CDG'
    addresses[0]["city"].should   == 'Paris'

    addresses[1]["street"].should == 'PGS'
    addresses[1]["city"].should   == 'Mikolaiv'
  end

end


describe Capybara::Session do
  context 'with non-existant driver' do
    it "should raise an error" do
      running {
        Capybara::Session.new(:quox, TestApp).driver
      }.should raise_error(Capybara::DriverNotFoundError)
    end
  end
end
