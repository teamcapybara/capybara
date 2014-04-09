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

    it 'should change number of windows' do
      expect do
        @session.within_window(@other_window) do
          @other_window.close
        end
      end.to change { @session.windows.size }.from(2).to(1)
    end

    it 'should raise error if invoked not for current window' do
      expect do
        @other_window.close
      end.to raise_error(Capybara::WindowError, "Closing not current window is not possible.")
    end
  end

  describe '#size' do
    it 'should return size of whole window' do
      expect(@session.current_window.size).to eq @session.evaluate_script("[window.outerWidth, window.outerHeight];")
    end

    it 'should raise error if invoked not for current window' do
      @other_window = @session.window_opened_by do
        @session.find(:css, '#openWindow').click
      end
      expect do
        @other_window.size
      end.to raise_error(Capybara::WindowError, "Getting size of not current window is not possible.")
    end
  end

  describe '#resize_to' do
    it 'should be able to resize window' do
      width, height = @session.evaluate_script("[window.outerWidth, window.outerHeight];")
      @session.current_window.resize_to(width-10, height-10)
      expect(@session.evaluate_script("[window.outerWidth, window.outerHeight];")).to eq([width-10, height-10])
    end

    it 'should raise error if invoked not for current window' do
      @other_window = @session.window_opened_by do
        @session.find(:css, '#openWindow').click
      end
      expect do
        @other_window.resize_to(1000, 700)
      end.to raise_error(Capybara::WindowError, "Resizing not current window is not possible.")
    end
  end
end
