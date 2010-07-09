require 'forwardable'
require 'capybara/timeout'

module Capybara
  class Session
    extend Forwardable

    DSL_METHODS = [
      :all, :attach_file, :body, :check, :choose, :click, :click_button, :click_link, :current_url, :drag, :evaluate_script,
      :field_labeled, :fill_in, :find, :find_button, :find_by_id, :find_field, :find_link, :has_content?, :has_css?,
      :has_no_content?, :has_no_css?, :has_no_xpath?, :has_xpath?, :locate, :save_and_open_page, :select, :source, :uncheck,
      :visit, :wait_until, :within, :within_fieldset, :within_table, :within_frame, :has_link?, :has_no_link?, :has_button?,
      :has_no_button?,    :has_field?, :has_no_field?, :has_checked_field?, :has_unchecked_field?, :has_no_table?, :has_table?,
      :unselect, :has_select?, :has_no_select?, :current_path, :scope_to
    ]

    attr_reader :mode, :app

    def initialize(mode, app=nil)
      @mode = mode
      @app = app
    end

    def driver
      @driver ||= begin                    
        string = mode.to_s
        string.gsub!(%r{(^.)|(_.)}) { |m| m[m.length-1,1].upcase }
        Capybara::Driver.const_get(string.to_sym).new(app)
      rescue NameError
        raise Capybara::DriverNotFoundError, "no driver called #{mode} was found"
      end
    end

    def_delegator :driver, :cleanup!
    def_delegator :driver, :current_url
    def_delegator :driver, :current_path
    def_delegator :driver, :response_headers
    def_delegator :driver, :status_code
    def_delegator :driver, :visit
    def_delegator :driver, :body
    def_delegator :driver, :source

    def document
      Capybara::Document.new(self)
    end

    def method_missing(*args)
      current_node.send(*args)
    end

    def respond_to?(method)
      super || current_node.respond_to?(method)
    end

    def within(kind, scope=nil)
      new_scope = locate(kind, scope, "scope '#{scope || kind}' not found on page")
      begin
        scopes.push(new_scope)
        yield
      ensure
        scopes.pop
      end
    end

    def within_fieldset(locator)
      within :xpath, XPath.fieldset(locator) do
        yield
      end
    end

    def within_table(locator)
      within :xpath, XPath.table(locator) do
        yield
      end
    end

    def within_frame(frame_id)
      driver.within_frame(frame_id) do
        yield
      end
    end

  private

    def current_node
      scopes.last
    end

    def scopes
      @scopes ||= [document]
    end
  end
end
