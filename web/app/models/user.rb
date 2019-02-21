class User < ApplicationRecord
  before_create :create_token
  before_create :create_player
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :player

  private
  def create_token
    self.token = rand(36**32).to_s(36)
  end

  def create_player
    Player.new(user_id: self.id, rank: 1, exp: 0)
  end
end
