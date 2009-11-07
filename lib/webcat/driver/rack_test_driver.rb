require 'rack/test'
require 'nokogiri'

class Webcat::Driver::RackTest
  class Node < Struct.new(:session, :node)
    def text
      node.text
    end
    
    def [](name)
      value = node[name.to_s]
      return value.to_s if value
    end

    def value
      node['value'].to_s
    end

    def value=(value)
      node['value'] = value.to_s
    end

    def click
      session.visit(self[:href])
    end
    
    def tag_name
      node.node_name
    end
  end
  
  include ::Rack::Test::Methods
  attr_reader :app, :html, :body

  alias_method :response, :last_response
  alias_method :request, :last_request
  
  def initialize(app)
    @app = app
  end
  
  def visit(path)
    get(path)
    @body = response.body
    @html = Nokogiri::HTML(body)
  end
  
  def find(selector)
    html.xpath(selector).map { |node| Node.new(self, node) }
  end

end
