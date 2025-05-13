class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :site

  validates :start_date, presence: true
  validates :end_date, presence: true

  def calculate_total_price
    return unless site && start_date && end_date
    num_days = [(end_date - start_date).to_i, 1].max
    self.total_price = site.price * num_days
  end

end
