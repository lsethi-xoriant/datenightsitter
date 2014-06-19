class Member < ActiveRecord::Base
  include BCrypt
  validates_format_of :email, :allow_nil => true, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  validates_uniqueness_of :email, :allow_nil => true
  validates_uniqueness_of :phone, :allow_nil => true
  has_many :transactions
  has_many :messages
  
  before_validation :check_password
  
  
  def password
    @password ||= Password.new(password_hash)
  end
  
  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  
  def phone=(new_phone)
    write_attribute(:phone, new_phone.gsub(/\D/, '')) unless new_phone.nil?
  end
  
  def full_name
    [first_name, last_name].join(" ")
  end
  
  
  
  
  #Class Methods

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password == password
      user
    else
      nil
    end
  end
  
  
  protected

  def check_password
    self.password_hash ||= Password.create(SecureRandom.hex(5).to_s)
  end
  
  
end
