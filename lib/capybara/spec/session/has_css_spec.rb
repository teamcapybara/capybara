shared_examples_for "has_css" do  
  describe '#has_css?' do
    before do
      @session.visit('/with_html')
    end

    it "should be true if the given selector is on the page" do
      @session.should have_css("p")
      @session.should have_css("p a#foo")
    end

    it "should be false if the given selector is not on the page" do
      @session.should_not have_css("abbr")
      @session.should_not have_css("p a#doesnotexist")
      @session.should_not have_css("p.nosuchclass")
    end

    it "should respect scopes" do
      @session.within "//p[@id='first']" do
        @session.should have_css("a#foo")
        @session.should_not have_css("a#red")
      end
    end

    context "with between" do
      it "should be true if the content occurs within the range given" do
        @session.should have_css("p", :between => 1..4)
        @session.should have_css("p a#foo", :between => 1..3)
      end

      it "should be false if the content occurs more or fewer times than range" do
        @session.should_not have_css("p", :between => 6..11 )
        @session.should_not have_css("p a#foo", :between => 4..7)
      end

      it "should be false if the content isn't on the page at all" do
        @session.should_not have_css("abbr", :between => 1..8)
        @session.should_not have_css("p a.doesnotexist", :between => 3..8)
      end
    end

    context "with count" do
      it "should be true if the content is on the page the given number of times" do
        @session.should have_css("p", :count => 3)
        @session.should have_css("p a#foo", :count => 1)
      end

      it "should be false if the content occurs the given number of times" do
        @session.should_not have_css("p", :count => 6)
        @session.should_not have_css("p a#foo", :count => 2)
      end

      it "should be false if the content isn't on the page at all" do
        @session.should_not have_css("abbr", :count => 2)
        @session.should_not have_css("p a.doesnotexist", :count => 1)
      end

      it "should coerce count to an integer" do
        @session.should have_css("p", :count => "3")
        @session.should have_css("p a#foo", :count => "1")
      end
    end

    context "with maximum" do
      it "should be true when content occurs same or fewer times than given" do
        @session.should have_css("h2.head", :maximum => 5) # edge case
        @session.should have_css("h2", :maximum => 10)
      end

      it "should be false when content occurs more times than given" do
        @session.should_not have_css("h2.head", :maximum => 4) # edge case
        @session.should_not have_css("h2", :maximum => 6)
        @session.should_not have_css("p", :maximum => 1)
      end

      it "should be false if the content isn't on the page at all" do
        @session.should_not have_css("abbr", :maximum => 2)
        @session.should_not have_css("p a.doesnotexist", :maximum => 1)
      end

      it "should coerce maximum to an integer" do
        @session.should have_css("h2.head", :maximum => "5") # edge case
        @session.should have_css("h2", :maximum => "10")
      end
    end

    context "with minimum" do
      it "should be true when content occurs same or more times than given" do
        @session.should have_css("h2.head", :minimum => 5) # edge case
        @session.should have_css("h2", :minimum => 3)
      end

      it "should be false when content occurs fewer times than given" do
        @session.should_not have_css("h2.head", :minimum => 6) # edge case
        @session.should_not have_css("h2", :minimum => 8)
        @session.should_not have_css("p", :minimum => 10)
      end

      it "should be false if the content isn't on the page at all" do
        @session.should_not have_css("abbr", :minimum => 2)
        @session.should_not have_css("p a.doesnotexist", :minimum => 7)
      end

      it "should coerce minimum to an integer" do
        @session.should have_css("h2.head", :minimum => "5") # edge case
        @session.should have_css("h2", :minimum => "3")
      end
    end

    context "with text" do
      it "should discard all matches where the given string is not contained" do
        @session.should have_css("p a", :text => "Redirect", :count => 1)
        @session.should_not have_css("p a", :text => "Doesnotexist")
      end

      it "should discard all matches where the given regexp is not matched" do
        @session.should have_css("p a", :text => /re[dab]i/i, :count => 1)
        @session.should_not have_css("p a", :text => /Red$/)
      end
    end
  end

  describe '#has_no_css?' do
    before do
      @session.visit('/with_html')
    end

    it "should be false if the given selector is on the page" do
      @session.should_not have_no_css("p")
      @session.should_not have_no_css("p a#foo")
    end

    it "should be true if the given selector is not on the page" do
      @session.should have_no_css("abbr")
      @session.should have_no_css("p a#doesnotexist")
      @session.should have_no_css("p.nosuchclass")
    end

    it "should respect scopes" do
      @session.within "//p[@id='first']" do
        @session.should_not have_no_css("a#foo")
        @session.should have_no_css("a#red")
      end
    end

    context "with between" do
      it "should be false if the content occurs within the range given" do
        @session.should_not have_no_css("p", :between => 1..4)
        @session.should_not have_no_css("p a#foo", :between => 1..3)
      end

      it "should be true if the content occurs more or fewer times than range" do
        @session.should have_no_css("p", :between => 6..11 )
        @session.should have_no_css("p a#foo", :between => 4..7)
      end

      it "should be true if the content isn't on the page at all" do
        @session.should have_no_css("abbr", :between => 1..8)
        @session.should have_no_css("p a.doesnotexist", :between => 3..8)
      end
    end

    context "with count" do
      it "should be false if the content is on the page the given number of times" do
        @session.should_not have_no_css("p", :count => 3)
        @session.should_not have_no_css("p a#foo", :count => 1)
      end

      it "should be true if the content is on the page the given number of times" do
        @session.should have_no_css("p", :count => 6)
        @session.should have_no_css("p a#foo", :count => 2)
      end

      it "should be true if the content isn't on the page at all" do
        @session.should have_no_css("abbr", :count => 2)
        @session.should have_no_css("p a.doesnotexist", :count => 1)
      end

      it "should coerce count to an integer" do
        @session.should_not have_no_css("p", :count => "3")
        @session.should_not have_no_css("p a#foo", :count => "1")
      end
    end

    context "with maximum" do
      it "should be false when content occurs same or fewer times than given" do
        @session.should_not have_no_css("h2.head", :maximum => 5) # edge case
        @session.should_not have_no_css("h2", :maximum => 10)
      end

      it "should be true when content occurs more times than given" do
        @session.should have_no_css("h2.head", :maximum => 4) # edge case
        @session.should have_no_css("h2", :maximum => 6)
        @session.should have_no_css("p", :maximum => 1)
      end

      it "should be true if the content isn't on the page at all" do
        @session.should have_no_css("abbr", :maximum => 5)
        @session.should have_no_css("p a.doesnotexist", :maximum => 10)
      end

      it "should coerce maximum to an integer" do
        @session.should_not have_no_css("h2.head", :maximum => "5") # edge case
        @session.should_not have_no_css("h2", :maximum => "10")
      end
    end

    context "with minimum" do
      it "should be false when content occurs more times than given" do
        @session.should_not have_no_css("h2.head", :minimum => 4) # edge case
        @session.should_not have_no_css("h2", :minimum => 3)
      end

      it "should be true when content occurs fewer times than given" do
        @session.should have_no_css("h2.head", :minimum => 6) # edge case
        @session.should have_no_css("h2", :minimum => 8)
        @session.should have_no_css("p", :minimum => 15)
      end

      it "should be true if the content isn't on the page at all" do
        @session.should have_no_css("abbr", :minimum => 5)
        @session.should have_no_css("p a.doesnotexist", :minimum => 10)
      end

      it "should coerce minimum to an integer" do
        @session.should_not have_no_css("h2.head", :minimum => "4") # edge case
        @session.should_not have_no_css("h2", :minimum => "3")
      end
    end

    context "with text" do
      it "should discard all matches where the given string is not contained" do
        @session.should_not have_no_css("p a", :text => "Redirect", :count => 1)
        @session.should have_no_css("p a", :text => "Doesnotexist")
      end

      it "should discard all matches where the given regexp is not matched" do
        @session.should_not have_no_css("p a", :text => /re[dab]i/i, :count => 1)
        @session.should have_no_css("p a", :text => /Red$/)
      end
    end
  end
end
