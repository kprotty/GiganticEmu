class BadgeMapper < ApplicationRecord
  belongs_to :player
  belongs_to :inventory
end
