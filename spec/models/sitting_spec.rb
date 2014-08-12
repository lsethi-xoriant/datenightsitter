require 'rails_helper'

RSpec.shared_examples 'a valid sitting object' do |status|
  it "is a Sitting object" do
    expect(subject).to be_valid
    expect(subject).to be_a(Sitting)
  end
  
  it "responds truthy to ##{status}?" do
    expect(subject.send(status + "?")).to be_truthy
  end
  
end

RSpec.shared_examples 'an editable sitting' do |status|
  it "returns true from #status_editable?" do
    expect(subject.status_editable?).to be_truthy
  end
  
  it "returns an array of valid status's from #status_editable_options" do
    expect(subject.status_editable_options).to be_a(Array)
  end
  
  it "status is no longer #{status} after calling #toggle_availability" do
    subject.toggle_availability
    expect(subject.send(status + "?")).to be_falsey
  end
end

RSpec.shared_examples "an uneditable sitting" do |status|
  it "returns false from #status_editable?" do
    expect(subject.status_editable?).to be_falsey
  end
  
  it "status remains #{status} after calling #toggle_availability" do
    subject.toggle_availability
    expect(subject.send(status + "?")).to be_truthy
  end
end

RSpec.shared_examples "a bookable sitting" do
  it "calling #book changes status to: booked " do
    subject.book
    expect(subject.booked?).to be_truthy
  end
end


RSpec.describe Sitting, :type => :model do
  context "after being created" do
    subject { FactoryGirl.create(:sitting) }
    status = "requested"
    it_should_behave_like "a valid sitting object", status
    it_should_behave_like "a bookable sitting"
  end

  context "after being created as status: available" do
    subject { FactoryGirl.create(:sitting_available) }
    status = "available"
    it_should_behave_like "a valid sitting object", status
    it_should_behave_like "an editable sitting", status
    it_should_behave_like "a bookable sitting"
    
    it "can be guaranteed" do
      expect(subject.guarantee).to be_truthy
      expect(subject.guaranteed?).to be_truthy
    end
  end
  
  context "after being created as status: unavailable" do
    subject { FactoryGirl.create(:sitting_unavailable) }
    status = "unavailable"
    it_should_behave_like "a valid sitting object", status
    it_should_behave_like "an editable sitting", status
  end
  
  context "after becoming a guranteed sitting" do
    subject {
      s = FactoryGirl.create(:sitting_available)
      s.guarantee
      s
    }
    status = "guaranteed"
    it_should_behave_like "a valid sitting object", status
    it_should_behave_like "an uneditable sitting", status
    
  end
  
end
