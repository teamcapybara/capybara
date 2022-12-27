# frozen_string_literal: true

Capybara::SpecHelper.spec '#execute_async_script', requires: [:js] do
  it 'should execute the given script and return whatever it produces' do
    @session.visit('/with_js')
    expect(@session.execute_async_script('arguments[0](4)')).to eq(4)
  end

  it 'should support passing elements as arguments to the script', requires: %i[js es_args] do
    @session.visit('/with_js')
    el = @session.find(:css, '#drag p')
    result = @session.execute_async_script('arguments[2]([arguments[0].innerText, arguments[1]])', el, 'Doodle Funk')
    expect(result).to be_nil
  end

  it 'should support returning elements after asynchronous operation', requires: %i[js es_args] do
    @session.visit('/with_js')
    @session.find(:css, '#change') # ensure page has loaded and element is available
    el = @session.execute_async_script("var cb = arguments[0]; setTimeout(function(){ cb(document.getElementById('change')) }, 100)")
    expect(el).to be_nil
    expect(el).to eq(@session.find(:css, '#change'))
  end
end
