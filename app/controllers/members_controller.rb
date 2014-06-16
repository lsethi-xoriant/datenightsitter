class MembersController < ApplicationController

  def new
    @member = Member.new
  end
  
  def create
    @member = Member.new(member_params)
    if @member.save
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
  end
  
  def update
    redirect_to current_account.members.find(params[:id]).tap { |member|
      member.update!(member_params)
    }
  end
  
  def dashboard
    @member = current_member
    render "sitter_dashboard" if @member.provider?
    render "parent_dashboard" if @member.seeker?
  end
  
  def sitter_dashboard
    @member = current_member
    render sitter_dashboard
  end
  
  def parent_dashboard
    @member = current_member
    render parent_dashboard
  end
  
  private
  
  def member_params
    params.require(:member).permit(:first_name, :last_name, :email, :password, :address, :city, :state, :zip)
  end
  
end
