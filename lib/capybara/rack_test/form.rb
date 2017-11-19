# frozen_string_literal: true
class Capybara::RackTest::Form < Capybara::RackTest::Node
  # This only needs to inherit from Rack::Test::UploadedFile because Rack::Test checks for
  # the class specifically when determining whether to construct the request as multipart.
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
    def size; 0; end
    def read; ""; end
  end

  def params(button)
    params = make_params

    form_element_types=[:input, :select, :textarea]
    form_elements_xpath=XPath.generate do |x|
      xpath=x.descendant(*form_element_types).where(~x.attr(:form))
      xpath=xpath.union(x.anywhere(*form_element_types).where(x.attr(:form) == native[:id])) if native[:id]
      xpath.where(~x.attr(:disabled))
    end.to_s

    native.xpath(form_elements_xpath).map do |field|
      case field.name
      when 'input'
        if %w(radio checkbox).include? field['type']
          if field['checked']
            node=Capybara::RackTest::Node.new(self.driver, field)
            merge_param!(params, field['name'].to_s, node.value.to_s)
          end
        elsif %w(submit image).include? field['type']
          # TO DO identify the click button here (in document order, rather
          # than leaving until the end of the params)
        elsif field['type'] =='file'
          if multipart?
            file = \
              if (value = field['value']).to_s.empty?
                NilUploadedFile.new
              else
                mime_info = MiniMime.lookup_by_filename(value)
                Rack::Test::UploadedFile.new(value, (mime_info && mime_info.content_type).to_s)
              end
            merge_param!(params, field['name'].to_s, file)
          else
            merge_param!(params, field['name'].to_s, File.basename(field['value'].to_s))
          end
        else
          merge_param!(params, field['name'].to_s, field['value'].to_s)
        end
      when 'select'
        if field['multiple'] == 'multiple'
          options = field.xpath(".//option[@selected]")
          options.each do |option|
            merge_param!(params, field['name'].to_s, (option['value'] || option.text).to_s)
          end
        else
          option = field.xpath(".//option[@selected]").first
          option ||= field.xpath('.//option').first
          merge_param!(params, field['name'].to_s, (option['value'] || option.text).to_s) if option
        end
      when 'textarea'
        merge_param!(params, field['name'].to_s, field['_capybara_raw_value'].to_s.gsub(/\n/, "\r\n"))
      end
    end
    merge_param!(params, button[:name], button[:value] || "") if button[:name]

    params.to_params_hash
  end

  def submit(button)
    action = (button && button['formaction']) || native['action']
    method = (button && button['formmethod']) || request_method
    driver.submit(method, action.to_s, params(button))
  end

  def multipart?
    self[:enctype] == "multipart/form-data"
  end

private

  class ParamsHash < Hash
    def to_params_hash
      self
    end
  end

  def request_method
    self[:method] =~ /post/i ? :post : :get
  end

  def merge_param!(params, key, value)
    if Rack::Utils.respond_to?(:default_query_parser)
      Rack::Utils.default_query_parser.normalize_params(params, key, value, Rack::Utils.param_depth_limit)
    else
      Rack::Utils.normalize_params(params, key, value)
    end
  end

  def make_params
    if Rack::Utils.respond_to?(:default_query_parser)
      Rack::Utils.default_query_parser.make_params
    else
      ParamsHash.new
    end
  end
end
