require 'rails_helper'

RSpec.describe Email::Content, :type => :model do
  data = {
    from: "nflores@agendapro.cl",
    to: "contacto@agendapro.cl",
    subject: "test",
    data: {
      text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sapien orci, interdum in tellus ut, pellentesque pharetra ipsum. Integer ac metus eget dui rutrum dictum in nec libero. Sed diam orci, venenatis et facilisis quis, lacinia sit amet massa. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam erat volutpat.",
      image: "https://agendaprotest.s3.amazonaws.com/email_content//7a22f06e-5c4a-4dd5-8018-154f2557c23a.png"
    }
  }
  context "edit unexisting content" do
    it "without providing an id" do
      result = Email::Content.generate(nil, data)
      expect(result).to eq(nil)
    end

    it "with an invalid id" do
      Email::Content.create(data)
      result = Email::Content.generate(2, data)
      expect(result).to eq(nil)
    end
  end

  context "edit exisiting content" do
    it "without providing any data" do
      content = Email::Content.create(template_id: 1)
      result = Email::Content.generate(content.id, nil)
      expect(result).to eq(true)
    end

    it "providing valid data" do
      content = Email::Content.create(template_id: 1)
      result = Email::Content.generate(content.id, data)
      expect(result).to eq(true)
    end
  end
end
