require 'rails_helper'

RSpec.describe ReservationItem, type: :model do
  describe 'バリデーション' do
    it 'reservationとitemが存在すれば有効' do
      reservation_item = build(:reservation_item)
      expect(reservation_item).to be_valid
    end

    it 'reservationがなければ無効' do
      reservation_item = build(:reservation_item, reservation: nil)
      expect(reservation_item).to be_invalid
      expect(reservation_item.errors[:reservation]).to include("must exist")
    end

    it 'itemがなければ無効' do
      reservation_item = build(:reservation_item, item: nil)
      expect(reservation_item).to be_invalid
      expect(reservation_item.errors[:item]).to include("must exist")
    end
  end

  describe 'アソシエーション' do
    it 'reservationに属している' do
      assoc = described_class.reflect_on_association(:reservation)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'itemに属している' do
      assoc = described_class.reflect_on_association(:item)
      expect(assoc.macro).to eq :belongs_to
    end
  end
end