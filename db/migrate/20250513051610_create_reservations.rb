class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :site, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, null: false, default: 'pending'
      t.string :payment_status, null: false, default: 'unpaid'
      t.integer :total_price, null: false, default: 0
      t.timestamps
    end
  end
end
