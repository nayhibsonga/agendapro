class AddBaseTemplate < ActiveRecord::Migration
  def change
    Email::Template.create(name: "plantilla_00")
  end
end
