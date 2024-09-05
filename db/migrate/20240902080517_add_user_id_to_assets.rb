class AddUserIdToAssets < ActiveRecord::Migration[7.2]
  def change
    add_reference :assets, :user, null: false, foreign_key: true
  end
end
