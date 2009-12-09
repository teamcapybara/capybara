require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Capybara::XPath do

  before do
    @driver = Capybara::Driver::RackTest.new(TestApp)
    @driver.visit('/form')
    @xpath = Capybara::XPath.new
  end
  
  it "should proxy any class method calls to a new instance" do
    @query = Capybara::XPath.fillable_field('First Name').to_s
    @driver.find(@query).first.value.should == 'John'
  end
  
  it "should respond to instance methods at the class level" do
    Capybara::XPath.should respond_to(:fillable_field)
  end

  describe '#field' do
    it "should find any field by id or label" do
      @query = @xpath.field('First Name').to_s
      @driver.find(@query).first.value.should == 'John'
      @query = @xpath.field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
      @query = @xpath.field('Description').to_s
      @driver.find(@query).first.text.should == 'Descriptive text goes here'
      @query = @xpath.field('Document').to_s
      @driver.find(@query).first[:name].should == 'form[document]'
      @query = @xpath.field('Cat').to_s
      @driver.find(@query).first.value.should == 'cat'
      @query = @xpath.field('Male').to_s
      @driver.find(@query).first.value.should == 'male'
      @query = @xpath.field('Region').to_s
      @driver.find(@query).first[:name].should == 'form[region]'
    end
    
    it "should be chainable" do
      @query = @xpath.field('First Name').password_field('First Name').to_s
      @driver.find(@query).first.value.should == 'John'
      @query = @xpath.field('Password').password_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
    end
  end
  
  describe '#fillable_field' do
    it "should find a text field, password field, or text area by id or label" do
      @query = @xpath.fillable_field('First Name').to_s
      @driver.find(@query).first.value.should == 'John'
      @query = @xpath.fillable_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
      @query = @xpath.fillable_field('Description').to_s
      @driver.find(@query).first.text.should == 'Descriptive text goes here'
    end
    
    it "should be chainable" do
      @query = @xpath.fillable_field('First Name').password_field('First Name').to_s
      @driver.find(@query).first.value.should == 'John'
      @query = @xpath.fillable_field('Password').password_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
    end
  end

  describe '#text_field' do
    it "should find a text field by id or label" do
      @query = @xpath.text_field('form_first_name').to_s
      @driver.find(@query).first.value.should == 'John'
      @query = @xpath.text_field('First Name').to_s
      @driver.find(@query).first.value.should == 'John'
    end

    it "should be chainable" do
      @query = @xpath.text_field('First Name').password_field('First Name').to_s
      @driver.find(@query).first.value.should == 'John'
      @query = @xpath.text_field('Password').password_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
    end
  end

  describe '#password_field' do
    it "should find a password field by id or label" do
      @query = @xpath.password_field('form_password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
      @query = @xpath.password_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
    end

    it "should be chainable" do
      @query = @xpath.password_field('First Name').text_field('First Name').to_s
      @driver.find(@query).first.value.should == 'John'
      @query = @xpath.password_field('Password').text_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
    end
  end
  
  describe '#text_area' do
    it "should find a text area by id or label" do
      @query = @xpath.text_area('form_description').to_s
      @driver.find(@query).first.text.should == 'Descriptive text goes here'
      @query = @xpath.text_area('Description').to_s
      @driver.find(@query).first.text.should == 'Descriptive text goes here'
    end
    
    it "should be chainable" do
      @query = @xpath.text_area('Description').password_field('Description').to_s
      @driver.find(@query).first.text.should == 'Descriptive text goes here'
      @query = @xpath.text_area('Password').password_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
    end
  end
  
  describe '#radio_button' do
    it "should find a radio button by id or label" do
      @query = @xpath.radio_button('Male').to_s
      @driver.find(@query).first.value.should == 'male'
      @query = @xpath.radio_button('gender_male').to_s
      @driver.find(@query).first.value.should == 'male'
    end
    
    it "should be chainable" do
      @query = @xpath.radio_button('Male').password_field('Male').to_s
      @driver.find(@query).first.value.should == 'male'
      @query = @xpath.radio_button('Password').password_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
    end
  end
  
  describe '#checkbox' do
    it "should find a checkbox by id or label" do
      @query = @xpath.checkbox('Cat').to_s
      @driver.find(@query).first.value.should == 'cat'
      @query = @xpath.checkbox('form_pets_cat').to_s
      @driver.find(@query).first.value.should == 'cat'
    end
    
    it "should be chainable" do
      @query = @xpath.checkbox('Cat').password_field('Cat').to_s
      @driver.find(@query).first.value.should == 'cat'
      @query = @xpath.checkbox('Password').password_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
    end
  end

  describe '#select' do
    it "should find a select by id or label" do
      @query = @xpath.select('Region').to_s
      @driver.find(@query).first[:name].should == 'form[region]'
      @query = @xpath.select('form_region').to_s
      @driver.find(@query).first[:name].should == 'form[region]'
    end
    
    it "should be chainable" do
      @query = @xpath.select('Region').password_field('Region').to_s
      @driver.find(@query).first[:name].should == 'form[region]'
      @query = @xpath.select('Password').password_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
    end
  end
  
  describe '#file_field' do
    it "should find a file field by id or label" do
      @query = @xpath.file_field('Document').to_s
      @driver.find(@query).first[:name].should == 'form[document]'
      @query = @xpath.file_field('form_document').to_s
      @driver.find(@query).first[:name].should == 'form[document]'
    end
    
    it "should be chainable" do
      @query = @xpath.file_field('Document').password_field('Document').to_s
      @driver.find(@query).first[:name].should == 'form[document]'
      @query = @xpath.file_field('Password').password_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
    end
  end
  
end
