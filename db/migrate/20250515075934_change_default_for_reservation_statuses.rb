class ChangeDefaultForReservationStatuses < ActiveRecord::Migration[7.1]
  def change
    change_column_default :reservations, :status, from: 'pending', to: 'reserved'
    change_column_default :reservations, :payment_status, from: 'unpaid', to: 'paid'
  end
end
