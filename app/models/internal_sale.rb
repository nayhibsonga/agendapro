class InternalSale < ActiveRecord::Base
	belongs_to :location
	#belongs_to :cashier
  belongs_to :employee_code
	belongs_to :service_provider
	belongs_to :product
	belongs_to :user

  has_one :product_log, dependent: :nullify

  def buyer_details
    details_str = ""
    if self.service_provider.nil? && self.user.nil?
      details_str += "Sin información."
    elsif !self.service_provider.nil?
      details_str += self.service_provider.public_name + " (prestador)."
    elsif !self.user.nil?
      details_str += self.user.full_name + " (usuario)."
    else
      details_str = "Sin información"
    end
    return details_str
  end

  def cashier_details
    details_str = "Sin información."
    if !self.employee_code_id.nil? && EmployeeCode.where(id: self.employee_code_id).count > 0
      details_str = self.employee_code.name + "."
    end
    return details_str
  end

  def get_notes
    if notes == ""
      return "Sin comentarios"
    else
      return notes
    end
  end

end
