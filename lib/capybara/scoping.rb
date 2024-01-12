# frozen_string_literal: true

module Capybara
  module Scoping
    ##
    #
    # Executes the given block within the context of a node. {#within} takes the
    # same options as {Capybara::Node::Finders#find #find}, as well as a block. For the duration of the
    # block, any command to Capybara will be handled as though it were scoped
    # to the given element.
    #
    #     within(:xpath, './/div[@id="delivery-address"]') do
    #       fill_in('Street', with: '12 Main Street')
    #     end
    #
    # Just as with `#find`, if multiple elements match the selector given to
    # {#within}, an error will be raised, and just as with `#find`, this
    # behaviour can be controlled through the `:match` and `:exact` options.
    #
    # It is possible to omit the first parameter, in that case, the selector is
    # assumed to be of the type set in {Capybara.configure default_selector}.
    #
    #     within('div#delivery-address') do
    #       fill_in('Street', with: '12 Main Street')
    #     end
    #
    # @overload within(*find_args)
    #   @param (see Capybara::Node::Finders#all)
    #
    # @overload within(a_node)
    #   @param [Capybara::Node::Base] a_node   The node in whose scope the block should be evaluated
    #
    # @raise  [Capybara::ElementNotFound]      If the scope can't be found before time expires
    #
    def within(*args, **kw_args)
      new_scope = args.first.respond_to?(:to_capybara_node) ? args.first.to_capybara_node : current_scope.find(*args, **kw_args)
      begin
        scopes.push(new_scope)
        yield new_scope if block_given?
      ensure
        scopes.pop
      end
    end
    alias_method :within_element, :within

    ##
    #
    # Execute the given block within the a specific fieldset given the id or legend of that fieldset.
    #
    # @param [String] locator    Id or legend of the fieldset
    #
    def within_fieldset(locator, &block)
      within(:fieldset, locator, &block)
    end

    ##
    #
    # Execute the given block within the a specific table given the id or caption of that table.
    #
    # @param [String] locator    Id or caption of the table
    #
    def within_table(locator, &block)
      within(:table, locator, &block)
    end

    def root_capybara_scope
      raise NotImplementedError
    end

    def current_scope
      scope = scopes.last
      [nil, :frame].include?(scope) ? root_scope : scope
    end

  private

    def scopes
      @scopes ||= [nil]
    end
  end
end
