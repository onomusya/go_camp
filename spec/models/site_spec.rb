require 'rails_helper'

RSpec.describe Site, type: :model do
  describe 'バリデーション' do
    it '有効なデータの場合は有効' do
      site = build(:site)
      expect(site).to be_valid
    end

    it '名前がないと無効' do
      site = build(:site, name: nil)
      expect(site).to be_invalid
      expect(site.errors[:name]).to include("can't be blank")
    end

    it '価格がないと無効' do
      site = build(:site, price: nil)
      expect(site).to be_invalid
      expect(site.errors[:price]).to include("can't be blank")
    end

    it '価格が0未満だと無効' do
      site = build(:site, price: -1)
      expect(site).to be_invalid
      expect(site.errors[:price]).to include("must be greater than or equal to 0")
    end

    it '定員がないと無効' do
      site = build(:site, capacity: nil)
      expect(site).to be_invalid
      expect(site.errors[:capacity]).to include("can't be blank")
    end

    it '定員が1未満だと無効' do
      site = build(:site, capacity: 0)
      expect(site).to be_invalid
      expect(site.errors[:capacity]).to include("must be greater than or equal to 1")
    end
  end

  describe 'アソシエーション' do
    it '予約を複数持てる（has_many）' do
      assoc = described_class.reflect_on_association(:reservations)
      expect(assoc.macro).to eq :has_many
    end
  end
end