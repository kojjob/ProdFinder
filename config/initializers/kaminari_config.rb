# frozen_string_literal: true

Kaminari.configure do |config|
  # Number of items per page
  config.default_per_page = 12

  # Maximum number of items per page
  config.max_per_page = 100

  # Number of page links to show on each side of the current page
  config.window = 2

  # Number of page links to show at the beginning and end
  config.outer_window = 1

  # Method name for pagination
  config.page_method_name = :page

  # Parameter name for page number
  config.param_name = :page

  # Don't show params on first page
  config.params_on_first_page = false
end
