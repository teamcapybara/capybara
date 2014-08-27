Capybara::SpecHelper.spec '#window_opened_by', requires: [:windows] do
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

  let(:zero_windows_message) { "block passed to #window_opened_by opened 0 windows instead of 1" }
  let(:two_windows_message) { "block passed to #window_opened_by opened 2 windows instead of 1" }

  context 'with :wait option' do
    it 'should raise error if value of :wait is less than timeout' do
      # So large value is used as `driver.window_handles` takes up to 800 ms on Travis
      Capybara.using_wait_time 2 do
        expect do
          @session.window_opened_by(wait: 0.8) do
            @session.find(:css, '#openWindowWithLongerTimeout').click
          end
        end.to raise_error(Capybara::WindowError, zero_windows_message)
      end
      @session.document.synchronize(2, errors: [Capybara::CapybaraError]) do
        raise Capybara::CapybaraError if @session.windows.size != 2
      end
    end

    it 'should find window if value of :wait is more than timeout' do
      Capybara.using_wait_time 0.1 do
        window = @session.window_opened_by(wait: 1.5) do
          @session.find(:css, '#openWindowWithTimeout').click
        end
        expect(window).to be_instance_of(Capybara::Window)
      end
    end
  end

  context 'without :wait option' do
    it 'should raise error if default_wait_time is less than timeout' do
      Capybara.using_wait_time 0.4 do
        expect do
          @session.window_opened_by do
            @session.find(:css, '#openWindowWithTimeout').click
          end
        end.to raise_error(Capybara::WindowError, zero_windows_message)
      end
      @session.document.synchronize(2, errors: [Capybara::CapybaraError]) do
        raise Capybara::CapybaraError if @session.windows.size != 2
      end
    end

    it 'should find window if default_wait_time is more than timeout' do
      Capybara.using_wait_time 1.5 do
        window = @session.window_opened_by do
          @session.find(:css, '#openWindowWithTimeout').click
        end
        expect(window).to be_instance_of(Capybara::Window)
      end
    end
  end

  it 'should raise error when two windows have been opened by block' do
    expect do
      @session.window_opened_by do
        @session.find(:css, '#openTwoWindows').click
      end
    end.to raise_error(Capybara::WindowError, two_windows_message)
    @session.document.synchronize(2, errors: [Capybara::CapybaraError]) do
      raise Capybara::CapybaraError if @session.windows.size != 3
    end
  end

  it 'should raise error when no windows were opened by block' do
    expect do
      @session.window_opened_by do
        @session.find(:css, '#doesNotOpenWindows').click
      end
    end.to raise_error(Capybara::WindowError, zero_windows_message)
  end
end
