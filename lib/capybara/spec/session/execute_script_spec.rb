# frozen_string_literal: true
Capybara::SpecHelper.spec "#execute_script", :requires => [:js] do
  it "should execute the given script and return nothing" do
    @session.visit('/with_js')
    expect(@session.execute_script("$('#change').text('Funky Doodle')")).to be_nil
    expect(@session).to have_css('#change', :text => 'Funky Doodle')
  end
end
