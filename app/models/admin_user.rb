class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :validatable

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "id","updated_at"]
  end
end
