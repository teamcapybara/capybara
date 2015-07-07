Capybara::SpecHelper.spec '#become_closed', requires: [:windows, :js] do
  before(:each) do
    @window = @session.current_window
    @session.visit('/with_windows')
    @other_window = @session.window_opened_by do
      @session.find(:css, '#openWindow').click
    end
  end

  after(:each) do
    @session.document.synchronize(5, errors: [Capybara::CapybaraError]) do
      raise Capybara::CapybaraError if @session.windows.size != 1
    end
    @session.switch_to_window(@window)
  end

  context 'with :wait option' do
    it 'should wait if value of :wait is more than timeout' do
      @session.within_window @other_window do
        @session.execute_script('setTimeout(function(){ window.close(); }, 500);')
      end
      Capybara.using_wait_time 0.1 do
        expect(@other_window).to become_closed(wait: 2)
      end
    end

    it 'should raise error if value of :wait is less than timeout' do
      @session.within_window @other_window do
        @session.execute_script('setTimeout(function(){ window.close(); }, 700);')
      end
      Capybara.using_wait_time 2 do
        expect do
          expect(@other_window).to become_closed(wait: 0.4)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /\Aexpected #<Window @handle=".+"> to become closed after 0.4 seconds\Z/)
      end
    end
  end

  context 'without :wait option' do
    it 'should wait if value of default_max_wait_time is more than timeout' do
      @session.within_window @other_window do
        @session.execute_script('setTimeout(function(){ window.close(); }, 500);')
      end
      Capybara.using_wait_time 1.5 do
        expect(@other_window).to become_closed
      end
    end

    it 'should raise error if value of default_max_wait_time is less than timeout' do
      @session.within_window @other_window do
        @session.execute_script('setTimeout(function(){ window.close(); }, 900);')
      end
      Capybara.using_wait_time 0.4 do
        expect do
          expect(@other_window).to become_closed
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /\Aexpected #<Window @handle=".+"> to become closed after 0.4 seconds\Z/)
      end
    end
  end

  context 'with not_to' do
    it 'should raise error if default_max_wait_time is more than timeout' do
      @session.within_window @other_window do
        @session.execute_script('setTimeout(function(){ window.close(); }, 700);')
      end
      Capybara.using_wait_time 0.4 do
        expect do
          expect(@other_window).not_to become_closed
        end
      end
    end

    it 'should raise error if default_max_wait_time is more than timeout' do
      @session.within_window @other_window do
        @session.execute_script('setTimeout(function(){ window.close(); }, 700);')
      end
      Capybara.using_wait_time 1.1 do
        expect do
          expect(@other_window).not_to become_closed
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /\Aexpected #<Window @handle=".+"> not to become closed after 1.1 seconds\Z/)
      end
    end
  end
end
