# frozen_string_literal: true

class AddStatusToTopics < ActiveRecord::Migration[8.1]
  def change
    add_column :topics, :status, :integer, default: 0, null: false
  end
end
