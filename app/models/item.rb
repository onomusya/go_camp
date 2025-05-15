class Item < ApplicationRecord
  enum item_type: { rental: 0, sale: 1 }

  validates :name, :item_type, :price, presence: true
end
