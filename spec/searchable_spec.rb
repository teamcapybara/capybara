require File.expand_path('spec_helper', File.dirname(__FILE__))

module Capybara

  describe Searchable do
    class Klass
      include Searchable    

      def all_unfiltered(locator, options = {})
        []
      end  

    end
  
    describe "#all" do
      before do
        @searchable = Klass.new 
      end

      it "should return unfiltered list without options" do
        node1 = stub(Node)
        node2 = stub(Node)
        @searchable.should_receive(:all_unfiltered).with('//x').and_return([node1, node2])
        @searchable.all('//x').should == [node1, node2]
      end
      
      context "with :text filter" do
        before do
          @node1 = stub(Node, :text => 'node one text')
          @node2 = stub(Node, :text => 'node two text')      
          @searchable.stub(:all_unfiltered).and_return([@node1, @node2])
        end
        
        it "should accept regular expression" do
          @searchable.all('//x', :text => /node one/).should == [@node1]
          @searchable.all('//x', :text => /node two/).should == [@node2]
        end
        
        it "should accept text" do
          @searchable.all('//x', :text => "node one").should == [@node1]
          @searchable.all('//x', :text => "node two").should == [@node2]
        end   
      end
      
      context "with :visible filter" do
        before do
          @visible_node = stub(Node, :visible? => true)
          @hidden_node = stub(Node, :visible? => false)     
          @searchable.stub(:all_unfiltered).and_return([@visible_node, @hidden_node])
        end
        
        it "should filter out hidden nodes" do
          @searchable.all('//x', :visible => true).should == [@visible_node]
        end
      
      end

    end #all
    
    describe "#has_xpath?" do
      def new_node(values = {})
        stub(Node, values)
      end
      
      before do
        @searchable = Klass.new 
      end
      
      it "should start with unfiltered matches for locator" do
        @searchable.should_receive(:all_unfiltered).with('//x').and_return([])
        @searchable.has_xpath?('//x')
      end
      
      it "should be true if the given selector is on the page" do        
        @searchable.stub(:all_unfiltered).and_return([new_node])
        @searchable.should have_xpath("//x")      
      end

      it "should be false if the given selector is not on the page" do
        @searchable.should_receive(:all_unfiltered).and_return([])
        @searchable.should_not have_xpath("//abbr")
      end

      context "with count" do
        
        it "should be true if the content is on the page the given number of times" do
          @searchable.stub(:all_unfiltered).and_return([new_node, new_node])
          @searchable.should have_xpath("//x", :count => 2)
        end

        it "should be false if the content is not on the page the given number of times" do
          @searchable.stub(:all_unfiltered).and_return([new_node, new_node])
          @searchable.should_not have_xpath("//x", :count => 6)
        end

        it "should be false if the content isn't on the page at all" do
          @searchable.stub(:all_unfiltered).and_return([])
          @searchable.should_not have_xpath("//x", :count => 2)
          @searchable.should_not have_xpath("//x", :count => 1)
        end
      end

      context "with text" do
        before do
          @searchable.stub(:all_unfiltered).and_return([new_node(:text => "node one"), new_node(:text => 'node two')])
        end

        it "should discard all matches where the given string is not contained" do          
          @searchable.should have_xpath("//x", :text => "node one", :count => 1)
          @searchable.should have_xpath('//x', :text => 'node two', :count => 1)
          @searchable.should have_xpath('//x', :text => 'node', :count => 2)
          @searchable.should_not have_xpath("//x", :text => "Doesnotexist")
        end

        it "should discard all matches where the given regexp is not matched" do
          @searchable.should have_xpath("//x", :text => /Node\sone/i, :count => 1)
          @searchable.should_not have_xpath("//x", :text => /Nope$/)
        end
      end
      
      context "with visible" do
        before do
          node1_visible = new_node(:text => "node one", :visible? => true)
          node2_hidden = new_node(:text => "node two", :visible? => false)
          @searchable.stub(:all_unfiltered).and_return([node1_visible, node2_hidden])
        end
        
        it "should discard hidden matches" do
          @searchable.should have_xpath('//x', :visible => true, :count => 1)
        end
      end
      
    end #has_xpath?

  end

end