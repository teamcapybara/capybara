module ClickElementSpec
  shared_examples_for "click_element" do
    describe '#click_element' do
      it "should click on a element" do
        @session.visit('/with_js')
        @session.click_element('fool_to_cry')
        @session.body.should include('<div id="fool_to_cry">daddy your a fool to cry</div>')
      end
    end  
  end
end  