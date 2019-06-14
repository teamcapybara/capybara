# frozen_string_literal: true

module Capybara
  module Node
    module Pluginify
      def self.prepended(mod)
        mod.public_instance_methods.each do |method_name|
          define_method method_name do |*args, **options|
            plugin_names = Array(options.delete(:using) { |_using| session_options.default_plugin[method_name] })
            plugin_names.reduce(false) do |memo, plugin_name|
              plugin = Capybara.plugins[plugin_name]
              raise ArgumentError, "Plugin not loaded: #{plugin_name}" unless plugin
              raise NoMethodError, "Action not implemented in plugin: #{plugin_name}:#{method_name}" unless plugin.respond_to?(method_name)

              memo || plugin.send(method_name, self, *args, **options)
            end || super(*args, **options)
          end
        end
      end
    end
  end
end
