# frozen_string_literal: true

require 'capybara/plugins/select2'
require 'capybara/plugins/react_select'

Capybara::SpecHelper.spec 'Plugin', requires: [:js], focus_: true do
  before do
    @session.visit('https://select2.org/appearance')
  end

  after do
    Capybara.default_plugin = nil
  end

  it 'should raise if wrong plugin specified' do
    expect do
      @session.select 'Florida', from: 'Click this to focus the single select element', using: :select3
    end.to raise_error(ArgumentError, /Plugin not loaded/)
  end

  it 'should raise if non-implemented action is called' do
    expect do
      @session.click_on('blah', using: :select2)
    end.to raise_error(NoMethodError, /Action not implemented/)
  end

  it 'should select an option' do
    @session.select 'Florida', from: 'Click this to focus the single select element', using: :select2
    expect(@session).to have_field(type: 'select', with: 'FL', visible: false)
  end

  it 'should remain selected if called twice on a single select' do
    @session.select 'Florida', from: 'Click this to focus the single select element', using: :select2
    @session.select 'Florida', from: 'Click this to focus the single select element', using: :select2
    expect(@session).to have_field(type: 'select', with: 'FL', visible: false)
  end

  it 'should work with multiple select' do
    @session.select 'Pennsylvania', from: 'Click this to focus the multiple select element', using: :select2
    @session.select 'California', from: 'Click this to focus the multiple select element', using: :select2
    expect(@session).to have_select(multiple: true, selected: %w[Pennsylvania California], visible: false)
    @session.unselect 'Pennsylvania', from: 'Click this to focus the multiple select element', using: :select2
    expect(@session).to have_select(multiple: true, selected: %w[California], visible: false)
    @session.unselect 'California', from: 'Click this to focus the multiple select element', using: :select2
    expect(@session).to have_select(multiple: true, selected: %w[], visible: false)
  end

  it 'should not reselect if already selected' do
    @session.select 'Pennsylvania', from: 'Click this to focus the multiple select element', using: :select2
    @session.select 'Pennsylvania', from: 'Click this to focus the multiple select element', using: :select2
    expect(@session).to have_select(multiple: true, selected: %w[Pennsylvania], visible: false)
    @session.unselect 'Pennsylvania', from: 'Click this to focus the multiple select element', using: :select2
    @session.unselect 'Pennsylvania', from: 'Click this to focus the multiple select element', using: :select2
    expect(@session).to have_select(multiple: true, selected: %w[], visible: false)
  end

  it 'should work with id' do
    @session.select 'Florida', from: 'id_label_single', using: :select2
    expect(@session).to have_field(type: 'select', with: 'FL', visible: false)
  end

  it 'works without :from' do
    @session.within(:css, 'div.s2-example:nth-of-type(2) p:first-child') do
      @session.select 'Florida', using: :select2
      expect(@session).to have_field(type: 'select', with: 'FL', visible: false)
    end
  end

  it 'works when called on the select box' do
    el = @session.find(:css, 'select#id_label_single', visible: false)
    el.select 'Florida', using: :select2
    expect(@session).to have_field(type: 'select', with: 'FL', visible: false)
  end

  it 'can set a default plugin to use' do
    Capybara.default_plugin[:select] = :select2
    @session.select 'Florida', from: 'Click this to focus the single select element'
    expect(@session).to have_field(type: 'select', with: 'FL', visible: false)
  end

  it 'can override a default plugin' do
    @session.visit('/form')
    Capybara.default_plugin[:select] = :select2
    @session.select 'Miss', from: 'Title', using: nil
    expect(@session.find_field('Title').value).to eq('Miss')
  end

  context 'with react select 2' do
    before do
      @session.visit('https://react-select.com/home')
    end

    it 'should select an option' do
      @session.select 'Red', from: 'color', using: :react_select
      expect(@session).to have_field('color', type: 'hidden', with: 'red')
    end

    it 'should remain selected if called twice on a single select' do
      @session.select 'Blue', from: 'color', using: :react_select
      @session.select 'Blue', from: 'color', using: :react_select
      expect(@session).to have_field('color', type: 'hidden', with: 'blue')
    end

    it 'should work with multiple select' do
      @session.within @session.first(:css, 'div.basic-multi-select') do
        @session.select 'Green', from: 'colors', using: :react_select
        @session.select 'Silver', from: 'colors', using: :react_select
        expect(@session).to have_field('colors', with: 'green', type: 'hidden')
        expect(@session).to have_field('colors', with: 'silver', type: 'hidden')
      end
    end

    it 'should unselect an option' do
      @session.within @session.first(:css, 'div.basic-multi-select') do
        @session.select 'Green', from: 'colors', using: :react_select
        expect(@session).to have_field('colors', with: 'green', type: 'hidden')
        @session.unselect 'Green', from: 'colors', using: :react_select
        expect(@session).to have_no_field('colors', with: 'green', type: 'hidden')
      end
    end

    it 'should work with name' do
      @session.select 'Purple', from: 'color', using: :react_select
      expect(@session).to have_css('input[type=hidden][name=color]', visible: false) { |el| el.value == 'purple' }
    end
  end
end
