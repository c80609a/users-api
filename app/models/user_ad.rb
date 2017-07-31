#
class UserAd < User

  has_one :companion,
          class_name: 'UserAdCompanion',
          inverse_of: :user_ad,
          dependent: :destroy,
          autosave: true

  delegate :pos,
           :org,
           :pos=,
           :org=,
           to: :lazily_companion

  private

  def lazily_companion
    companion || build_companion
  end

end
