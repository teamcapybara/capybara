require 'rack/test'
require 'nokogiri'
require 'cgi'

class Capybara::Driver::RackTest
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
      inputs = node.xpath(".//input[@type='text']", ".//input[@type='hidden']", ".//input[@type='password']").map do |input|
        [input['name'].to_s, input['value'].to_s]
      end
      params.concat(inputs)
      inputs = node.xpath(".//textarea").map do |textarea|
        [textarea['name'].to_s, textarea.text.to_s]
      end
      params.concat(inputs)
      inputs = node.xpath(".//input[@type='radio']").map do |input|
        [input['name'].to_s, input['value'].to_s] if input['checked']
      end
      params.concat(inputs)
      inputs = node.xpath(".//input[@type='checkbox']").map do |input|
        [input['name'].to_s, input['value'].to_s] if input['checked']
      end
      params.concat(inputs)
      inputs = node.xpath(".//select").map do |select|
        option = select.xpath(".//option[@selected]").first
        option ||= select.xpath('.//option').first
        option ? [select['name'].to_s, (option['value'] || option.text).to_s] : nil
      end
      params.concat(inputs)
      inputs = node.xpath(".//input[@type='file']").map do |input|
        if input['value'].to_s.any?
          if multipart?
            [input['name'].to_s, Rack::Test::UploadedFile.new(input['value'].to_s)]
          else
            [input['name'].to_s, File.basename(input['value'].to_s)]
          end
        end
      end
      params.concat(inputs)
      params.compact!
      params.push [button[:name], button[:value]] if button[:name]
      if multipart?
        Hash[
          params.map do |key, value|
            [key, value.is_a?(String) ? CGI.escape(value.to_s) : value]
          end
        ]
      else
        params.map { |key, value| "#{key}=#{CGI.escape(value.to_s)}" }.join('&')
      end
    end

    def submit(button)
      if post?
        driver.submit(node['action'].to_s, params(button))
      else
        driver.visit(node['action'].to_s.split('?').first + '?' + params(button))
      end
    end

    def multipart?
      self[:enctype] == "multipart/form-data"
    end
    
    def post?
      self[:method] =~ /post/i
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
