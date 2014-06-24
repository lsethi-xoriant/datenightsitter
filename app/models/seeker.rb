class Seeker < Member
  has_many :transactions, :dependent => :destroy
  has_many :messages, :dependent => :destroy
  has_and_belongs_to_many :providers
  
  
end