class Seeker < Member
  has_many :transactions
  has_many :messages
  has_and_belongs_to_many :providers
  
  
end