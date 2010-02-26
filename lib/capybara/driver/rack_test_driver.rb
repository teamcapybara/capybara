require 'rack/test'
require 'mime/types'
require 'nokogiri'
require 'cgi'

class Capybara::Driver::RackTest < Capybara::Driver::Base
  class Node < Capybara::Node
    def text
      node.text
    end

    def [](name)
      attr_name = name.to_s
      case
      when 'select' == tag_name && 'value' == attr_name
        if node['multiple'] == 'multiple'
          node.xpath(".//option[@selected='selected']").map { |option| option.content  }
        else
          option = node.xpath(".//option[@selected='selected']").first || node.xpath(".//option").first
          option.content if option
        end
      when 'input' == tag_name && 'checkbox' == type && 'checked' == attr_name
        node[attr_name] == 'checked' ? true : false
      else
        node[attr_name]
      end
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
      if node['multiple'] != 'multiple'
        node.xpath(".//option[@selected]").each { |node| node.remove_attribute("selected") }
      end

      if option_node = node.xpath(".//option[text()='#{option}']").first ||
                       node.xpath(".//option[contains(.,'#{option}')]").first
        option_node["selected"] = 'selected'
      else
        options = node.xpath(".//option").map { |o| "'#{o.text}'" }.join(', ')
        raise Capybara::OptionNotFound, "No such option '#{option}' in this select box. Available options: #{options}"
      end
    end

    def unselect(option)
      if node['multiple'] != 'multiple'
        raise Capybara::UnselectNotAllowed, "Cannot unselect option '#{option}' from single select box."
      end

      if option_node = node.xpath(".//option[text()='#{option}']").first ||
                       node.xpath(".//option[contains(.,'#{option}')]").first
        option_node.remove_attribute('selected')
      else
        options = node.xpath(".//option").map { |o| "'#{o.text}'" }.join(', ')
        raise Capybara::OptionNotFound, "No such option '#{option}' in this select box. Available options: #{options}"
      end
    end

    def click
      if tag_name == 'a'
        driver.visit(self[:href].to_s)
      elsif (tag_name == 'input' or tag_name == 'button') and %w(submit image).include?(type)
        Form.new(driver, form).submit(self)
      end
    end

    def tag_name
      node.node_name
    end

    def visible?
      node.xpath("./ancestor-or-self::*[contains(@style, 'display:none') or contains(@style, 'display: none')]").size == 0
    end

    def path
      node.path
    end

  private

    def all_unfiltered(locator)
      node.xpath(locator).map { |n| self.class.new(driver, n) }
    end

    def type
      node[:type]
    end

    def form
      node.ancestors('form').first
    end
  end

  class Form < Node
    def params(button)
      params = {}

      text_fields = %w[text hidden password url color tel email search].map{|f| "@type='#{f}'"}.join(' or ')

      node.xpath(".//input[#{text_fields}]").map do |input|
        merge_param!(params, input['name'].to_s, input['value'].to_s)
      end
      node.xpath(".//textarea").map do |textarea|
        merge_param!(params, textarea['name'].to_s, textarea.text.to_s)
      end
      node.xpath(".//input[@type='radio' or @type='checkbox']").map do |input|
        merge_param!(params, input['name'].to_s, input['value'].to_s) if input['checked']
      end
      node.xpath(".//select").map do |select|
        if select['multiple'] == 'multiple'
          options = select.xpath(".//option[@selected]")
          options.each do |option|
            merge_param!(params, select['name'].to_s, (option['value'] || option.text).to_s)
          end
        else
          option = select.xpath(".//option[@selected]").first
          option ||= select.xpath('.//option').first
          merge_param!(params, select['name'].to_s, (option['value'] || option.text).to_s) if option
        end
      end
      node.xpath(".//input[@type='file']").map do |input|
        unless input['value'].to_s.empty?
          if multipart?
            content_type = MIME::Types.type_for(input['value'].to_s).first.to_s
            file = Rack::Test::UploadedFile.new(input['value'].to_s, content_type)
            merge_param!(params, input['name'].to_s, file)
          else
            merge_param!(params, input['name'].to_s, File.basename(input['value'].to_s))
          end
        end
      end
      merge_param!(params, button[:name], button[:value] || "") if button[:name]
      params
    end

    def submit(button)
      driver.submit(method, node['action'].to_s, params(button))
    end

    def multipart?
      self[:enctype] == "multipart/form-data"
    end

  private

    def method
      self[:method] =~ /post/i ? :post : :get
    end

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
  alias_method :source, :body

  def initialize(app)
    @app = app
  end

  def visit(path, attributes = {})
    return if path.gsub(/^#{current_path}/, '') =~ /^#/
    get(path, attributes, env)
    follow_redirects!
    cache_body
  end

  def current_url
    request.url rescue ""
  end

  def response_headers
    response.headers
  end

  def submit(method, path, attributes)
    path = current_path if not path or path.empty?
    send(method, path, attributes, env)
    follow_redirects!
    cache_body
  end

  def find(selector)
    html.xpath(selector).map { |node| Node.new(self, node) }
  end

private

  def build_rack_mock_session # :nodoc:
    Rack::MockSession.new(app, Capybara.default_host)
  end

  def current_path
    request.path rescue ""
  end

  def follow_redirects!
    Capybara::WaitUntil.timeout(4) do
      redirect = response.redirect?
      follow_redirect! if redirect
      not redirect
    end
  rescue Capybara::TimeoutError
    raise Capybara::InfiniteRedirectError, "infinite redirect detected!"
  end

  def env
    env = {}
    begin
      env["HTTP_REFERER"] = request.url
    rescue Rack::Test::Error
      # no request yet
    end
    env
  end

  def cache_body
    @body = response.body
    @html = Nokogiri::HTML(body)
  end

end
