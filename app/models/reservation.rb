class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :site
  has_many :reservation_items, dependent: :destroy
  has_many :items, through: :reservation_items

  validate :no_overlap_with_existing_reservations

  def calculate_total_price
    return unless site && start_date && end_date
    num_days = [(end_date - start_date).to_i, 1].max
    self.total_price = site.price * num_days
  end

  private

  def no_overlap_with_existing_reservations
    return if start_date.blank? || end_date.blank? || site.blank?

    overlapping = Reservation
                    .where(site_id: site_id)
                    .where.not(id: id) # 編集時は自分自身を除外
                    .where('start_date < ? AND end_date > ?', end_date, start_date)

    if overlapping.exists?
      errors.add(:base, '選択した期間にはすでに予約が入っています。別の日付を選択してください。')
    end
  end

end
