# frozen_string_literal: true
Capybara::SpecHelper.spec '#switch_to_window', requires: [:windows] do
  before(:each) do
    @window = @session.current_window
    @session.visit('/with_windows')
  end
  after(:each) do
    (@session.windows - [@window]).each do |w|
      @session.switch_to_window w
      w.close
    end
    @session.switch_to_window(@window)
  end

  it "should raise error when invoked without args" do
    expect do
      @session.switch_to_window
    end.to raise_error(ArgumentError, "`switch_to_window`: either window or block should be provided")
  end

  it "should raise error when invoked with window and block" do
    expect do
      @session.switch_to_window(@window) { @session.title == 'Title of the first popup' }
    end.to raise_error(ArgumentError, "`switch_to_window` can take either a block or a window, not both")
  end

  context "with an instance of Capybara::Window" do
    it "should be able to switch to window" do
      window = @session.open_new_window
      expect(@session.title).to eq('With Windows')
      @session.switch_to_window(window)
      expect(['', 'about:blank']).to include(@session.title)
    end

    it "should raise error when closed window is passed" do
      original_window = @session.current_window
      new_window = @session.open_new_window
      @session.switch_to_window(new_window)
      new_window.close
      @session.switch_to_window(original_window)
      expect do
        @session.switch_to_window(new_window)
      end.to raise_error(@session.driver.no_such_window_error)
    end
  end

  context "with block" do
    before(:each) do
      @session.find(:css, '#openTwoWindows').click
      sleep(0.2) # wait for the windows to open
    end

    it "should be able to switch to current window" do
      @session.switch_to_window { @session.title == 'With Windows' }
      expect(@session).to have_css('#openTwoWindows')
    end

    it "should find the div in another window" do
      @session.switch_to_window { @session.title == 'Title of popup two' }
      expect(@session).to have_css('#divInPopupTwo')
    end

    it "should be able to switch multiple times" do
      @session.switch_to_window { @session.title == 'Title of the first popup' }
      expect(@session).to have_css('#divInPopupOne')
      @session.switch_to_window { @session.title == 'Title of popup two' }
      expect(@session).to have_css('#divInPopupTwo')
    end

    it "should return window" do
      window = @session.switch_to_window { @session.title == 'Title of popup two' }
      expect((@session.windows - [@window])).to include(window)
    end

    it "should raise error when invoked inside `within` as it's nonsense" do
      expect do
        @session.within(:css, '#doesNotOpenWindows') do
          @session.switch_to_window { @session.title == 'With Windows' }
        end
      end.to raise_error(Capybara::ScopeError, "`switch_to_window` is not supposed to be invoked from `within`'s, `within_frame`'s' or `within_window`'s' block.")
    end

    it "should raise error when invoked inside `within_frame` as it's nonsense" do
      expect do
        @session.within_frame('frameOne') do
          @session.switch_to_window { @session.title == 'With Windows' }
        end
      end.to raise_error(Capybara::ScopeError, "`switch_to_window` is not supposed to be invoked from `within`'s, `within_frame`'s' or `within_window`'s' block.")
    end

    it "should raise error when invoked inside `within_window` as it's nonsense" do
      window = (@session.windows - [@window]).first
      expect do
        @session.within_window window do
          @session.switch_to_window { @session.title == 'With Windows' }
        end
      end.to raise_error(Capybara::ScopeError, "`switch_to_window` is not supposed to be invoked from `within`'s, `within_frame`'s' or `within_window`'s' block.")
    end

    it "should raise error if window matching block wasn't found" do
      original = @session.current_window
      expect do
        @session.switch_to_window { @session.title == 'A title' }
      end.to raise_error(Capybara::WindowError, "Could not find a window matching block/lambda")
      expect(@session.current_window).to eq(original)
    end

    it "should switch to original window if error is raised inside block" do
      original = @session.switch_to_window(@session.windows[1])
      expect do
        @session.switch_to_window { raise 'error' }
      end.to raise_error(StandardError, 'error')
      expect(@session.current_window).to eq(original)
    end
  end

  it "should wait for window to appear" do
    @session.find(:css, '#openWindowWithTimeout').click
    expect do
      @session.switch_to_window { @session.title == 'Title of the first popup'}
    end.not_to raise_error
  end
end
