def init
  super
  sections.place(:builtins).before(:subclasses)
end

def builtins
  return if object.path != "Capybara::Selector" # only show built-in selectors for Selector class

  @selectors = Registry.all(:selector)
  return if @selectors.nil? || @selectors.empty?

  @selectors = @selectors.map do |selector|
    [selector.name, selector]
  end

  erb(:selectors)
end