class CreateCatParents < ActiveRecord::Migration[5.1]
  def change
    create_table :cat_parents do |t|
      t.string       :name
      t.timestamps
    end
  end
end
