class CreateInitialTemplates < ActiveRecord::Migration
  def up
    1.upto(6) do |num|
      Email::Template.create(name: "plantilla_#{num.to_s.rjust(2,'0')}")
    end
  end

  def down
    Email::Template.limit(6).destroy_all
  end
end
