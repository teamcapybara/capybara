require 'rack/test'
require 'rack/utils'
require 'mime/types'
require 'nokogiri'
require 'cgi'

class Capybara::Driver::RackTest < Capybara::Driver::Base
  class Node < Capybara::Driver::Node
    def text
      native.text
    end

    def [](name)
      string_node[name]
    end

    def value
      string_node.value
    end

    def set(value)
      if tag_name == 'input' and type == 'radio'
        other_radios_xpath = XPath.generate { |x| x.anywhere(:input)[x.attr(:name).equals(self[:name])] }.to_s
        driver.html.xpath(other_radios_xpath).each { |node| node.remove_attribute("checked") }
        native['checked'] = 'checked'
      elsif tag_name == 'input' and type == 'checkbox'
        if value && !native['checked']
          native['checked'] = 'checked'
        elsif !value && native['checked']
          native.remove_attribute('checked')
        end
      elsif tag_name == 'input'
        native['value'] = value.to_s
      elsif tag_name == "textarea"
        native.content = value.to_s
      end
    end

    def select_option
      if select_node['multiple'] != 'multiple'
        select_node.find(".//option[@selected]").each { |node| node.native.remove_attribute("selected") }
      end
      native["selected"] = 'selected'
    end

    def unselect_option
      if select_node['multiple'] != 'multiple'
        raise Capybara::UnselectNotAllowed, "Cannot unselect option from single select box."
      end
      native.remove_attribute('selected')
    end

    def click
      if tag_name == 'a'
        method = self["data-method"] || :get
        driver.process(method, self[:href].to_s)
      elsif (tag_name == 'input' and %w(submit image).include?(type)) or
          ((tag_name == 'button') and type.nil? or type == "submit")
        Form.new(driver, form).submit(self)
      end
    end

    def tag_name
      native.node_name
    end

    def visible?
      string_node.visible?
    end

    def path
      native.path
    end

    def find(locator)
      native.xpath(locator).map { |n| self.class.new(driver, n) }
    end

  private

    def string_node
      @string_node ||= Capybara::Node::Simple.new(native)
    end

    # a reference to the select node if this is an option node
    def select_node
      find('./ancestor::select').first
    end

    def type
      native[:type]
    end

    def form
      native.ancestors('form').first
    end
  end

  class Form < Node
    # This only needs to inherit from Rack::Test::UploadedFile because Rack::Test checks for
    # the class specifically when determing whether to consturct the request as multipart.
    # That check should be based solely on the form element's 'enctype' attribute value,
    # which should probably be provided to Rack::Test in its non-GET request methods.
    class NilUploadedFile < Rack::Test::UploadedFile
      def initialize
        @empty_file = Tempfile.new("nil_uploaded_file")
        @empty_file.close
      end

      def original_filename; ""; end
      def content_type; "application/octet-stream"; end
      def path; @empty_file.path; end
    end

    def params(button)
      params = {}

      native.xpath(".//input[not(@disabled) and (not(@type) or (@type!='radio' and @type!='file' and @type!='checkbox' and @type!='submit' and @type!='image'))]").map do |input|
        merge_param!(params, input['name'].to_s, input['value'].to_s)
      end
      native.xpath(".//textarea[not(@disabled)]").map do |textarea|
        merge_param!(params, textarea['name'].to_s, textarea.text.to_s)
      end
      native.xpath(".//input[not(@disabled) and (@type='radio' or @type='checkbox')]").map do |input|
        merge_param!(params, input['name'].to_s, input['value'].to_s) if input['checked']
      end
      native.xpath(".//select[not(@disabled)]").map do |select|
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
      native.xpath(".//input[not(@disabled) and @type='file']").map do |input|
        if multipart?
          file = \
            if (value = input['value']).to_s.empty?
              NilUploadedFile.new
            else
              content_type = MIME::Types.type_for(value).first.to_s
              Rack::Test::UploadedFile.new(value, content_type)
            end
          merge_param!(params, input['name'].to_s, file)
        else
          merge_param!(params, input['name'].to_s, File.basename(input['value'].to_s))
        end
      end
      merge_param!(params, button[:name], button[:value] || "") if button[:name]
      params
    end

    def submit(button)
      driver.submit(method, native['action'].to_s, params(button))
    end

    def multipart?
      self[:enctype] == "multipart/form-data"
    end

  private

    def method
      self[:method] =~ /post/i ? :post : :get
    end

    def merge_param!(params, key, value)
      Rack::Utils.normalize_params(params, key, value)
    end
  end

  include ::Rack::Test::Methods
  attr_reader :app

  alias_method :response, :last_response
  alias_method :request, :last_request

  def initialize(app)
    raise ArgumentError, "rack-test requires a rack application, but none was given" unless app
    @app = app
  end

  def visit(path, attributes = {})
    process(:get, path, attributes)
  end

  def process(method, path, attributes = {})
    return if path.gsub(/^#{request_path}/, '') =~ /^#/
    path = request_path + path if path =~ /^\?/
    path = Capybara.app_host + path if Capybara.app_host and path.start_with?('/')
    send(method, to_binary(path), to_binary( attributes ), env)
    follow_redirects!
  end

  def current_url
    request.url rescue ""
  end

  def response_headers
    response.headers
  end

  def status_code
    response.status
  end

  def to_binary(object)
    return object unless Kernel.const_defined?(:Encoding)

    if object.respond_to?(:force_encoding)
      object.dup.force_encoding(Encoding::ASCII_8BIT)
    elsif object.respond_to?(:each_pair) #Hash
      {}.tap { |x| object.each_pair {|k,v| x[to_binary(k)] = to_binary(v) } }
    elsif object.respond_to?(:each) #Array
      object.map{|x| to_binary(x)}
    else
      object
    end
  end

  def submit(method, path, attributes)
    path = request_path if not path or path.empty?
    send(method, to_binary(path), to_binary(attributes), env)
    follow_redirects!
  end

  def find(selector)
    html.xpath(selector).map { |node| Node.new(self, node) }
  end

  def body
    @body ||= response.body
  end

  def html
    @html ||= Nokogiri::HTML(body)
  end
  alias_method :source, :body

  def reset!
    clear_cookies
  end

  def get(*args, &block); reset_cache; super; end
  def post(*args, &block); reset_cache; super; end
  def put(*args, &block); reset_cache; super; end
  def delete(*args, &block); reset_cache; super; end

  def follow_redirects!
    5.times do
      follow_redirect! if response.redirect?
    end
    raise Capybara::InfiniteRedirectError, "redirected more than 5 times, check for infinite redirects." if response.redirect?
  end

private

  def reset_cache
    @body = nil
    @html = nil
  end

  def build_rack_mock_session # :nodoc:
    Rack::MockSession.new(app, Capybara.default_host || "www.example.com")
  end

  def request_path
    request.path rescue ""
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

end
