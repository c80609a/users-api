class User < ActiveRecord::Base
  validates :title, presence: true
  validates :email,
            presence: true,
            format: { with: /\A([a-z0-9_.-]+)@([a-z0-9-]+)\.[a-z.]+\z/}
  validates :phone,
            presence: true,
            format: { with: /\A((8|\+7)?[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}\z/ }
end
