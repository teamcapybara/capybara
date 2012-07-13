shared_examples_for "session with javascript support" do
  describe 'all JS specs' do
    before do
      Capybara.default_wait_time = 1
    end

    after do
      Capybara.default_wait_time = 0
    end

    describe 'Node#drag_to' do
      it "should drag and drop an object" do
        @session.visit('/with_js')
        element = @session.find('//div[@id="drag"]')
        target = @session.find('//div[@id="drop"]')
        element.drag_to(target)
        @session.find('//div[contains(., "Dropped!")]').should_not be_nil
      end
    end

    describe 'Node#reload' do
      context "without automatic reload" do
        before { Capybara.automatic_reload = false }
        it "should reload the current context of the node" do
          @session.visit('/with_js')
          node = @session.find(:css, '#reload-me')
          @session.click_link('Reload!')
          sleep(0.3)
          node.reload.text.should == 'RELOADED'
          node.text.should == 'RELOADED'
        end

        it "should reload a parent node" do
          @session.visit('/with_js')
          node = @session.find(:css, '#reload-me').find(:css, 'em')
          @session.click_link('Reload!')
          sleep(0.3)
          node.reload.text.should == 'RELOADED'
          node.text.should == 'RELOADED'
        end

        it "should not automatically reload" do
          @session.visit('/with_js')
          node = @session.find(:css, '#reload-me')
          @session.click_link('Reload!')
          sleep(0.3)
          running { node.text.should == 'RELOADED' }.should raise_error
        end
        after { Capybara.automatic_reload = true }
      end

      context "with automatic reload" do
        it "should reload the current context of the node automatically" do
          @session.visit('/with_js')
          node = @session.find(:css, '#reload-me')
          @session.click_link('Reload!')
          sleep(0.3)
          node.text.should == 'RELOADED'
        end

        it "should reload a parent node automatically" do
          @session.visit('/with_js')
          node = @session.find(:css, '#reload-me').find(:css, 'em')
          @session.click_link('Reload!')
          sleep(0.3)
          node.text.should == 'RELOADED'
        end

        it "should reload a node automatically when using find" do
          @session.visit('/with_js')
          node = @session.find(:css, '#reload-me')
          @session.click_link('Reload!')
          sleep(0.3)
          node.find(:css, 'a').text.should == 'RELOADED'
        end

        it "should not reload nodes which haven't been found" do
          @session.visit('/with_js')
          node = @session.all(:css, '#the-list li')[1]
          @session.click_link('Fetch new list!')
          sleep(0.3)
          running { node.text.should == 'Foo' }.should raise_error
          running { node.text.should == 'Bar' }.should raise_error
        end
      end
    end

    describe '#find' do
      it "should allow triggering of custom JS events" do
        # Not supported by Selenium without resorting to JavaScript execution
        # http://code.google.com/p/selenium/wiki/FrequentlyAskedQuestions#Q:_How_can_I_trigger_arbitrary_events_on_the_page?
        unless @session.mode == :selenium
          @session.visit('/with_js')
          @session.find(:css, '#with_focus_event').trigger(:focus)
          @session.should have_css('#focus_event_triggered')
        end
      end
    end

    describe '#html' do
      it "should return the current state of the page" do
        @session.visit('/with_js')
        @session.html.should include('I changed it')
        @session.html.should_not include('This is text')
      end
    end

    [:body, :source].each do |method|
      describe "##{method}" do
        it "should return the original, unmodified source of the page" do
          # Not supported by Selenium. See for example
          # http://stackoverflow.com/questions/6050805
          unless @session.mode == :selenium
            @session.visit('/with_js')
            @session.send(method).should include('This is text')
            @session.send(method).should_not include('I changed it')
          end
        end
      end
    end

    describe "#evaluate_script" do
      it "should evaluate the given script and return whatever it produces" do
        @session.visit('/with_js')
        @session.evaluate_script("1+3").should == 4
      end
    end

    describe "#execute_script" do
      it "should execute the given script and return nothing" do
        @session.visit('/with_js')
        @session.execute_script("$('#change').text('Funky Doodle')").should be_nil
        @session.should have_css('#change', :text => 'Funky Doodle')
      end
    end

    describe '#find' do
      it "should wait for asynchronous load" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.find(:css, "a#has-been-clicked").text.should include('Has been clicked')
      end

      context "with frozen time" do
        it "raises an error suggesting that Capybara is stuck in time" do
          @session.visit('/with_js')
          now = Time.now
          Time.stub(:now).and_return(now)
          expect { @session.find('//isnotthere') }.to raise_error(Capybara::FrozenInTime)
        end
      end
    end

    describe '#click_link_or_button' do
      it "should wait for asynchronous load" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.click_link_or_button('Has been clicked')
      end
    end

    describe '#click_link' do
      it "should wait for asynchronous load" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.click_link('Has been clicked')
      end
    end

    describe '#click_button' do
      it "should wait for asynchronous load" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.click_button('New Here')
      end
    end

    describe '#fill_in' do
      it "should wait for asynchronous load" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.fill_in('new_field', :with => 'Testing...')
      end

      context 'on a pre-populated textfield with a reformatting onchange' do
        it 'should only trigger onchange once' do
          @session.fill_in('with_change_event', :with => 'some value')
          @session.find(:css, '#with_change_event').value.should == 'some value'
        end
      end
    end

    describe '#check' do
      it "should trigger associated events" do
        @session.visit('/with_js')
        @session.check('checkbox_with_event')
        @session.should have_css('#checkbox_event_triggered');
      end
    end

    describe '#has_xpath?' do
      it "should wait for content to appear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_xpath("//input[@type='submit' and @value='New Here']")
      end
    end

    describe '#has_no_xpath?' do
      it "should wait for content to disappear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_no_xpath("//p[@id='change']")
      end
    end

    describe '#has_css?' do
      it "should wait for content to appear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_css("input[type='submit'][value='New Here']")
      end
    end

    describe '#has_no_xpath?' do
      it "should wait for content to disappear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_no_css("p#change")
      end
    end

    describe '#has_content?' do
      it "should wait for content to appear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_content("Has been clicked")
      end
    end

    describe '#has_no_content?' do
      it "should wait for content to disappear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_no_content("I changed it")
      end
    end

    describe '#has_text?' do
      it "should wait for text to appear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_text("Has been clicked")
      end
    end

    describe '#has_no_text?' do
      it "should wait for text to disappear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_no_text("I changed it")
      end
    end

    describe "#current_path" do
     it "is affected by pushState" do
       @session.visit("/with_js")
       @session.execute_script("window.history.pushState({}, '', '/pushed')")
       @session.current_path.should == "/pushed"
     end

     it "is affected by replaceState" do
       @session.visit("/with_js")
       @session.execute_script("window.history.replaceState({}, '', '/replaced')")
       @session.current_path.should == "/replaced"
     end
   end
  end
end

shared_examples_for "session without javascript support" do
  describe "#evaluate_script" do
    before{ @session.visit('/with_simple_html') }
    it "should raise an error" do
      running {
        @session.evaluate_script('3 + 3')
      }.should raise_error(Capybara::NotSupportedByDriverError)
    end
  end
end
