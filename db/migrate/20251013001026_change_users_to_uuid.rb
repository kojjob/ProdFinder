# frozen_string_literal: true

# Note: This migration is complex due to existing data and foreign key constraints.
# For now, we'll leave the users table as integer ID and ensure consistency in future tables.
# This can be addressed later with a more comprehensive migration strategy.

class ChangeUsersToUuid < ActiveRecord::Migration[8.1]
  def up
    # Skip this migration for now - users table will remain with integer ID
    # Future tables should use UUID for consistency
    say "Skipping users UUID conversion - will be addressed in future migration"
  end

  def down
    # No changes needed
  end
end
