class Player < ApplicationRecord
  belongs_to :user
  has_one :inventoryMapper
  has_one :BadgeMapper
end
