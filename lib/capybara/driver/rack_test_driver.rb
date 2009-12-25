require 'rack/test'
require 'nokogiri'
require 'cgi'

class Capybara::Driver::RackTest < Capybara::Driver::Base
  class Node < Capybara::Node
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
        driver.html.xpath("//input[@name='#{self[:name]}']").each { |node| node.remove_attribute("checked") }
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
        driver.visit(self[:href])
      elsif (tag_name == 'input' or tag_name == 'button') and %w(submit image).include?(type)
        Form.new(driver, form).submit(self)
      end
    end
    
    def tag_name
      node.node_name
    end
    
    def visible?
      node.xpath("./ancestor-or-self::*[contains(@style, 'display:none')]").size == 0
    end
    
    def path
      node.path
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
      params = {}
      node.xpath(".//input[@type='text' or @type='hidden' or @type='password']").map do |input|
        merge_param!(params, input['name'].to_s, input['value'].to_s)
      end
      node.xpath(".//textarea").map do |textarea|
        merge_param!(params, textarea['name'].to_s, textarea.text.to_s)
      end
      node.xpath(".//input[@type='radio' or @type='checkbox']").map do |input|
        merge_param!(params, input['name'].to_s, input['value'].to_s) if input['checked']
      end
      node.xpath(".//select").map do |select|
        option = select.xpath(".//option[@selected]").first
        option ||= select.xpath('.//option').first
        merge_param!(params, select['name'].to_s, (option['value'] || option.text).to_s) if option
      end
      node.xpath(".//input[@type='file']").map do |input|
        unless input['value'].to_s.empty?
          if multipart?
            merge_param!(params, input['name'].to_s, Rack::Test::UploadedFile.new(input['value'].to_s))
          else
            merge_param!(params, input['name'].to_s, File.basename(input['value'].to_s))
          end
        end
      end
      merge_param!(params, button[:name], button[:value]) if button[:name]
      params
    end

    def submit(button)
      if post?
        driver.submit(node['action'].to_s, params(button))
      else
        driver.visit(node['action'].to_s, params(button))
      end
    end

    def multipart?
      self[:enctype] == "multipart/form-data"
    end
    
    def post?
      self[:method] =~ /post/i
    end
    
    private
    
    def merge_param!(params, key, value)
      collection = key.sub!(/\[\]$/, '')
      if collection
        if params[key]
          params[key] << value
        else
          params[key] = [value]
        end
      else
        params[key] = value
      end
    end
  end
  
  include ::Rack::Test::Methods
  attr_reader :app, :html, :body

  alias_method :response, :last_response
  alias_method :request, :last_request
  
  def initialize(app)
    @app = app
  end
  
  def visit(path, attributes = {})
    get(path, attributes)
    follow_redirect! while response.redirect?
    cache_body
  end

  def current_url
    request.url
  end
  
  def response_headers
    response.headers
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
