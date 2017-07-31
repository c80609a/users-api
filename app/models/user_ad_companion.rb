#
class UserAdCompanion < ActiveRecord::Base
  # Attributes: pos, org
  belongs_to :user_ad, inverse_of: :companion
  validates :user_ad, presence: true
end