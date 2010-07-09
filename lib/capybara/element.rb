module Capybara
  class Element < Node
    # TODO: maybe we should explicitely delegate?
    def method_missing(*args)
      @base.send(*args)
    end

    def respond_to?(method)
      super || @base.respond_to?(method)
    end
  end
end
