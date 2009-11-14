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

    def set(value)
      if tag_name == 'input' and %w(text password hidden file).include?(type)
        node['value'] = value.to_s
      elsif tag_name == 'input' and type == 'radio'
        session.html.xpath("//input[@name='#{self[:name]}']").each { |node| node.remove_attribute("checked") }
        node['checked'] = 'checked'
      elsif tag_name == 'input' and type == 'checkbox'
        if value
          node['checked'] = 'checked'
        else
          node.remove_attribute('checked')
        end
      elsif tag_name == "textarea"
        node.content = value.to_s
      end
    end
    
    def select(option)
      node.xpath(".//option").each { |node| node.remove_attribute("selected") }
      node.xpath(".//option[contains(.,'#{option}')]").first["selected"] = 'selected'
    end

    def click
      if tag_name == 'a'
        session.visit(self[:href])
      elsif tag_name == 'input' and %w(submit image).include?(type)
        Form.new(session, form).submit(self)
      end
    end
    
    def tag_name
      node.node_name
    end

  private
  
    def type
      self[:type]
    end

    def form
      node.ancestors('form').first
    end
  end

  class Form < Node
    def params(button)
      params = []
      params += node.xpath(".//input[@type='text']", ".//input[@type='hidden']", ".//input[@type='password']").inject([]) do |agg, input|
        agg << [input['name'].to_s, input['value'].to_s]
        agg
      end
      params += node.xpath(".//textarea").inject([]) do |agg, textarea|
        agg << [textarea['name'].to_s, textarea.text.to_s]
        agg
      end
      params += node.xpath(".//input[@type='radio']").inject([]) do |agg, input|
        agg << [input['name'].to_s, input['value'].to_s] if input['checked']
        agg
      end
      params += node.xpath(".//input[@type='checkbox']").inject([]) do |agg, input|
        agg << [input['name'].to_s, input['value'].to_s] if input['checked']
        agg
      end
      params += node.xpath(".//select").inject([]) do |agg, select|
        option = select.xpath(".//option[@selected]").first
        option ||= select.xpath('.//option').first
        agg << [select['name'].to_s, (option['value'] || option.text).to_s] if option 
        agg
      end
      params += node.xpath(".//input[@type='file']").inject([]) do |agg, input|
        if multipart?
          agg << [input['name'].to_s, Rack::Test::UploadedFile.new(input['value'].to_s)]
        else
          agg << [input['name'].to_s, File.basename(input['value'].to_s)]
        end
        agg
      end
      params.push [button[:name], button[:value]] if button[:name]
      if multipart?
        params.inject({}) { |agg, (key, value)| agg[key] = value; agg }
      else
        params.map { |key, value| "#{key}=#{value}" }.join('&')
      end
    end

    def submit(button)
      session.submit(node['action'].to_s, params(button)) 
    end

    def multipart?
      self[:enctype] == "multipart/form-data"
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
    follow_redirect! while response.redirect?
    cache_body
  end

  def submit(path, attributes)
    post(path, attributes)
    follow_redirect! while response.redirect?
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
