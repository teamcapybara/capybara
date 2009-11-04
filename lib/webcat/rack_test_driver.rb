require 'rack/test'
require 'nokogiri'

class Webcat::Driver::RackTest
  class Node < Struct.new(:session, :node)
    def text
      node.text
    end
    
    def attribute(name)
      value = node.attributes[name.to_s]
      return value.to_s if value
    end
    
    def click
      session.visit(attribute(:href))
    end
  end
  
  include ::Rack::Test::Methods
  attr_reader :app

  alias_method :response, :last_response
  alias_method :request, :last_request
  
  def initialize(app)
    @app = app
  end
  
  def visit(path)
    get(path)
  end
  
  def body
    response.body
  end
  
  def find(selector)
    html.xpath(selector).map { |node| Node.new(self, node) }
  end
  
private

  def html
    Nokogiri::HTML(body)
  end
end