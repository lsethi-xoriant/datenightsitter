require 'rails_helper'

RSpec.describe ApplicationHelper, :type => :helper do
  describe "#flass_class" do
    
    it "returns 'alert-danger' class when 'danger' flag presented" do
      expect(helper.flash_class("danger")).to eq("alert-danger")
    end

    it "returns 'alert-danger' class when 'error' flag presented" do
      expect(helper.flash_class("error")).to eq("alert-danger")
    end
    it "returns 'alert-danger' class when 'alert' flag presented" do
      expect(helper.flash_class("alert")).to eq("alert-danger")
    end

    it "returns 'alert-success' class when 'success' flag presented" do
      expect(helper.flash_class("success")).to eq("alert-success")
    end

    it "returns 'alert-warning' class when 'warning' flag presented" do
      expect(helper.flash_class("warning")).to eq("alert-warning")
    end

    it "returns 'alert-info' class when 'info' flag presented" do
      expect(helper.flash_class("info")).to eq("alert-info")
    end

    it "returns 'alert-info' class when 'notice' flag presented" do
      expect(helper.flash_class("notice")).to eq("alert-info")
    end
  end
  
end
