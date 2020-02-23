# frozen_string_literal: true

Capybara::SpecHelper.spec 'shadow', requires: %i[js shadow] do
  before { @session.visit('/form') }

  it 'can check for fields in the shadow dom' do
    form = @session.first(:css, 'form')
    shadow = @session.evaluate_script <<~JS, form
      (function(form){
        var shadow_host = document.createElement('div');
        var shadow = shadow_host.attachShadow({mode: 'open'});
        shadow.appendChild(form);
        document.documentElement.appendChild(shadow_host);
        return shadow;
      }).apply(this, arguments)
    JS

    expect(shadow).to have_field('Dog', selector_format: :css)
    expect(shadow).not_to have_field('Monkey', selector_format: :css)

    expect(shadow).to have_field('First Name', with: 'John', selector_format: :css)
    expect(shadow).to have_field('First Name', with: /^Joh/, selector_format: :css)
    expect(shadow).not_to have_field('Random', with: 'John', selector_format: :css)

    expect(shadow).not_to have_field('First Name', with: 'Peter', selector_format: :css)
    expect(shadow).not_to have_field('First Name', with: /eter$/, selector_format: :css)

    shadow.fill_in('First Name', with: 'Jonas', selector_format: :css, fill_options: { clear: :backspace })
    expect(shadow).to have_field('First Name', with: 'Jonas', selector_format: :css)
    expect(shadow).to have_field('First Name', with: /ona/, selector_format: :css)

    shadow.fill_in('First Name', with: 'Jonas', selector_format: :css, fill_options: { clear: :backspace })
    expect(shadow).not_to have_field('First Name', with: 'John', selector_format: :css)
    expect(shadow).not_to have_field('First Name', with: /John|Paul|George|Ringo/, selector_format: :css)

    # shadow.fill_in('First Name', with: 'Thomas', selector_format: :css, fill_options: { clear: :backspace})
    # expect do
    #   expect(shadow).to have_field('First Name', with: 'Jonas', selector_format: :css)
    # end.to raise_exception(RSpec::Expectations::ExpectationNotMetError, /Expected value to be "Jonas" but was "Thomas"/)
    #
    # expect do
    #   expect(shadow).to have_field('First Name', readonly: true, selector_format: :css)
    # end.to raise_exception(RSpec::Expectations::ExpectationNotMetError, /Expected readonly true but it wasn't/)
    #
    # # inherited boolean node filter
    # expect do
    #   expect(shadow).to have_field('form_pets_cat', checked: true, selector_format: :css)
    # end.to raise_exception(RSpec::Expectations::ExpectationNotMetError, /Expected checked true but it wasn't/)
    #
    # expect(shadow).to have_field('First Name', type: 'text', selector_format: :css)
    #
    # expect(shadow).not_to have_field('First Name', type: 'textarea', selector_format: :css)
    #
    # expect(shadow).to have_field('form[data]', with: 'TWTW', type: 'hidden', selector_format: :css)
    #
    # expect(shadow).to have_field('Html5 Multiple Email', multiple: true, selector_format: :css)
    #
    # expect(shadow).not_to have_field('Html5 Multiple Email', multiple: false, selector_format: :css)
    #
    # shadow.fill_in 'required', with: 'something', selector_format: :css, fill_options: { clear: :backspace}
    # shadow.fill_in 'length', with: 'abcd', selector_format: :css, fill_options: { clear: :backspace}
    #
    # expect(shadow).to have_field('required', valid: true, selector_format: :css)
    # expect(shadow).to have_field('length', valid: true, selector_format: :css)
    #
    # expect(shadow).not_to have_field('required', valid: true, selector_format: :css)
    # expect(shadow).to have_field('required', valid: false, selector_format: :css)
    #
    # shadow.fill_in 'length', with: 'abc', selector_format: :css, fill_options: { clear: :backspace}
    # expect(shadow).not_to have_field('length', valid: true, selector_format: :css)
  end
end
