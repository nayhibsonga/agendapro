class Product < ActiveRecord::Base
  require 'pg_search'
  include PgSearch

  belongs_to :company
  belongs_to :product_category
  belongs_to :product_brand
  belongs_to :product_display
  has_many :location_products, dependent: :destroy
  has_many :locations, through: :location_products
  has_many :payment_products, dependent: :destroy
  has_many :payments, through: :payment_products
  has_many :receipts, through: :payment_products
  has_many :internal_sales
  has_many :product_logs, dependent: :destroy

  accepts_nested_attributes_for :location_products, :reject_if => :all_blank, :allow_destroy => true

  pg_search_scope :search,
  :against => [:name, :sku],
  :using => {
    :trigram => {
      :threshold => 0.1,
      :prefix => true,
      :any_word => true
      },
      :tsearch => {
        :prefix => true,
        :any_word => true
      }
  },
  :ignoring => :accents

  def get_commission
    if self.comission_option == 0
      return self.price * self.comission_value / 100
    else
      return self.comission_value
    end
  end

  def full_name

    full_name = self.name + ", " + self.product_category.name + ", " + self.product_brand.name + ", " + self.product_display.name + " (SKU: " + self.sku + ")"
    return full_name
  end

  # Legacy
  # def self.open_spreadsheet(file)
  #   case File.extname(file.original_filename)
  #   when ".csv" then Roo::Csv.new(file.path, file_warning: :ignore)
  #   when ".xls" then Roo::Excel.new(file.path, file_warning: :ignore)
  #   when ".xlsx" then Roo::Excelx.new(file.path, file_warning: :ignore)
  #   end
  # end

  def self.open_spreadsheet(file)
    file_name = file.original_filename
    file_path = file.path
    begin
      case File.extname(file_name)
      when ".csv"
        # Try to identify separator type
        # Take a wild guess by column count (totally improvable)
        # Accept , ; \t
        # ,
        sheet = Roo::CSV.new(file_path, file_warning: :ignore, csv_options: {col_sep: ","})

        arr = sheet.row(1)
        if arr.length > 2
          if arr[0] == "email" && arr[1] == "first_name" && arr[2] == "last_name"
            return sheet
          end
        end

        # ;
        sheet = Roo::CSV.new(file_path, file_warning: :ignore, csv_options: {col_sep: ";"})

        arr = sheet.row(1)
        if arr.length > 2
          if arr[0] == "email" && arr[1] == "first_name" && arr[2] == "last_name"
            return sheet
          end
        end

        # \t
        sheet = Roo::CSV.new(file_path, file_warning: :ignore, csv_options: {col_sep: "\t"})

        arr = sheet.row(1)
        if arr.length > 2
          if arr[0] == "email" && arr[1] == "first_name" && arr[2] == "last_name"
            return sheet
          end
        end

        return nil
      when ".xlsx"
        Roo::Excelx.new(file_path, file_warning: :ignore)
      when ".xlsm"
        Roo::Excelx.new(file_path, file_warning: :ignore)
      when ".ods"
        Roo::OpenOffice.new(file_path, file_warning: :ignore)
      when ".xls"
        begin
          Roo::Excel.new(file_path, file_warning: :ignore)
        rescue
          Roo::Excel2003XML.new(file_path, file_warning: :ignore)
        end
      when ".xml"
        Roo::Excel2003XML.new(file_path, file_warning: :ignore)
      end
    rescue
      return nil
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

        sku = row[0].to_s.chomp('.0').strip
        category_str = row[1].to_s
        brand_str = row[2].to_s
        name_str = row[3].to_s
        display_str = row[4].to_s

        cost = row[5].to_s.to_f
        price = row[6].to_s.to_f
        internal_price = row[7].to_s.to_f
        comission_value = row[8].to_s.to_f
        comission_option = row[9].to_s.to_i
        description = row[10].to_s

        logger.debug "SKU: " + sku
        logger.debug "Category: " + category_str
        logger.debug "Brand: " + brand_str
        logger.debug "Display: " + display_str
        logger.debug "Name: " + name_str

        product = Product.new
        category = ProductCategory.new
        brand = ProductBrand.new
        display = ProductDisplay.new

        if !ProductCategory.where(:name => category_str, :company_id => company_id).first.nil?
          category = ProductCategory.where(:name => category_str, :company_id => company_id).first
        else
          category.name = category_str
          category.company_id = company_id
          category.save
        end

        if !ProductBrand.where(:name => brand_str, :company_id => company_id).first.nil?
          brand = ProductBrand.where(:name => brand_str, :company_id => company_id).first
        else
          brand.name = brand_str
          brand.company_id = company_id
          brand.save
        end

        if !ProductDisplay.where(:name => display_str, :company_id => company_id).first.nil?
          display = ProductDisplay.where(:name => display_str, :company_id => company_id).first
        else
          display.name = display_str
          display.company_id = company_id
          display.save
        end

        if Product.where(sku: sku, company_id: company_id).count > 0
          product = Product.where(sku: sku, company_id: company_id).first
        end

        product.sku = sku
        product.name = name_str
        product.product_category_id = category.id
        product.product_brand_id = brand.id
        product.product_display_id = display.id
        product.company_id = company_id

        product.cost = cost
        product.price = price
        product.internal_price = internal_price
        product.comission_value = comission_value
        product.comission_option = comission_option
        product.description = description

        product.save

        loc_index = 11

        xls_locations.each do |location|
          if LocationProduct.where(:location_id => location.id, :product_id => product.id).count > 0
            location_product = LocationProduct.where(:location_id => location.id, :product_id => product.id).first
            old_stock = location_product.stock
            location_product.stock = row[loc_index].to_i
            if location_product.save
              ProductLog.create(product_id: product.id, location_id: location.id, user_id: current_user.id, change: "Incremento de " + old_stock.to_s + " a " + location_product.stock.to_s, cause: "Importación de productos.")
            end
          else
            if !row[loc_index].blank?
              location_product = LocationProduct.create(:location_id => location.id, :product_id => product.id, :stock => row[loc_index].to_i)
              ProductLog.create(product_id: product.id, location_id: location.id, user_id: current_user.id, change: "Creación de producto con stock de " + row[loc_index], cause: "Importación de productos.")
            else
              location_product = LocationProduct.create(:location_id => location.id, :product_id => product.id, :stock => 0)
              ProductLog.create(product_id: product.id, location_id: location.id, user_id: current_user.id, change: "Creación de producto con stock de 0", cause: "Importación de productos.")
            end
          end
          loc_index = loc_index + 1
        end

        #Check if there are missing locations (for instance, a local administrator is importing products).
        #If there are, check if any has no LocationProduct. If so, create it. Else, continue (they have one already and
        #shouldn't be modified without privileges.
        if pre_xls_locations.count != xls_locations.count
          missing_locations = pre_xls_locations - xls_locations
          missing_locations.each do |location|
            if LocationProduct.where(:location_id => location.id, :product_id => product.id).count == 0
              location_product = LocationProduct.create(:location_id => location.id, :product_id => product.id, :stock => 0)
              ProductLog.create(product_id: product.id, location_id: location.id, user_id: current_user.id, change: "Creación de producto con stock de 0", cause: "Importación de productos.")
            end
          end
        end

      end

      message = "Productos importados correctamente."

    else
      message = "Error en el archivo de importación, archivo inválido o lista vacía."
    end
  end

end
