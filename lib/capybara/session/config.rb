# frozen_string_literal: true
require 'delegate'

module Capybara
  class SessionConfig
    OPTIONS = [:always_include_port, :run_server, :default_selector, :default_max_wait_time, :ignore_hidden_elements,
               :automatic_reload, :match, :exact, :exact_text, :raise_server_errors, :visible_text_only, :wait_on_first_by_default,
               :automatic_label_click, :enable_aria_label, :save_path, :exact_options, :asset_host, :default_host, :app_host,
               :save_and_open_page_path, :server_host, :server_port, :server_errors]

    attr_accessor(*OPTIONS)

    ##
    #@!method always_include_port
    #  See {Capybara.configure}
    #@!method run_server
    #  See {Capybara.configure}
    #@!method default_selector
    #  See {Capybara.configure}
    #@!method default_max_wait_time
    #  See {Capybara.configure}
    #@!method ignore_hidden_elements
    #  See {Capybara.configure}
    #@!method automatic_reload
    #  See {Capybara.configure}
    #@!method match
    #  See {Capybara.configure}
    #@!method exact
    #  See {Capybara.configure}
    #@!method raise_server_errors
    #  See {Capybara.configure}
    #@!method visible_text_only
    #  See {Capybara.configure}
    #@!method wait_on_first_by_default
    #  See {Capybara.configure}
    #@!method automatic_label_click
    #  See {Capybara.configure}
    #@!method enable_aria_label
    #  See {Capybara.configure}
    #@!method save_path
    #  See {Capybara.configure}
    #@deprecated
    #@!method exact_options
    #  See {Capybara.configure}
    #@!method asset_host
    #  See {Capybara.configure}
    #@!method default_host
    #  See {Capybara.configure}
    #@!method app_host
    #  See {Capybara.configure}
    #@!method save_and_open_page_path
    #  See {Capybara.configure}
    #@!method server_host
    #  See {Capybara.configure}
    #@!method server_port
    #  See {Capybara.configure}
    #@!method server_errors
    #  See {Capybara.configure}

    remove_method :server_host

    ##
    #
    # @return [String]    The IP address bound by default server
    #
    def server_host
      @server_host || '127.0.0.1'
    end

    remove_method :server_errors=
    def server_errors=(errors)
      (@server_errors ||= []).replace(errors.dup)
    end

    remove_method :app_host=
    def app_host=(url)
      raise ArgumentError.new("Capybara.app_host should be set to a url (http://www.example.com)") unless url.nil? || (url =~ URI::Parser.new.make_regexp)
      @app_host = url
    end

    remove_method :default_host=
    def default_host=(url)
      raise ArgumentError.new("Capybara.default_host should be set to a url (http://www.example.com)") unless url.nil? || (url =~ URI::Parser.new.make_regexp)
      @default_host = url
    end

    remove_method :save_and_open_page_path=
    def save_and_open_page_path=(path)
      warn "DEPRECATED: #save_and_open_page_path is deprecated, please use #save_path instead. \n"\
           "Note: Behavior is slightly different with relative paths - see documentation" unless path.nil?
      @save_and_open_page_path = path
    end

    remove_method :exact_options=
    def exact_options=(opt)
      @exact_options = opt
      warn "DEPRECATED: #exact_options is deprecated, please scope your findes/actions and use the `:exact` "\
           "option if similar functionality is needed."
    end

    def initialize_copy(other)
      super
      @server_errors = @server_errors.dup
    end
  end

  class ReadOnlySessionConfig < SimpleDelegator
    SessionConfig::OPTIONS.each do |m|
      define_method "#{m}=" do |val|
        raise "Per session settings are only supported when Capybara.threadsafe == true"
      end
    end
  end
end