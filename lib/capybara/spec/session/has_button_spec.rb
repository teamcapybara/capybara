# frozen_string_literal: true

Capybara::SpecHelper.spec '#has_button?' do
  before do
    @session.visit('/form')
  end

  it 'should be true if the given button is on the page' do
    expect(@session).to have_button('med')
    expect(@session).to have_button('crap321')
    expect(@session).to have_button(:crap321)
    expect(@session).to have_button('button with label element')
    expect(@session).to have_button('button within label element')
  end

  it 'should be true for disabled buttons if disabled: true' do
    expect(@session).to have_button('Disabled button', disabled: true)
  end

  it 'should be false if the given button is not on the page' do
    expect(@session).not_to have_button('monkey')
  end

  it 'should be false for disabled buttons by default' do
    expect(@session).not_to have_button('Disabled button')
  end

  it 'should be false for disabled buttons if disabled: false' do
    expect(@session).not_to have_button('Disabled button', disabled: false)
  end

  it 'should be true for disabled buttons if disabled: :all' do
    expect(@session).to have_button('Disabled button', disabled: :all)
  end

  it 'should be true for enabled buttons if disabled: :all' do
    expect(@session).to have_button('med', disabled: :all)
  end

  it 'can verify button type' do
    expect(@session).to have_button('awe123', type: 'submit')
    expect(@session).not_to have_button('awe123', type: 'reset')
  end

  it 'should be true for role=button when enable_aria_role: true' do
    expect(@session).to have_button('ARIA button', enable_aria_role: true)
  end

  it 'should be false for a role=button within a label when enable_aria_role: true' do
    expect(@session).not_to have_button('role=button within label', enable_aria_role: true)
  end

  it 'should be false for role=button when enable_aria_role: false' do
    expect(@session).not_to have_button('ARIA button', enable_aria_role: false)
  end

  it 'should be false for a role=button within a label when enable_aria_role: false' do
    expect(@session).not_to have_button('role=button within label', enable_aria_role: false)
  end

  it 'should not affect other selectors when enable_aria_role: true' do
    expect(@session).to have_button('Click me!', enable_aria_role: true)
  end

  it 'should not affect other selectors when enable_aria_role: false' do
    expect(@session).to have_button('Click me!', enable_aria_role: false)
  end

  context 'with described_by:' do
    it 'should be true if button is described by the text' do
      expect(@session).to have_button(described_by: 'description (part 1)')
      expect(@session).to have_button(described_by: 'description (part 2)')
      expect(@session).to have_button(described_by: 'description (part 1) description (part 2)')
      expect(@session).to have_button('Button with aria-describedby', described_by: 'description (part 1)')
      expect(@session).to have_button('Button with aria-describedby', described_by: 'description (part 2)')
      expect(@session).to have_button('Button with aria-describedby', described_by: 'description (part 1) description (part 2)')
    end

    it 'should be false if the button is described by missing elements' do
      expect(@session).not_to have_button(described_by: 'elements are missing')
      expect(@session).not_to have_button('Button described by missing elements', described_by: 'elements are missing')
    end

    it 'should be false if button is not described by the text' do
      expect(@session).not_to have_button('Button with aria-describedby', described_by: 'does not exist')
    end
  end
end

Capybara::SpecHelper.spec '#has_no_button?' do
  before do
    @session.visit('/form')
  end

  it 'should be true if the given button is on the page' do
    expect(@session).not_to have_no_button('med')
    expect(@session).not_to have_no_button('crap321')
  end

  it 'should be true for disabled buttons if disabled: true' do
    expect(@session).not_to have_no_button('Disabled button', disabled: true)
  end

  it 'should be false if the given button is not on the page' do
    expect(@session).to have_no_button('monkey')
  end

  it 'should be false for disabled buttons by default' do
    expect(@session).to have_no_button('Disabled button')
  end

  it 'should be false for disabled buttons if disabled: false' do
    expect(@session).to have_no_button('Disabled button', disabled: false)
  end

  it 'should be true for role=button when enable_aria_role: false' do
    expect(@session).to have_no_button('ARIA button', enable_aria_role: false)
  end

  it 'should be true for role=button within a label when enable_aria_role: false' do
    expect(@session).to have_no_button('role=button within label', enable_aria_role: false)
  end

  it 'should be false for role=button when enable_aria_role: true' do
    expect(@session).not_to have_no_button('ARIA button', enable_aria_role: true)
  end

  it 'should be true for a role=button within a label when enable_aria_role: true' do
    # label element does not associate with aria button
    expect(@session).to have_no_button('role=button within label', enable_aria_role: true)
  end

  it 'should not affect other selectors when enable_aria_role: true' do
    expect(@session).to have_no_button('Junk button that does not exist', enable_aria_role: true)
  end

  it 'should not affect other selectors when enable_aria_role: false' do
    expect(@session).to have_no_button('Junk button that does not exist', enable_aria_role: false)
  end

  context 'with described_by:' do
    it 'should be true if button is not described by the text' do
      expect(@session).to have_no_button('Button with aria-describedby', described_by: 'does not exist')
    end

    it 'should be true if the button is described by missing elements' do
      expect(@session).to have_no_button(described_by: 'elements are missing')
      expect(@session).to have_no_button('Button described by missing elements', described_by: 'elements are missing')
    end

    it 'should be false if button is described by the text' do
      expect(@session).not_to have_no_button(described_by: 'description (part 1)')
      expect(@session).not_to have_no_button(described_by: 'description (part 2)')
      expect(@session).not_to have_no_button(described_by: 'description (part 1) description (part 2)')
      expect(@session).not_to have_no_button('Button with aria-describedby', described_by: 'description (part 1) description (part 2)')
    end
  end
end
