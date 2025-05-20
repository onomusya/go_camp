require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'バリデーション' do
    it 'すべての項目が正しければ有効' do
      item = build(:item)
      expect(item).to be_valid
    end

    it '名前がないと無効' do
      item = build(:item, name: nil)
      expect(item).to be_invalid
      expect(item.errors[:name]).to include("can't be blank")
    end

    it '種別（item_type）がないと無効' do
      item = build(:item, item_type: nil)
      expect(item).to be_invalid
      expect(item.errors[:item_type]).to include("can't be blank")
    end

    it '価格がないと無効' do
      item = build(:item, price: nil)
      expect(item).to be_invalid
      expect(item.errors[:price]).to include("can't be blank")
    end

    it '価格が0未満だと無効' do
      item = build(:item, price: -100)
      expect(item).to be_invalid
      expect(item.errors[:price]).to include("must be greater than or equal to 0")
    end

    it '価格が整数でないと無効' do
      item = build(:item, price: 100.5)
      expect(item).to be_invalid
      expect(item.errors[:price]).to include("must be an integer")
    end
  end

  describe 'アソシエーション' do
    it 'reservation_itemsと多対多（has_many）' do
      assoc = described_class.reflect_on_association(:reservation_items)
      expect(assoc.macro).to eq :has_many
    end

    it 'reservationsとthroughで多対多（has_many :through）' do
      assoc = described_class.reflect_on_association(:reservations)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:through]).to eq :reservation_items
    end
  end

  describe 'enum' do
    it 'item_typeがrentalまたはsaleとして定義されている' do
      expect(Item.item_types.keys).to contain_exactly('rental', 'sale')
    end
  end
end