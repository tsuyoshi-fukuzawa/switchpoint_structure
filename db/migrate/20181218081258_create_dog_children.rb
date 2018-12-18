class CreateDogChildren < ActiveRecord::Migration[5.1]
  def change
    create_table :dog_children do |t|
      t.integer      :dog_parent_id, limit: 8
      t.string       :name
      t.timestamps
    end
    add_index :dog_children, :dog_parent_id
  end
end
