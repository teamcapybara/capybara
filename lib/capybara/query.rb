# frozen_string_literal: true
require 'capybara/queries/selector_query'
module Capybara
  # @deprecated This class and its methods are not supposed to be used by users of Capybara's public API.
  #   It may be removed in future versions of Capybara.
  Query = Queries::SelectorQuery
end
