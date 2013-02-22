# Use Capybara integration
require "sauce"

module Sauce
  class Config
    # Sauce doesnt access this from the passed in config for some reason
    # DEFAULT_OPTIONS[:start_local_application] = false
  end
end

require "sauce/capybara"


    
# Set up configuration
Sauce.config do |c|
  # see above
  # c[:start_local_application] = false
  c[:browsers] = [ 
    # ["Windows 8", "Internet Explorer", "10"],             
    # ["Windows 7", "Firefox", "20"],
    # ["OS X 10.8", "Safari", "6"],                         
    ["Linux", "Android", '4.3']          
  ]
end