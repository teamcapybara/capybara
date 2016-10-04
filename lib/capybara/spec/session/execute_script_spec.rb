# frozen_string_literal: true
Capybara::SpecHelper.spec "#execute_script", requires: [:js] do
  it "should execute the given script and return nothing" do
    @session.visit('/with_js')
    expect(@session.execute_script("document.getElementById('change').textContent = 'Funky Doodle'")).to be_nil
    expect(@session).to have_css('#change', text: 'Funky Doodle')
  end

  it "should be able to call functions defined in the page" do
    @session.visit('/with_js')
    expect{ @session.execute_script("$('#change').text('Funky Doodle')") }.not_to raise_error
  end
end
