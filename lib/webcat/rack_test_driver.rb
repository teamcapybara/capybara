require 'rack/test'

class Webcat::Driver::RackTest
  include ::Rack::Test::Methods
  attr_reader :app

  alias_method :response, :last_response
  alias_method :request, :last_request
  
  def initialize(app)
    @app = app
  end
  
  def body
    response.body
  end
end