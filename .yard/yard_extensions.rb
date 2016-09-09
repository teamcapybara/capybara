YARD::Templates::Engine.register_template_path Pathname.new('./.yard/templates_custom')

YARD::Tags::Library.define_tag "Locator", :locator
YARD::Tags::Library.define_tag "Filter", :filter, :with_types_and_name

class SelectorObject < YARD::CodeObjects::Base
  def path
    "__Capybara" + sep + super
  end
end

class AddSelectorHandler < YARD::Handlers::Ruby::Base
  handles method_call(:add_selector)
  namespace_only
  process do
    name = statement.parameters.first.jump(:tstring_content, :ident).source
    # object = YARD::CodeObjects::MethodObject.new(namespace, name.to_sym)
    # object = SelectorObject.new(YARD::Registry.resolve(P("Capybara"), "#add_selector", false, true), name.to_sym)
    object = SelectorObject.new(namespace, name)
    register(object)
    parse_block(statement.last.last, :owner => object)

    # modify the object
    object.dynamic = true
  end
end

class AddExpressionFilterHandler < YARD::Handlers::Ruby::Base
  handles method_call(:xpath)
  handles method_call(:css)

  process do
    return unless owner.is_a?(SelectorObject)
    return if statement.parameters.empty?
    # names = statement.parameters.children.map { |p| p.jump(:tstring_content, :ident).source.sub(/^:/, '') }
    names = statement.parameters.children.map &:source
    current_names = owner.tags(:filter).map(&:name)
    (names-current_names).each do |name|
      owner.add_tag(YARD::Tags::Tag.new(:filter, nil, nil, name))
    end
  end
end

class AddFilterHandler < YARD::Handlers::Ruby::Base
  handles method_call(:filter)

  process do
    return unless owner.is_a?(SelectorObject)
    return if statement.parameters.empty?
    name = statement.parameters.first.source
    type = if statement.parameters[1] && statement.parameters[1].source == ':boolean'
      'Boolean'
    else
      nil
    end
    if owner.tags(:filter).none? {|tag| tag.name == name }
      filter_tag = YARD::Tags::Tag.new(:filter, nil, type, name)
      owner.add_tag(filter_tag)
    end
  end
end

class FilterSetHandler < YARD::Handlers::Ruby::Base
  handles method_call(:filter_set)

  process do
    return unless owner.is_a?(SelectorObject)
    return if statement.parameters.empty? || !statement.parameters[1]

    names = statement.parameters[1].flatten.map { |name| ":#{name}" }
    names.each do |name|
      if owner.tags(:filter).none? {|tag| tag.name == name }
        filter_tag = YARD::Tags::Tag.new(:filter, nil, nil, name)
        owner.add_tag(filter_tag)
      end
    end
  end
end
