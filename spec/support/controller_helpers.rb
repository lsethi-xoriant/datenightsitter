module ControllerHelpers
  def sign_in(member = double('member'))
    if member.nil?
      allow(controller).to receive(:authenticate_member).and_return(false)
      allow(controller).to receive(:current_member).and_return(nil)
      allow(controller).to receive(:member_authenticated?).and_return(false)
    else
      allow(controller).to receive(:authenticate_member).and_return(true)
      allow(controller).to receive(:current_member).and_return(member)
      allow(controller).to receive(:member_authenticated?).and_return(true)
    end
  end

end