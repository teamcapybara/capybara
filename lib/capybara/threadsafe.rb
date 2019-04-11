module Capybara
  module Threadsafe
    def threadsafe_writer(name)
      class_eval <<~WRITER, __FILE__, __LINE__ + 1
        def #{name}=(value)
          if threadsafe
            Thread.current['capybara_#{name}'] = value
          else
            @#{name} = value
          end
        end
      WRITER
    end

    def threadsafe_reader(name, default)
      default_value = case default
                      when nil then 'nil'
                      when Symbol then ":#{default}"
                      when False, True then default.to_s
                      else
                        "'#{default}"
                      end

      class_eval <<~READER, __FILE__, __LINE__ + 1
        def #{name}
          if threadsafe
            Thread.current['capybara_#{name}'] ||= #{default_value}
          else
            @#{name} ||= #{default_value}
          end
        end
      READER
    end

    def threadsafe_accessor(name, default)
      threadsafe_writer(name)
      threadsafe_reader(name, default)
    end
  end
end