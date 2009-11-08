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
      if tag_name == 'a'
        session.visit(self[:href])
      elsif tag_name == 'input' and self[:type] == 'submit'
        form = node.ancestors('form').first
        attributes = form.xpath('//input').inject({}) do |agg, node|
          agg[node['name'].to_s] = node['value'].to_s
          agg
        end
        session.submit(form['action'].to_s, attributes) 
      end
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
    cache_body
  end

  def submit(path, attributes)
    post(path, attributes)
    cache_body  
  end
  
  def find(selector)
    html.xpath(selector).map { |node| Node.new(self, node) }
  end

  private

  def cache_body
    @body = response.body
    @html = Nokogiri::HTML(body)
  end

end
