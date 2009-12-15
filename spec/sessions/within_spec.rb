module WithinSpec
  shared_examples_for "within" do  
    describe '#within' do
      before do
        @session.visit('/with_scope')
      end

      context "with CSS selector" do
        it "should click links in the given scope" do
          @session.within(:css, "ul li[contains('With Simple HTML')]") do
            @session.click_link('Go')
          end
          @session.body.should include('<h1>Bar</h1>')
        end
      end

      context "with XPath selector" do
        it "should click links in the given scope" do
          @session.within(:xpath, "//li[contains(.,'With Simple HTML')]") do
            @session.click_link('Go')
          end
          @session.body.should include('<h1>Bar</h1>')
        end
      end

      context "with the default selector" do
        it "should use XPath" do
          @session.within("//li[contains(., 'With Simple HTML')]") do
            @session.click_link('Go')
          end
          @session.body.should include('<h1>Bar</h1>')
        end
      end

      context "with the default selector set to CSS" do
        after do
          Capybara.default_selector = :xpath
        end

        it "should use CSS" do
          Capybara.default_selector = :css
          @session.within("ul li[contains('With Simple HTML')]") do
            @session.click_link('Go')
          end
          @session.body.should include('<h1>Bar</h1>')
        end
      end

      context "with click_link" do
        it "should click links in the given scope" do
          @session.within("//li[contains(.,'With Simple HTML')]") do
            @session.click_link('Go')
          end
          @session.body.should include('<h1>Bar</h1>')
        end

        context "with nested scopes" do
          it "should respect the inner scope" do
            @session.within("//div[@id='for_bar']") do
              @session.within("//li[contains(.,'Bar')]") do
                @session.click_link('Go')
              end
            end
            @session.body.should include('Another World')
          end

          it "should respect the outer scope" do
            @session.within("//div[@id='another_foo']") do
              @session.within("//li[contains(.,'With Simple HTML')]") do
                @session.click_link('Go')
              end
            end
            @session.body.should include('Hello world')
          end
        end

        it "should raise an error if the scope is not found on the page" do
          running {
            @session.within("//div[@id='doesnotexist']") do
            end
          }.should raise_error(Capybara::ElementNotFound)
        end
      end

      context "with forms" do
        it "should fill in a field and click a button" do
          @session.within("//li[contains(.,'Bar')]") do
            @session.click_button('Go')
          end
          extract_results(@session)['first_name'].should == 'Peter'
          @session.visit('/with_scope')
          @session.within("//li[contains(.,'Bar')]") do
            @session.fill_in('First Name', :with => 'Dagobert')
            @session.click_button('Go')
          end
          extract_results(@session)['first_name'].should == 'Dagobert'
        end
      end
    end

    describe '#within_fieldset' do
      before do
        @session.visit('/fieldsets')
      end

      it "should restrict scope to a fieldset given by id" do
        @session.within_fieldset("villain_fieldset") do
          @session.fill_in("Name", :with => 'Goldfinger')
          @session.click_button("Create")
        end
        extract_results(@session)['villain_name'].should == 'Goldfinger'
      end

      it "should restrict scope to a fieldset given by legend" do
        @session.within_fieldset("Villain") do
          @session.fill_in("Name", :with => 'Goldfinger')
          @session.click_button("Create")
        end
        extract_results(@session)['villain_name'].should == 'Goldfinger'
      end
    end

    describe '#within_table' do
      before do
        @session.visit('/tables')
      end

      it "should restrict scope to a fieldset given by id" do
        @session.within_table("girl_table") do
          @session.fill_in("Name", :with => 'Christmas')
          @session.click_button("Create")
        end
        extract_results(@session)['girl_name'].should == 'Christmas'
      end

      it "should restrict scope to a fieldset given by legend" do
        @session.within_table("Villain") do
          @session.fill_in("Name", :with => 'Quantum')
          @session.click_button("Create")
        end
        extract_results(@session)['villain_name'].should == 'Quantum'
      end
    end
  end
end  