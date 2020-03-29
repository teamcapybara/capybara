# frozen_string_literal: true

module ActionPauser
  def initialize(mouse, keyboard)
    super
    @devices[:pauser] = Pauser.new
  end

  def pause(duration)
    @actions << [:pauser, :pause, [duration]]
    self
  end

  class Pauser
    def pause(duration)
      sleep duration
    end
  end

  private_constant :Pauser
end

::Selenium::WebDriver::ActionBuilder.prepend ActionPauser if defined? ::Selenium::WebDriver::ActionBuilder
