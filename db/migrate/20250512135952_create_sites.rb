class CreateSites < ActiveRecord::Migration[7.1]
  def change
    create_table :sites do |t|
      t.string :name, null: false
      t.integer :capacity, null: false
      t.integer :price, null: false
      t.text :description

      t.timestamps
    end
  end
end
