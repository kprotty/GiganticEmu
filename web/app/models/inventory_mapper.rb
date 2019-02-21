class InventoryMapper < ApplicationRecord
  belongs_to :player
  belongs_to :inventory
end
