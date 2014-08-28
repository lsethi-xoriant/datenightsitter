# == Schema Information
#
# Table name: messages
#
#  id            :integer          not null, primary key
#  type          :string(255)
#  provider_id   :integer
#  seeker_id     :integer
#  direction     :integer
#  subject       :string(255)
#  body          :text
#  reference_url :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  template      :string(255)
#

require 'rails_helper'

RSpec.describe Message, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
