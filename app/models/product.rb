class Product < ActiveRecord::Base
  belongs_to :company
  belongs_to :product_category
  belongs_to :product_brand
  belongs_to :product_display
  has_many :location_products
  has_many :locations, through: :location_products
  has_many :payment_products
  has_many :payments, through: :payment_products
  has_many :receipt_products
  has_many :receipts, through: :receipt_products

  accepts_nested_attributes_for :location_products, :reject_if => :all_blank, :allow_destroy => true

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, file_warning: :ignore)
    when ".xls" then Roo::Excel.new(file.path, file_warning: :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, file_warning: :ignore)
    end
  end

  def self.import(file, company_id, current_user)

    spreadsheet = open_spreadsheet(file)

    if !spreadsheet.nil?

      pre_xls_locations = Location.where(company_id: current_user.company_id, active: true).order(:id)
      xls_locations = []

      if current_user.role_id != Role.find_by_name("Administrador General").id
        pre_xls_locations.each do |location|
          if current_user.locations.pluck(:id).include?(location.id)
            xls_locations << location
          end
        end
      else
         xls_locations = pre_xls_locations
      end

      header = spreadsheet.row(1)
      #"Sku", "Categoría", "Marca", "Nombre", "Cantidad/Unidad"

      (2..spreadsheet.last_row).each do |i|
        
        row = Hash[[header, spreadsheet.row(i)].transpose].values

        logger.debug row.inspect

        sku = row[0].to_s
        category_str = row[1].to_s
        brand_str = row[2].to_s
        name_str = row[3].to_s
        display_str = row[4].to_s

        logger.debug "Category: " + category_str
        logger.debug "Brand: " + brand_str
        logger.debug "Display: " + display_str
        logger.debug "Name: " + name_str

        # product = Product.new
        # category = ProductCategory.new
        # brand = ProductBrand.new
        # display = ProductDisplay.new

        # if !ProductCategory.where(:name => category_str, :company_id => company_id).first.nil?
        #   category = ProductCategory.where(:name => category_str, :company_id => company_id).first
        # else
        #   category.name = category_str
        #   category.company_id = company_id
        #   category.save
        # end

        # if !ProductBrand.where(:name => category_str, :company_id => company_id).first.nil?
        #   brand = ProductBrand.where(:name => category_str, :company_id => company_id).first
        # else
        #   brand.name = brand_str
        #   brand.company_id = company_id
        #   brand.save
        # end

        # if !ProductDisplay.where(:name => category_str, :company_id => company_id).first.nil?
        #   display = ProductDisplay.where(:name => category_str, :company_id => company_id).first
        # else
        #   display.name = display_str
        #   display.company_id = company_id
        #   display.save
        # end

        # if !Product.find_by_sku(sku).nil?
        #   product = Product.find_by_sku(sku)
        # end

        # product.name = name_str
        # product.product_category_id = category.id
        # product.product_brand_id = brand.id
        # product.product_display_id = display.id
        # product.save

        # loc_index = 5

        # xls_locations.each do |location|
        #   if LocationProduct.where(:location_id => location.id, :product_id => product.id).count > 0
        #     location_product = LocationProduct.where(:location_id => location.id, :product_id => product.id).first
        #     location_product.stock = row[loc_index].to_i
        #     location_product.save
        #   else
        #     location_product = LocationProduct.create(:location_id => location.id, :product_id => product.id, :stock => row[loc_index].to_i)
        #   end
        #   loc_index = loc_index + 1
        # end

      end

    else
      message = "Error en el archivo de importación, archivo inválido o lista vacía."
    end
  end

end
