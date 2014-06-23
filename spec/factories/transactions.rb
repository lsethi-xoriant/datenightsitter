# Read about factories at https://github.com/thoughtbot/factory_girl
require "faker"

FactoryGirl.define do
  factory :transaction do
    started_at { DateTime.now }
    duration { rand(8) }
    rate { rand(25) }
  end
end
