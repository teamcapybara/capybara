Capybara::SpecHelper.spec Capybara::Window, requires: [:windows] do
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

  describe '#exists?' do
    before(:each) do
      @other_window = @session.window_opened_by do
        @session.find(:css, '#openWindow').click
      end
    end

    it "should become false after window was closed" do
      expect do
        @session.switch_to_window @other_window
        @other_window.close
      end.to change { @other_window.exists? }.from(true).to(false)
    end
  end

  describe '#closed?' do
    it "should become true after window was closed" do
      @other_window = @session.window_opened_by do
        @session.find(:css, '#openWindow').click
      end
      expect do
        @session.switch_to_window @other_window
        @other_window.close
      end.to change { @other_window.closed? }.from(false).to(true)
    end
  end

  describe '#current?' do
    before(:each) do
      @other_window = @session.window_opened_by do
        @session.find(:css, '#openWindow').click
      end
    end

    it 'should become true after switching to window' do
      expect do
        @session.switch_to_window(@other_window)
      end.to change { @other_window.current? }.from(false).to(true)
    end

    it 'should return false if window is closed' do
      @session.switch_to_window(@other_window)
      @other_window.close
      expect(@other_window.current?).to eq(false)
    end
  end

  describe '#close' do
    before(:each) do
      @other_window = @session.window_opened_by do
        @session.find(:css, '#openWindow').click
      end
    end

    it 'should switch to original window if invoked not for current window' do
      expect(@session.windows.size).to eq(2)
      expect(@session.current_window).to eq(@window)
      @other_window.close
      expect(@session.windows.size).to eq(1)
      expect(@session.current_window).to eq(@window)
    end

    it 'should make subsequent invocations of other methods raise no_such_window_error if invoked for current window' do
      @session.switch_to_window(@other_window)
      expect(@session.current_window).to eq(@other_window)
      @other_window.close
      expect do
        @session.find(:css, '#some_id')
      end.to raise_error(@session.driver.no_such_window_error)
      @session.switch_to_window(@window)
    end
  end

  describe '#size' do
    it 'should return size of whole window', requires: [:windows, :js] do
      expect(@session.current_window.size).to eq @session.evaluate_script("[window.outerWidth, window.outerHeight];")
    end

    it 'should switch to original window if invoked not for current window' do
      @other_window = @session.window_opened_by do
        @session.find(:css, '#openWindow').click
      end
      size =
        @session.within_window @other_window do
          @session.evaluate_script("[window.outerWidth, window.outerHeight];")
        end
      expect(@other_window.size).to eq(size)
      expect(@session.current_window).to eq(@window)
    end
  end

  describe '#resize_to' do
    it 'should be able to resize window', requires: [:windows, :js] do
      width, height = @session.evaluate_script("[window.outerWidth, window.outerHeight];")
      @session.current_window.resize_to(width-10, height-10)
      expect(@session.evaluate_script("[window.outerWidth, window.outerHeight];")).to eq([width-10, height-10])
    end

    it 'should switch to original window if invoked not for current window' do
      @other_window = @session.window_opened_by do
        @session.find(:css, '#openWindow').click
      end
      @other_window.resize_to(400, 300)
      expect(@session.current_window).to eq(@window)
      expect(@other_window.size).to eq([400, 300])
    end
  end

  describe '#maximize' do
    it 'should be able to maximize window', requires: [:windows, :js] do
      screen_width, screen_height = @session.evaluate_script("[window.screen.availWidth, window.screen.availHeight];")
      window = @session.current_window
      window.resize_to(screen_width-100, screen_height-100)
      expect(@session.evaluate_script("[window.outerWidth, window.outerHeight];")).to eq([screen_width-100, screen_height-100])
      window.maximize
      sleep 0.5  # The timing on maximize is finicky on Travis -- wait a bit for maximize to occur
      expect(@session.evaluate_script("[window.outerWidth, window.outerHeight];")).to eq([screen_width, screen_height])
    end

    it 'should switch to original window if invoked not for current window', requires: [:windows, :js] do
      @other_window = @session.window_opened_by do
        @session.find(:css, '#openWindow').click
      end
      @other_window.maximize
      expect(@session.current_window).to eq(@window)
      expect(@other_window.size).to eq(@session.evaluate_script("[window.screen.availWidth, window.screen.availHeight];"))
    end
  end
end
