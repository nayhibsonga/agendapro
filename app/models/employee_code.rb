class EmployeeCode < ActiveRecord::Base
  belongs_to :company
  has_many :payments, dependent: :nullify
  has_many :internal_sales, dependent: :nullify
  has_many :booking_histories, dependent: :nullify

  validate :code_uniqueness

  def code_uniqueness
  	if self.code.nil? || self.code == ""
  		errors.add(:base, "El código de empleado no puede estar vacío.")
  		return
  	end
  	EmployeeCode.where(:company_id => self.company_id, :code => self.code).each do |employee_code|
  		if employee_code != self && employee_code.code != "" && employee_code.code == self.code
  			errors.add(:base, "No puede haber dos empleados con el mismo código.")
  		end
  	end
  end

end
