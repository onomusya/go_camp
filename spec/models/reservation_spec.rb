require 'rails_helper'

RSpec.describe Reservation, type: :model do
  before do
    # PAY.JPの決済処理をモック（本番決済を回避）
    allow(Payjp::Charge).to receive(:create).and_return(true)
  end

  describe 'バリデーション' do
    let(:reservation) { build(:reservation) }

    context '予約できるとき' do
      it 'すべての情報が正しく存在すれば有効' do
        expect(reservation).to be_valid
      end
    end

    context '予約できないとき' do
      it 'start_dateが空では無効' do
        reservation.start_date = nil
        reservation.valid?
        expect(reservation.errors[:start_date]).to include("can't be blank")
      end

      it 'end_dateが空では無効' do
        reservation.end_date = nil
        reservation.valid?
        expect(reservation.errors[:end_date]).to include("can't be blank")
      end

      it 'userが紐づいていなければ無効' do
        reservation.user = nil
        reservation.valid?
        expect(reservation.errors[:user]).to include("must exist")
      end

      it 'siteが紐づいていなければ無効' do
        reservation.site = nil
        reservation.valid?
        expect(reservation.errors[:site]).to include("must exist")
      end
    end
  end

  describe '#calculate_total_price' do
    it '1泊ならsiteのpriceをそのまま設定する' do
      reservation = build(:reservation, start_date: Date.today, end_date: Date.today + 1)
      reservation.calculate_total_price
      expect(reservation.total_price).to eq(reservation.site.price)
    end

    it '2泊ならsiteのprice×2を設定する' do
      reservation = build(:reservation, start_date: Date.today, end_date: Date.today + 2)
      reservation.calculate_total_price
      expect(reservation.total_price).to eq(reservation.site.price * 2)
    end

    it 'start_dateとend_dateが同じ日でも最低1日分の料金がかかる' do
      reservation = build(:reservation, start_date: Date.today, end_date: Date.today)
      reservation.calculate_total_price
      expect(reservation.total_price).to eq(reservation.site.price)
    end
  end
end