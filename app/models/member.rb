class Member < ActiveRecord::Base
  include BCrypt
  validates_confirmation_of :password_hash
  validates_presence_of :password_hash, :on => :create
  validates_presence_of :phone, :on => :create
  validates_uniqueness_of :phone
  validates_presence_of :email, :on => :create
  validates_uniqueness_of :email
  

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password == password
      user
    else
      nil
    end
  end
  
end
