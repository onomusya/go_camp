class Site < ApplicationRecord
  has_many :reservations, dependent: :destroy
end
