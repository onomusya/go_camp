class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.integer :item_type, null: false, default: 0 # enumでレンタル/販売を管理
      t.integer :price, null: false

      t.timestamps
    end
  end
end
