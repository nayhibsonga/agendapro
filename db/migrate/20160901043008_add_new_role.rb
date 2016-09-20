class AddNewRole < ActiveRecord::Migration
  Role.create(name: "Recepcionista (sin edición)", description: "Rol que puede ver y editar fichas de usuario pero no agendar.")
end
