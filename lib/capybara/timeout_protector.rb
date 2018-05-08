module Capybara
  module TimeoutProtector
    def protect_from_timeout(*method_names)
      timeout_protector = Module.new do
        method_names.each do |method|
          define_method method do |*args, &block|
            Thread.handle_interrupt(Timeout::Error => :never) do
              super(*args, &block)
            end
          end
        end
      end
      prepend timeout_protector
    end
  end
end
