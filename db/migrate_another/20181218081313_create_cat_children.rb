class CreateCatChildren < ActiveRecord::Migration[5.1]
  def change
    create_table :cat_children do |t|
      t.integer      :cat_parent_id, limit: 8
      t.string       :name
      t.timestamps
    end
    add_index :cat_children, :cat_parent_id
  end
end
