Capybara::SpecHelper.spec '#within_window', requires: [:windows] do
  before(:each) do
    @window = @session.current_window
    @session.visit('/with_windows')
    @session.find(:css, '#openTwoWindows').click

    @session.document.synchronize(3, errors: [Capybara::CapybaraError]) do
      raise Capybara::CapybaraError if @session.windows.size != 3
    end
  end
  after(:each) do
    (@session.windows - [@window]).each do |w|
      @session.switch_to_window w
      w.close
    end
    @session.switch_to_window(@window)
  end

  context "with an instance of Capybara::Window" do
    it "should not invoke driver#switch_to_window when given current window" do
      # switch_to_window is invoked in after hook
      expect(@session.driver).to receive(:switch_to_window).exactly(3).times.and_call_original
      @session.within_window @window do
        expect(@session.title).to eq('With Windows')
      end
    end

    it "should be able to switch to another window" do
      window = (@session.windows - [@window]).first
      expect(@session.driver).to receive(:switch_to_window).exactly(5).times.and_call_original
      @session.within_window window do
        expect(['Title of the first popup', 'Title of popup two']).to include(@session.title)
      end
      expect(@session.title).to eq('With Windows')
    end

    it "returns value from the block" do
      window = (@session.windows - [@window]).first
      value = @session.within_window window do
                43252003274489856000
              end
      expect(value).to eq(43252003274489856000)
    end

    it "should switch back if exception was raised inside block" do
      window = (@session.windows - [@window]).first
      expect do
        @session.within_window(window) do
          @session.within 'html' do
            raise 'some error'
          end
        end
      end.to raise_error(StandardError, 'some error')
      expect(@session.current_window).to eq(@window)
      expect(@session).to have_css('#doesNotOpenWindows')
      expect(@session.send(:scopes)).to eq([nil])
    end

    it "should leave correct scopes after execution in case of error" do
      window = (@session.windows - [@window]).first
      expect do
        @session.within 'html' do
          @session.within_window(window) {}
        end
      end.to raise_error(Capybara::ScopeError)
      expect(@session.current_window).to eq(@window)
      expect(@session).to have_css('#doesNotOpenWindows')
      expect(@session.send(:scopes)).to eq([nil])
    end

    it 'should raise error if closed window was passed' do
      other_window = (@session.windows - [@window]).first
      @session.within_window other_window do
        other_window.close
      end
      expect do
        @session.within_window(other_window) do
          raise 'should not be invoked'
        end
      end.to raise_error(@session.driver.no_such_window_error)
      expect(@session.current_window).to eq(@window)
      expect(@session).to have_css('#doesNotOpenWindows')
      expect(@session.send(:scopes)).to eq([nil])
    end
  end

  context "with lambda" do
    it "should find the div in another window" do
      @session.within_window(->{ @session.title == 'Title of the first popup'}) do
        expect(@session).to have_css('#divInPopupOne')
      end
    end

    it "should find divs in both windows" do
      @session.within_window(->{ @session.title == 'Title of popup two'}) do
        expect(@session).to have_css('#divInPopupTwo')
      end
      @session.within_window(->{ @session.title == 'Title of the first popup'}) do
        expect(@session).to have_css('#divInPopupOne')
      end
      expect(@session.title).to eq('With Windows')
    end

    it "should raise error if window wasn't found" do
      expect do
        @session.within_window(->{ @session.title == 'Invalid title'}) do
          expect(@session).to have_css('#divInPopupOne')
        end
      end.to raise_error(Capybara::WindowError, "Could not find a window matching block/lambda")
      expect(@session.current_window).to eq(@window)
      expect(@session).to have_css('#doesNotOpenWindows')
      expect(@session.send(:scopes)).to eq([nil])
    end

    it "returns value from the block" do
      value = @session.within_window(->{ @session.title == 'Title of popup two'}) do
                42
              end
      expect(value).to eq(42)
    end

    it "should switch back if exception was raised inside block" do
      expect do
        @session.within_window(->{ @session.title == 'Title of popup two'}) do
          raise 'some error'
        end
      end.to raise_error(StandardError, 'some error')
      expect(@session.current_window).to eq(@window)
      expect(@session.send(:scopes)).to eq([nil])
    end
  end

  context "with string" do
    it "should warn" do
      expect(@session).to receive(:warn).with("DEPRECATION WARNING: Passing string argument "\
        "to #within_window is deprecated. Pass window object or lambda. "\
        "(called from #{__FILE__}:138)").and_call_original
      @session.within_window('firstPopup') {}
    end

    it "should find window by handle" do
      window = (@session.windows - [@window]).first
      @session.within_window window.handle do
        expect(['Title of the first popup', 'Title of popup two']).to include(@session.title)
      end
    end

    it "should find the div in firstPopup" do
      @session.within_window("firstPopup") do
        expect(@session.find("//*[@id='divInPopupOne']").text).to eq 'This is the text of divInPopupOne'
      end
    end
    it "should find the div in secondPopup" do
      @session.within_window("secondPopup") do
        expect(@session.find("//*[@id='divInPopupTwo']").text).to eq 'This is the text of divInPopupTwo'
      end
    end
    it "should find the divs in both popups" do
      @session.within_window("secondPopup") do
        expect(@session.find("//*[@id='divInPopupTwo']").text).to eq 'This is the text of divInPopupTwo'
      end
      @session.within_window("firstPopup") do
        expect(@session.find("//*[@id='divInPopupOne']").text).to eq 'This is the text of divInPopupOne'
      end
    end
    it "should find the div in the main window after finding a div in a popup" do
      @session.within_window("secondPopup") do
        expect(@session.find("//*[@id='divInPopupTwo']").text).to eq 'This is the text of divInPopupTwo'
      end
      expect(@session.find("//*[@id='doesNotOpenWindows']").text).to eq 'Does not open windows'
    end
    it "should reset scope when switching windows" do
      @session.within(:css, '#doesNotOpenWindows') do
        @session.within_window("secondPopup") do
          expect(@session.find("//*[@id='divInPopupTwo']").text).to eq 'This is the text of divInPopupTwo'
        end
      end
    end
    it "should switch back if exception was raised inside block" do
      expect do
        @session.within_window('secondPopup') do
          raise 'some error'
        end
      end.to raise_error(StandardError, 'some error')
      expect(@session.current_window).to eq(@window)
    end
  end
end
