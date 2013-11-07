class User < ActiveRecord::Base
  # Remember to create a migration!
  has_many :albums
  has_many :photos, :through => :albums

  validates :email, :uniqueness => true

  def self.authenticate(email, password)
    user = User.find_by_email(email)

    if !user.nil? && user.password == password
      user
    else
      nil
    end
  end

end
