# frozen_string_literal: true
Capybara::SpecHelper.spec '#reset_session!' do
  it "removes cookies" do
    @session.visit('/set_cookie')
    @session.visit('/get_cookie')
    expect(@session).to have_content('test_cookie')

    @session.reset_session!
    @session.visit('/get_cookie')
    expect(@session.body).not_to include('test_cookie')
  end

  it "resets current url, host, path" do
    @session.visit '/foo'
    expect(@session.current_url).not_to be_empty
    expect(@session.current_host).not_to be_empty
    expect(@session.current_path).to eq('/foo')

    @session.reset_session!
    expect([nil, '', 'about:blank']).to include(@session.current_url)
    expect(['', nil]).to include(@session.current_path)
    expect(@session.current_host).to be_nil
  end

  it "resets page body" do
    @session.visit('/with_html')
    expect(@session).to have_content('This is a test')
    expect(@session.find('.//h1').text).to include('This is a test')

    @session.reset_session!
    expect(@session.body).not_to include('This is a test')
    expect(@session).to have_no_selector('.//h1')
  end

  it "is synchronous" do
    @session.visit("/with_slow_unload")
    expect(@session).to have_selector(:css, 'div')
    @session.reset_session!
    expect(@session).to have_no_selector :xpath, "/html/body/*", wait: false
  end

  it "handles modals during unload", requires: [:modals] do
    skip "geckodriver cannot be reliably reset with unload alerts" if marionette?(@session)
    @session.visit('/with_unload_alert')
    expect(@session).to have_selector(:css, 'div')
    expect { @session.reset_session! }.not_to raise_error
    expect(@session).to have_no_selector :xpath, "/html/body/*", wait: false
  end

  it "handles already open modals", requires: [:modals] do
    skip "geckodriver cannot be reliably reset with unload alerts" if marionette?(@session)
    @session.visit('/with_unload_alert')
    @session.click_link('Go away')
    expect { @session.reset_session! }.not_to raise_error
    expect(@session).to have_no_selector :xpath, "/html/body/*", wait: false
  end

  it "raises any standard errors caught inside the server", requires: [:server] do
    quietly { @session.visit("/error") }
    expect do
      @session.reset_session!
    end.to raise_error(TestApp::TestAppError)
    @session.visit("/")
    expect(@session.current_path).to eq("/")
  end

  context "When reuse_server == false" do
    before do
      @reuse_server = Capybara.reuse_server
      Capybara.reuse_server = false
    end

    it "raises any standard errors caught inside the server during a second session", requires: [:server] do
      Capybara.using_driver(@session.mode) do
        Capybara.using_session(:another_session) do
          @another_session = Capybara.current_session
          quietly { @another_session.visit("/error") }
          expect do
            @another_session.reset_session!
          end.to raise_error(TestApp::TestAppError)
          @another_session.visit("/")
          expect(@another_session.current_path).to eq("/")
        end
      end
    end

    after do
      Capybara.reuse_server = @reuse_server
    end
  end

  it "raises configured errors caught inside the server", requires: [:server] do
    prev_errors = Capybara.server_errors.dup

    Capybara.server_errors = [LoadError]
    quietly { @session.visit("/error") }
    expect do
      @session.reset_session!
    end.not_to raise_error

    quietly { @session.visit("/load_error") }
    expect do
      @session.reset_session!
    end.to raise_error(LoadError)

    Capybara.server_errors = prev_errors
  end

  it "ignores server errors when `Capybara.raise_server_errors = false`", requires: [:server] do
    Capybara.raise_server_errors = false
    quietly { @session.visit("/error") }
    @session.reset_session!
    @session.visit("/")
    expect(@session.current_path).to eq("/")
  end
end
