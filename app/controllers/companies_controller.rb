class CompaniesController < ApplicationController
  	before_action :verify_is_active, only: [:overview, :workflow]
	before_action :set_company, only: [:show, :edit, :update, :destroy, :edit_payment]
	before_action :constraint_locale, only: [:overview, :workflow]
	before_action :authenticate_user!, except: [:new, :overview, :workflow, :check_company_web_address, :select_hour, :user_data, :select_promo_hour, :mobile_hours]
	before_action :quick_add, except: [:new, :overview, :workflow, :add_company, :check_company_web_address, :select_hour, :user_data, :select_promo_hour, :mobile_hours]
	before_action :verify_is_super_admin, only: [:index, :edit_payment, :new, :edit, :manage, :manage_company, :new_payment, :add_payment, :update_company, :get_year_incomes, :incomes, :locations, :monthly_locations, :deactivate_company]
	before_action :verify_premium_plan, only: [:files, :create_folder, :rename_folder, :delete_folder, :upload_file, :move_file, :edit_file]

	layout "admin", except: [:show, :overview, :workflow, :add_company, :select_hour, :user_data, :select_session_hour, :select_promo_hour]
	load_and_authorize_resource

	respond_to :html, :json, :xls, :csv

	# GET /companies
	# GET /companies.json
	def index
		@companies = Company.all.order(:name)
	end

	#SuperAdmin

	def pending_billing_wire_transfers

		@transfers = BillingWireTransfer.where(approved: false)

	end

	def approved_billing_wire_transfers

		@transfers = BillingWireTransfer.where(approved: true)

	end

	def show_billing_wire_transfer
	    @transfer = BillingWireTransfer.find(params[:billing_wire_transfer_id])
	    respond_to do |format|
	      format.html { render :partial => 'billing_wire_transfer_summary' }
	      format.json { render :json => @transfer }
	    end
	end

	def approve_billing_wire_transfer

		@json_response = []

		@transfer = BillingWireTransfer.find(params[:billing_wire_transfer_id])
		company = Company.find(@transfer.company_id)
		sales_tax = company.country.sales_tax

    	day_number = @transfer.payment_date.day
    	month_number = @transfer.payment_date.month
    	month_days = @transfer.payment_date.days_in_month

    	puts "Day number: " + day_number.to_s
    	puts "Month number: " + month_number.to_s
    	puts "Month_days: " + month_days.to_s


    	if company.plan_id != Plan.find_by_name("Gratis").id
	    	if @transfer.change_plan

	    		plan_id = @transfer.new_plan

	    		#company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where(locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).first.price : price = company.plan.plan_countries.find_by(country_id: company.country.id).price

	    		price = 0
			    if company.payment_status == PaymentStatus.find_by_name("Trial")
			      if company.locations.count > 1 || company.service_providers.count > 1
			        price = Plan.where(name: "Normal", custom: false).first.plan_countries.find_by(country_id: company.country.id).price * company.computed_multiplier
			      else
			        price = Plan.where(name: "Personal", custom: false).first.plan_countries.find_by(country_id: company.country.id).price * company.computed_multiplier
			      end
			    else
			      if company.plan.custom
			        price = company.company_plan_setting.base_price
			      else
			        price = company.company_plan_setting.base_price * company.computed_multiplier
			      end
			    end

			    if company.payment_status_id == PaymentStatus.find_by_name("Trial").id || company.payment_status_id == PaymentStatus.find_by_name("Bloqueado").id || company.payment_status_id == PaymentStatus.find_by_name("Inactivo").id
			      	price = ((month_days - day_number + 1).to_f / month_days.to_f) * price
			    end

	    		new_plan = Plan.find(plan_id)

	    		accepted_plans = Plan.where(custom: false).pluck(:id)

	    		if accepted_plans.include?(plan_id)

	    			if (company.service_providers.where(active: true, location_id: company.locations.where(active: true).pluck(:id)).count <= new_plan.service_providers && company.locations.where(active: true).count <= new_plan.locations) || (!new_plan.custom && new_plan.name != "Personal")

	    				previous_plan_id = company.plan.id
				        months_active_left = company.months_active_left
				        plan_value_left = (month_days - day_number + 1)*price/month_days + price*(months_active_left - 1)
				        due_amount = company.due_amount
				        plan_price = Plan.find(plan_id).plan_countries.find_by(country_id: company.country.id).price * company.computed_multiplier
				        previous_plan_price = company.plan.plan_countries.find_by(country_id: company.country.id).price
				        plan_month_value = (month_days - day_number + 1)*plan_price/month_days

				        #Days that should be payed of current plan
				        plan_value_taken = (day_number*previous_plan_price/month_days + -1*previous_plan_price*(company.months_active_left))

				        puts "Plan value left: " + plan_value_left.to_s

				        if months_active_left > 0
	          				if plan_value_left > (plan_month_value + due_amount)

					            new_active_months_left = ((plan_value_left - plan_month_value - due_amount/(1 + sales_tax)).round(0)/plan_price).floor + 1

					            new_amount_due = (-1 * (((plan_value_left - plan_month_value - due_amount/(1 + sales_tax)).round(0)/plan_price) % 1 )) * plan_price * (1 + sales_tax)

					            company.active = true
					            company.plan_id = plan_id
					            company.months_active_left = new_active_months_left
					            company.due_amount = (new_amount_due).round(0) * (1 + sales_tax)

					            if company.save

					            	company.company_plan_setting.base_price = Plan.find(plan_id).plan_countries.find_by(country_id: company.country.id).price
					            	company.company_plan_setting.save
					            	company.company_setting.mails_base_capacity = company.plan.monthly_mails
          							company.company_setting.save

					            	@transfer.approved = true
					            	@transfer.save

					              	PlanLog.create(trx_id: "", new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id, amount: 0.0)

					              	@transfer.sendings.build(method: 'receipt_transfer').save

					              	@json_response[0] = "ok"
									@json_response[1] = company
									render :json => @json_response
									return

					            else
					              	@json_response[0] = "error"
									@json_response[1] = company.errors
									render :json => @json_response
									return
					            end
					        else

					        	mockCompany = Company.find(company.id)
					            mockCompany.plan_id = plan_id
					            mockCompany.months_active_left = 1.0
					            mockCompany.due_amount = 0.0
					            mockCompany.due_date = nil
					            mockCompany.active = true
					            mockCompany.payment_status_id = PaymentStatus.find_by_name("Activo").id
					            if !mockCompany.valid?
					            	@json_response[0] = "error"
									@json_response[1] = mockCompany.errors
									render :json => @json_response
									return
					            else

					            	due_number = ((plan_month_value + due_amount / (1 + sales_tax) - plan_value_left)*(1+sales_tax)).round(0)
					              	due = sprintf('%.2f', ((plan_month_value + due_amount / (1 + sales_tax) - plan_value_left)*(1+sales_tax)).round(0))

					              	if @transfer.amount.round(0) != due_number
						    			#Error
										@json_response[0] = "error"
										@json_response[1] = "El monto transferido no es correcto. Transferido: " + @transfer.amount.to_s + " / Precio: " + due_number.to_s
										render :json => @json_response
										return
						    		end

						    		if mockCompany.save

						    			mockCompany.company_plan_setting.base_price = Plan.find(plan_id).plan_countries.find_by(country_id: company.country.id).price
					            		mockCompany.company_plan_setting.save
					            		mockCompany.company_setting.mails_base_capacity = mockCompany.plan.monthly_mails
          								mockCompany.company_setting.save

						                PlanLog.create(trx_id: "", new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id, amount: due)

						                @transfer.approved = true
						                @transfer.save

						                @transfer.sendings.build(method: 'receipt_transfer').save

						                @json_response[0] = "ok"
										@json_response[1] = company
										render :json => @json_response
										return
									else
										@json_response[0] = "error"
										@json_response[1] = company.errors
										render :json => @json_response
										return
									end

					            end

					        end

					    else

					    	mockCompany = Company.find(company.id)
							mockCompany.plan_id = plan_id
							mockCompany.months_active_left = 1.0
							mockCompany.due_amount = 0.0
							mockCompany.due_date = nil
							mockCompany.active = true
							mockCompany.payment_status_id = PaymentStatus.find_by_name("Activo").id
							if !mockCompany.valid?
								@json_response[0] = "error"
								@json_response[1] = mockCompany.errors
								render :json => @json_response
								return
							else
								puts "HERE"
								puts "HERE"
								puts "HERE"
								puts "plan_value_taken: " + plan_value_taken.to_s
								puts "plan_month_value: " + plan_month_value.to_s
								puts "due_amount: " + due_amount.to_s

								due_number = ((plan_value_taken + due_amount / (1 + sales_tax) + plan_month_value) * (1 + sales_tax)).round(0)
								due = sprintf('%.2f', ((plan_month_value + due_amount / (1 + sales_tax))*(1+sales_tax)).round(0))

								if @transfer.amount.round(0) != due_number
					    			#Error
									@json_response[0] = "error"
									@json_response[1] = "El monto transferido no es correcto. Transferido: " + @transfer.amount.to_s + " / Precio: " + due_number.to_s
									render :json => @json_response
									return
					    		end

					    		if mockCompany.save
									PlanLog.create(trx_id: "", new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id, amount: due)

									mockCompany.company_plan_setting.base_price = Plan.find(plan_id).plan_countries.find_by(country_id: company.country.id).price
					            	mockCompany.company_plan_setting.save
					            	mockCompany.company_setting.mails_base_capacity = mockCompany.plan.monthly_mails
          							mockCompany.company_setting.save

									@transfer.approved
									@transfer.save

									@transfer.sendings.build(method: 'receipt_transfer').save

									@json_response[0] = "ok"
									@json_response[1] = company
									render :json => @json_response
									return
								else
									@json_response[0] = "error"
									@json_response[1] = company.errors
									render :json => @json_response
									return
								end


							end

					   	end

	    			else
	    				@json_response[0] = "error"
						@json_response[1] = "La empresa tiene más prestadores o locales que el plan elegido"
						render :json => @json_response
						return
	    			end

	    		else
	    			@json_response[0] = "error"
					@json_response[1] = "El plan solicitado no está entre los elegibles"
					render :json => @json_response
					return
	    		end

	    	else

	    		#company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where(custom: false, locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first.plan_countries.find_by(country_id: company.country.id).price : price = company.plan.plan_countries.find_by(country_id: company.country.id).price

	    		price = 0
			    if company.payment_status == PaymentStatus.find_by_name("Trial")
			      if company.locations.count > 1 || company.service_providers.count > 1
			        price = Plan.where(name: "Normal", custom: false).first.plan_countries.find_by(country_id: company.country.id).price * company.computed_multiplier
			      else
			        price = Plan.where(name: "Personal", custom: false).first.plan_countries.find_by(country_id: company.country.id).price * company.computed_multiplier
			      end
			    else
			      if company.plan.custom
			        price = company.company_plan_setting.base_price
			      else
			        price = company.company_plan_setting.base_price * company.computed_multiplier
			      end
			    end

			    if company.payment_status_id == PaymentStatus.find_by_name("Trial").id || company.payment_status_id == PaymentStatus.find_by_name("Bloqueado").id || company.payment_status_id == PaymentStatus.find_by_name("Inactivo").id
			      price = ((month_days - day_number + 1).to_f / month_days.to_f) * price
			    end

	    		accepted_amounts = [1,2,3,4,6,9,12]
	    		if accepted_amounts.include?(@transfer.paid_months)

	    			mockCompany = Company.find(company.id)
					mockCompany.months_active_left += @transfer.paid_months
					mockCompany.due_amount = 0.0
					mockCompany.due_date = nil
					mockCompany.payment_status_id = PaymentStatus.find_by_name("Activo").id
					mockCompany.active = true
					if !mockCompany.valid?
						#Error
						@json_response[0] = "error"
						@json_response[1] = mockCompany.errors
						render :json => @json_response
						return
					else
						NumericParameter.find_by_name(@transfer.paid_months.to_s+"_month_discount") ? month_discount = NumericParameter.find_by_name(@transfer.paid_months.to_s+"_month_discount").value : month_discount = 0

						#company.months_active_left > 0 ? plan_1 = (company.due_amount + price*(1+sales_tax)).round(0) : plan_1 = ((company.due_amount + (month_days - day_number + 1)*price/month_days)*(1+sales_tax)).round(0)

						plan_1 = (company.due_amount + price*(1+sales_tax)).round(0)

						due_number = ((plan_1 + price*(@transfer.paid_months-1)*(1+sales_tax))*(1-month_discount)).round(0)

	        			due = sprintf('%.2f', ((plan_1 + price*(@transfer.paid_months-1)*(1+sales_tax))*(1-month_discount)).round(0))

	        			if @transfer.amount.round(0) != due_number.round(0)
			    			#Error
							@json_response[0] = "error"
							@json_response[1] = "El monto transferido no es correcto. Transferido: " + @transfer.amount.to_s + " / Precio: " + due_number.to_s
							render :json => @json_response
							return
			    		end


	        			BillingLog.create(payment: due, amount: @transfer.paid_months, company_id: company.id, plan_id: company.plan.id, transaction_type_id: TransactionType.find_by_name("Transferencia Formulario").id, trx_id: "")

	        			company.months_active_left += @transfer.paid_months
						company.due_amount = 0.0
						company.due_date = nil
						company.payment_status_id = PaymentStatus.find_by_name("Activo").id
						company.active = true

	        			if company.save
	        				@transfer.approved = true
	        				@transfer.save
			          		CompanyCronLog.create(company_id: company.id, action_ref: 7, details: "OK notification_billing")
			          		@transfer.sendings.build(method: 'receipt_transfer').save
			          		@json_response[0] = "ok"
							@json_response[1] = company
							render :json => @json_response
							return
			        	else
			          		CompanyCronLog.create(company_id: company.id, action_ref: 7, details: "ERROR notification_billing "+company.errors.full_messages.inspect)
			          		@json_response[0] = "error"
							@json_response[1] = company.errors
							render :json => @json_response
							return
			        	end

					end
				else
					@json_response[0] = "error"
					@json_response[1] = "La cantidad de meses a pagar no es válida"
					render :json => @json_response
					return
	    		end

	    	end
	    else

	    	downgradeLog = DowngradeLog.where(company_id: company.id).order('created_at desc').first

		    new_plan = downgradeLog.plan

		    #Should have free plan
		    previous_plan = company.plan

		    if new_plan.custom
		    	price = new_plan.plan_countries.find_by(country_id: company.country.id).price
		    else
		    	price = new_plan.plan_countries.find_by(country_id: company.country.id).price * company.computed_multiplier
		    end

		    plan_month_value = ((month_days - day_number + 1).to_f / month_days.to_f) * price
		    due_amount = downgradeLog.debt

		    due_number = (due_amount + plan_month_value * (1 + sales_tax)).round(0)

		    company = Company.find(company.id)
			company.plan_id = new_plan.id
			company.months_active_left = 1.0
			company.due_amount = 0.0
			company.due_date = nil
			company.payment_status_id = PaymentStatus.find_by_name("Activo").id
			company.active = true

			if !company.valid?
			    #Error
				@json_response[0] = "error"
				@json_response[1] = company.errors
				render :json => @json_response
				return
			end

			if @transfer.amount.round(0) != due_number
    			#Error
				@json_response[0] = "error"
				@json_response[1] = "El monto transferido no es correcto. Transferido: " + @transfer.amount.to_s + " / Precio: " + due_number.to_s
				render :json => @json_response
				return
    		end

    		if company.save

    			due = sprintf('%.2f', due_number)

                PlanLog.create(trx_id: "", new_plan_id: new_plan.id, prev_plan_id: previous_plan.id, company_id: company.id, amount: due)

                @transfer.approved = true
                @transfer.save

                @transfer.sendings.build(method: 'receipt_transfer').save

                @json_response[0] = "ok"
				@json_response[1] = company
				render :json => @json_response
				return
			else
				@json_response[0] = "error"
				@json_response[1] = company.errors
				render :json => @json_response
				return
			end

	    end

	end

	def disapprove_billing_wire_transfer

	end

	def delete_billing_wire_transfer

		@json_response = []
		@transfer = BillingWireTransfer.find(params[:billing_wire_transfer_id])

		if @transfer.delete
			@json_response[0] = "ok"
			@json_response[1] = @transfer
		else
			@json_response[0] = "error"
			@json_response[1] = @transfer.errors
		end

		render :json => @json_response

	end

	#Manage companies payments.
	def manage
		if current_user.role_id == Role.find_by_name("Ventas").id
			@companies = StatsCompany.where(company_sales_user_id: current_user.id)
			@active_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Activo').id).order(:company_name)
			@trial_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Trial').id).order(:created_at, :company_name)
			@late_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Vencido').id).order(:company_name)
			@blocked_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Bloqueado').id).order(:company_name)
			@inactive_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Inactivo').id).order(:company_name)
			@issued_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Emitido').id).order(:company_name)
			@pac_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Convenio PAC').id).order(:company_name)
		else
			@user = User.find_by_email('cuentas@agendapro.cl')
			if I18n.locale == :es
				@companies = StatsCompany.all#.order(:company_name)
			else
				@companies = StatsCompany.where(company_id: Company.where(country_id: Country.find_by(locale: I18n.locale.to_s)))#.order(:company_name)
			end
			@active_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Activo').id).order(:company_name)
			@trial_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Trial').id).order(:created_at, :company_name)
			@late_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Vencido').id).order(:company_name)
			@blocked_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Bloqueado').id).order(:company_name)
			@inactive_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Inactivo').id).order(:company_name)
			@issued_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Emitido').id).order(:company_name)
			@pac_companies = @companies.where(:company_payment_status_id => PaymentStatus.find_by_name('Convenio PAC').id).order(:company_name)
		end
	end

	#SuperAdmin
	#Manage company sheet.
	def manage_company
		@company = Company.find(params[:id])
		@bookings = Array.new
		@company.locations.each do |location|
			location.bookings.each do |booking|
				@bookings << booking
			end
		end

		@billing_info = BillingInfo.new
		if BillingInfo.where(company_id: @company.id).count > 0
			@billing_info = @company.billing_info
		end

		# @company.payment_status == PaymentStatus.find_by_name("Trial") ? @price = Plan.find_by_name("Normal").plan_countries.find_by(country_id: @company.country.id).price : @price = @company.plan.plan_countries.find_by(country_id: @company.country.id).price

		#@company.payment_status == PaymentStatus.find_by_name("Trial") ? @price = Plan.where.not(id: Plan.find_by_name("Gratis").id).where(custom: false).where('locations >= ?', @company.locations.where(active: true).count).where('service_providers >= ?', @company.service_providers.where(active: true).count).order(:service_providers).first.plan_countries.find_by(country_id: @company.country.id).price : @price = @company.plan.plan_countries.find_by(country_id: @company.country.id).price

		@price = 0
	    if @company.payment_status == PaymentStatus.find_by_name("Trial")
	    	plan = @company.default_plan

	    	if plan.name == "Normal" || plan.name == "Personal"
				if @company.locations.where(active: true).count > 1 || @company.service_providers.where(location_id: @company.locations.where(active: true).pluck(:id), active:true).count > 1
					plan = Plan.where(name: "Normal", custom: false).first
				else
					plan = Plan.where(name: "Personal", custom: false).first
				end
 			end

	        @price = plan.plan_countries.find_by(country_id: @company.country.id).price * @company.computed_multiplier

	    else
	      if @company.plan.custom
	        @price = @company.company_plan_setting.base_price
	      else
	        @price = @company.company_plan_setting.base_price * @company.computed_multiplier
	      end
	    end

		@sales_tax = @company.country.sales_tax
	    @month_discount_4 = NumericParameter.find_by_name("4_month_discount").value
	    @month_discount_6 = NumericParameter.find_by_name("6_month_discount").value
	    @month_discount_9 = NumericParameter.find_by_name("9_month_discount").value
	    @month_discount_12 = NumericParameter.find_by_name("12_month_discount").value



	    @day_number = Time.now.day
	    @month_number = Time.now.month
	    @month_days = Time.now.days_in_month
		#@company.months_active_left > 0 ? @plan_1 = (@company.due_amount/(1+@sales_tax) + @price).round(0) : @plan_1 = ((@company.due_amount/(1+@sales_tax) + (@month_days - @day_number + 1)*@price/@month_days)).round(0)

		@plan_1 = (@company.due_amount/(1+@sales_tax) + @price).round(0)

		if @company.payment_status_id == PaymentStatus.find_by_name("Trial").id || @company.payment_status_id == PaymentStatus.find_by_name("Bloqueado").id || @company.payment_status_id == PaymentStatus.find_by_name("Inactivo").id
	      	puts "True"
	      	special_price = ((@month_days - @day_number + 1).to_f / @month_days.to_f) * @price
	      	@plan_1 = (@company.due_amount + special_price * (1+@sales_tax)).round(0)
	    end


	    @plan_2 = (@plan_1 + @price*1).round(0)
	    @plan_3 = (@plan_1 + @price*2).round(0)
	    @plan_4 = ((@plan_1 + @price*3)*(1-@month_discount_4)).round(0)
	    @plan_6 = ((@plan_1 + @price*5)*(1-@month_discount_6)).round(0)
	    @plan_9 = ((@plan_1 + @price*8)*(1-@month_discount_9)).round(0)
	    @plan_12 = ((@plan_1 + @price*11)*(1-@month_discount_12)).round(0)
	end

	#SuperAdmin
	#Add manual payment (billingRecord) to a company
	def new_payment
		@company = Company.find(params[:id])
	end

	#SuperAdmin
	def add_payment
		@company = Company.find(params[:id])
		amount = params[:amount].to_f
		date = Date.parse(params[:date])
		billing_record = BillingRecord.new
		billing_record.company_id = @company.id
		billing_record.amount = amount
		billing_record.transaction_type_id = params[:transaction_type_id]
		billing_record.date = date
		if billing_record.save
			if @company.plan.id != params[:new_plan_id]
				@company.plan_id = params[:new_plan_id]
			end
			if params[:new_due] != ""
				@company.due_amount = params[:new_due].to_f
			end
			if params[:new_months] != ""
				@company.months_active_left = params[:new_months].to_f
			end
			if @company.payment_status_id != params[:new_status_id]
				@company.payment_status_id = params[:new_status_id]
			end

			@company.save

			redirect_to :action => 'manage_company', :id => @company.id
		else
			redirect_to :action => 'new_payment', :id => @company.id, :alert => 'Ocurrió un error al ingresar el pago.'
		end
	end


	def payment

		@record = BillingRecord.find(params[:id])
		@company = @record.company

	end

	def delete_payment
		@record = BillingRecord.find(params[:record_id])
		@company = Company.find(params[:id])
		if @record.delete
			flash[:success] = 'Pago eliminado correctamente.'
			redirect_to :action => 'manage_company', :id => @company.id
		else
			flash[:error] = 'Ocurrió un error al eliminar el pago.'
			redirect_to :action => 'manage_company', :id => @company.id
		end
	end

	def modify_payment

		@record = BillingRecord.find(params[:id])
		if params[:amount].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			@record.amount = params[:amount].to_f
		end
		if params[:date] != ""
			date = Date.parse(params[:date])
			@record.date = date
		end
		@record.transaction_type_id = params[:transaction_type_id]
		@company = @record.company

		if @record.save
			if @company.plan.id != params[:new_plan_id]
				@company.plan_id = params[:new_plan_id]
			end
			if params[:new_due] != ""
				@company.due_amount = params[:new_due].to_f
			end
			if params[:new_months] != ""
				@company.months_active_left = params[:new_months].to_f
			end
			if @company.payment_status_id != params[:new_status_id]
				@company.payment_status_id = params[:new_status_id]
			end
			@company.save
			redirect_to :action => 'manage_company', :id => @company.id
		else
			redirect_to :action => 'payment', :id => @record.id, :alert => 'Ocurrió un error al modificar el pago.'
		end

	end


	#SuperAdmin
	def update_company

		@company = Company.find(params[:id])

		log_details = ""

		if @company.payment_status_id != params[:new_payment_status_id].to_i
			log_details += " Estado: " + @company.payment_status.name + " a " + PaymentStatus.find(params[:new_payment_status_id]).name + "."
		end

		if @company.payment_status_id != PaymentStatus.find_by_name("Inactivo").id
			@company.active = true
		else
			@company.active = false
		end

		if @company.sales_user_id != params[:sales_user_id].to_i
			if !@company.sales_user_id.nil? && !params[:sales_user_id].blank?
				log_details += " Usuario Ventas: " + User.find(@company.sales_user_id).full_name + " a " + User.find(params[:sales_user_id]).full_name + "."
			elsif @company.sales_user_id.nil? && !params[:sales_user_id].blank?
				log_details += " Usuario Ventas: Sin asignar a " + User.find(params[:sales_user_id]).full_name + "."
			elsif !@company.sales_user_id.nil? && params[:sales_user_id].blank?
				log_details += " Usuario Ventas: " + User.find(@company.sales_user_id).full_name + " a Sin asignar."
			end

		end

		if @company.plan_id != params[:new_plan_id].to_i
			log_details += " Plan: " + @company.plan.name + " a " + Plan.find(params[:new_plan_id]).name + "."
		end

		if @company.default_plan_id != params[:new_default_plan_id].to_i && !params[:new_default_plan_id].blank?
			log_details += " Plan por defecto: " + @company.default_plan.name + " a " + Plan.find(params[:new_default_plan_id]).name + "."
		end

		@company.payment_status_id = params[:new_payment_status_id]
		@company.sales_user_id = params[:sales_user_id]
		@company.plan_id = params[:new_plan_id]
		@company.default_plan_id = params[:new_default_plan_id]
		if params[:new_due_amount].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			if @company.due_amount != params[:new_due_amount].to_f
				log_details += " Deuda: " + @company.due_amount.to_s + " a " + params[:new_due_amount].to_s + "."
			end
			@company.due_amount = params[:new_due_amount]
		end
		if params[:new_months_active_left].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			if @company.months_active_left != params[:new_months_active_left].to_i
				log_details += " Meses restantes: " + @company.months_active_left.to_s + " a " + params[:new_months_active_left].to_s + "."
			end
			@company.months_active_left = params[:new_months_active_left]
		end
		if params[:new_online_payment_commission].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			if @company.company_setting.online_payment_commission != params[:new_online_payment_commission].to_f
				log_details += " Comisión pago en línea: " + @company.company_setting.online_payment_commission.to_s + "% a " + params[:new_online_payment_commission].to_s + "%."
			end
			@company.company_setting.online_payment_commission = params[:new_online_payment_commission].to_f
			@company.company_setting.save
		end
		if params[:new_promo_commission].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			if @company.company_setting.promo_commission != params[:new_promo_commission].to_f
				log_details += " Comisión promociones: " + @company.company_setting.promo_commission.to_s + "% a " + params[:new_promo_commission].to_s + "%."
			end
			@company.company_setting.promo_commission = params[:new_promo_commission].to_f
			@company.company_setting.save
		end
		if params[:new_base_price].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			if @company.company_plan_setting.base_price != params[:new_base_price].to_f
				log_details += " Precio base: " + @company.company_plan_setting.base_price.to_s + " a " + params[:new_base_price].to_s + "."
			end
			@company.company_plan_setting.base_price = params[:new_base_price].to_f
			@company.company_plan_setting.save
		end
		if params[:new_locations_multiplier].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			if @company.company_plan_setting.locations_multiplier != params[:new_locations_multiplier].to_f
				log_details += " Multiplicador: " + @company.company_plan_setting.locations_multiplier.to_s + " a " + params[:new_locations_multiplier].to_s + "."
			end
			@company.company_plan_setting.locations_multiplier = params[:new_locations_multiplier].to_f
			@company.company_plan_setting.save
		end
		if params[:new_mails_base_capacity].match(/\A[+-]?\d+?(_?\d+)*(\.\d+e?\d*)?\Z/) != nil
			if @company.company_setting.mails_base_capacity != params[:new_mails_base_capacity].to_i
				log_details += " Mails base: " + @company.company_setting.mails_base_capacity.to_s + " a " + params[:new_mails_base_capacity].to_s + "."
			end
			@company.company_setting.mails_base_capacity = params[:new_mails_base_capacity].to_i
			@company.company_setting.save
		end

		opc_checker = (params[:new_online_payment_capable].to_i == 1)
		poc_checker = (params[:new_promo_offerer_capable].to_i == 1)
		if @company.company_setting.online_payment_capable != opc_checker
			log_details += " Pago en línea: " + @company.company_setting.online_payment_capable.to_s + " a " + opc_checker.to_s + "."
		end

		if @company.company_setting.promo_offerer_capable != poc_checker
			log_details += " Promociones: " + @company.company_setting.promo_offerer_capable.to_s + " a " + poc_checker.to_s + "."
		end

		@company.company_setting.online_payment_capable = params[:new_online_payment_capable]
		@company.company_setting.promo_offerer_capable = params[:new_promo_offerer_capable]
		@company.company_setting.save

		if @company.company_setting.promo_time.nil?
			promo_time = PromoTime.new
			promo_time.company_setting_id = @company.company_setting.id
			promo_time.save
		end

		if @company.payment_status_id != PaymentStatus.find_by_name("Inactivo").id and @company.payment_status_id != PaymentStatus.find_by_name("Bloqueado").id
			@company.active = true
		else
			@company.active = false
		end

		if @company.save

			if log_details != ""
				SuperAdminLog.create(company_id: @company.id, user_id: current_user.id, detail: log_details)
			end

			flash[:success] = 'Companía editada correctamente.'
			redirect_to :action => 'manage_company', :id => @company.id
		else
			flash[:error] = 'Ocurrió un error al editar la compañía.'
			redirect_to :action => 'manage_company', :id => @company.id
		end

	end

	#SuperAdmin
	#Return a hash of incomes per month
	def get_year_incomes

		@incomes = Hash.new

		total = 0
		year = params[:year].to_i

		for i in 1..13 do
			@incomes[i] = Hash.new
			@incomes[i]['month'] = ""
			@incomes[i]['income'] = 0
		end

		@incomes[1]['month'] = "Enero"
		@incomes[2]['month'] = "Febrero"
		@incomes[3]['month'] = "Marzo"
		@incomes[4]['month'] = "Abril"
		@incomes[5]['month'] = "Mayo"
		@incomes[6]['month'] = "Junio"
		@incomes[7]['month'] = "Julio"
		@incomes[8]['month'] = "Agosto"
		@incomes[9]['month'] = "Septiembre"
		@incomes[10]['month'] = "Octubre"
		@incomes[11]['month'] = "Noviembre"
		@incomes[12]['month'] = "Diciembre"

		@company = Company.find(params[:id])
		for i in 1..12 do

			month_income = 0

			start_date = DateTime.new(year, i, 1)
			end_date = start_date
			if i < 12
				end_date = DateTime.new(year, i+1, 1)-1.minutes
			else
				end_date = DateTime.new(year+1, 1, 1)-1.minutes
			end

			billing_logs = BillingLog.where.not(transaction_type_id: TransactionType.find_by_name("Transferencia Formulario").id).where('company_id = ? and created_at BETWEEN ? and ?', @company.id, start_date, end_date).where(:trx_id => PuntoPagosConfirmation.where(:response => "00").pluck(:trx_id))

			billing_records = BillingRecord.where('company_id = ? and date BETWEEN ? and ?', @company.id, start_date, end_date)

			transfers = @company.billing_wire_transfers.where(approved: true).where('payment_date BETWEEN ? and ?', start_date, end_date)

			month_income += billing_logs.sum(:payment)
			month_income += billing_records.sum(:amount)
			month_income += transfers.sum(:amount)

			total += billing_logs.sum(:payment)
			total += billing_records.sum(:amount)
			total += transfers.sum(:amount)

			# billing_logs.each do |bl|
			# 	month_income = month_income + bl.payment
			# 	total = total + bl.payment
			# end
			# billing_records.each do |br|
			# 	month_income = month_income + br.amount
			# 	total = total + br.amount
			# end

			@incomes[i]['income'] = month_income

		end
		@incomes[13]['month'] = 'Total'
		@incomes[13]['income'] = total

		render :json => @incomes

	end

	#SuperAdmin
	def get_year_bookings
		@bookings = Hash.new

		total = 0
		year = params[:year].to_i

		for i in 1..13 do
			@bookings[i] = Hash.new
			@bookings[i]['month'] = ""
			@bookings[i]['count'] = 0
		end

		@bookings[1]['month'] = "Enero"
		@bookings[2]['month'] = "Febrero"
		@bookings[3]['month'] = "Marzo"
		@bookings[4]['month'] = "Abril"
		@bookings[5]['month'] = "Mayo"
		@bookings[6]['month'] = "Junio"
		@bookings[7]['month'] = "Julio"
		@bookings[8]['month'] = "Agosto"
		@bookings[9]['month'] = "Septiembre"
		@bookings[10]['month'] = "Octubre"
		@bookings[11]['month'] = "Noviembre"
		@bookings[12]['month'] = "Diciembre"

		@company = Company.find(params[:id])

		for i in 1..12 do

			month_bookings = 0

			start_date = DateTime.new(year, i, 1)
			end_date = start_date
			if i < 12
				end_date = DateTime.new(year, i+1, 1)-1.minutes
			else
				end_date = DateTime.new(year+1, 1, 1)-1.minutes
			end


			month_bookings = Booking.where('start BETWEEN ? and ?', start_date, end_date).where(:location_id => @company.locations.pluck(:id)).count


			@bookings[i]['count'] = month_bookings
			total = total + month_bookings

		end

		@bookings[13]['count'] = total
		@bookings[13]['month'] = "Total"

		render :json => @bookings

	end

	#SuperAdmin
	def incomes

		# @companies = Company.where(active: true).where.not(payment_status_id: PaymentStatus.find_by_name('Inactivo').id).order(:name)

		@filter = "all"
		@companies = Company.all.order(:name)
		if(!params[:filter].blank?)
			if params[:filter] == "active"
				@filter = "active"
				@companies = @companies.where(active: true)
			elsif params[:filter] == "inactive"
				@filter = "inactive"
				@companies.where(active: false)
			end
		end

		@year = DateTime.now.year.to_i
		if params[:year]
			@year = params[:year].to_i
		end

		@incomes = Hash.new
		for i in 1..13
			@incomes[i] = Hash.new
			@incomes[i]['month'] = ""
			@incomes[i]['income'] = 0
		end

		@incomes[1]['month'] = "Enero"
		@incomes[2]['month'] = "Febrero"
		@incomes[3]['month'] = "Marzo"
		@incomes[4]['month'] = "Abril"
		@incomes[5]['month'] = "Mayo"
		@incomes[6]['month'] = "Junio"
		@incomes[7]['month'] = "Julio"
		@incomes[8]['month'] = "Agosto"
		@incomes[9]['month'] = "Septiembre"
		@incomes[10]['month'] = "Octubre"
		@incomes[11]['month'] = "Noviembre"
		@incomes[12]['month'] = "Diciembre"

	end

	#SuperAdmin
	def monthly_bookings

		@year = DateTime.now.year.to_i
		if params[:year]
			@year = params[:year].to_i
		end

		#start_date = DateTime.new(@year, 1, 1)
		#end_date = DateTime.new(@year+1, 1, 1) -1.minutes

		@companies = Company.all.order(:name)
		#.where(:id => Location.where('created_at BETWEEN ? and ?', start_date, end_date).pluck('company_id'))

		@bookings = Hash.new
		for i in 1..13
			@bookings[i] = Hash.new
			@bookings[i]['month'] = ""
			@bookings[i]['count'] = 0
			@bookings[i]['web'] = 0
		end

		@bookings[1]['month'] = "Enero"
		@bookings[2]['month'] = "Febrero"
		@bookings[3]['month'] = "Marzo"
		@bookings[4]['month'] = "Abril"
		@bookings[5]['month'] = "Mayo"
		@bookings[6]['month'] = "Junio"
		@bookings[7]['month'] = "Julio"
		@bookings[8]['month'] = "Agosto"
		@bookings[9]['month'] = "Septiembre"
		@bookings[10]['month'] = "Octubre"
		@bookings[11]['month'] = "Noviembre"
		@bookings[12]['month'] = "Diciembre"

		@cat_bookings = Hash.new
		for i in 1..13
			@cat_bookings[i] = Hash.new
			@cat_bookings[i]['month'] = ""
			@cat_bookings[i]['count'] = 0
			@cat_bookings[i]['web'] = 0
		end

		@cat_bookings[1]['month'] = "Enero"
		@cat_bookings[2]['month'] = "Febrero"
		@cat_bookings[3]['month'] = "Marzo"
		@cat_bookings[4]['month'] = "Abril"
		@cat_bookings[5]['month'] = "Mayo"
		@cat_bookings[6]['month'] = "Junio"
		@cat_bookings[7]['month'] = "Julio"
		@cat_bookings[8]['month'] = "Agosto"
		@cat_bookings[9]['month'] = "Septiembre"
		@cat_bookings[10]['month'] = "Octubre"
		@cat_bookings[11]['month'] = "Noviembre"
		@cat_bookings[12]['month'] = "Diciembre"

	end

	#CSV generation
	def get_monthly_bookings
		filename = params[:type] + "_" + params[:subtype]
		year = params[:year]
		filename = filename + "_" + year + ".csv"

	    send_data Booking.generate_csv(params[:type], params[:subtype], params[:year]), filename: filename

	end

	#SuperAdmin
	def locations

		@year = DateTime.now.year.to_i
		if params[:year]
			@year = params[:year].to_i
		end

		@companies_arr = Array.new

		for i in 1..12
			@companies_arr[i] = Hash.new
			@companies_arr[i]['month'] = ""

			start_date = DateTime.new(@year, i, 1)
			end_date = start_date
			if i < 12
				end_date = DateTime.new(@year, i+1, 1)-1.minutes
			else
				end_date = DateTime.new(@year+1, 1, 1)-1.minutes
			end

			@companies_arr[i]['companies'] = Company.where('created_at BETWEEN ? and ?', start_date, end_date).order(:name)
		end

		@companies_arr[1]['month'] = "Enero"
		@companies_arr[2]['month'] = "Febrero"
		@companies_arr[3]['month'] = "Marzo"
		@companies_arr[4]['month'] = "Abril"
		@companies_arr[5]['month'] = "Mayo"
		@companies_arr[6]['month'] = "Junio"
		@companies_arr[7]['month'] = "Julio"
		@companies_arr[8]['month'] = "Agosto"
		@companies_arr[9]['month'] = "Septiembre"
		@companies_arr[10]['month'] = "Octubre"
		@companies_arr[11]['month'] = "Noviembre"
		@companies_arr[12]['month'] = "Diciembre"

	end

	#SuperAdmin
	def monthly_locations

		#@companies = Company.all.order(:name)

		@year = DateTime.now.year.to_i
		if params[:year]
			@year = params[:year].to_i
		end

		start_date = DateTime.new(@year, 1, 1)
		end_date = DateTime.new(@year+1, 1, 1) -1.minutes

		@companies = Company.where(:id => Location.where('created_at BETWEEN ? and ?', start_date, end_date).pluck('company_id'))

		@locations = Hash.new
		for i in 1..13
			@locations[i] = Hash.new
			@locations[i]['month'] = ""
			@locations[i]['count'] = 0
		end

		@locations[1]['month'] = "Enero"
		@locations[2]['month'] = "Febrero"
		@locations[3]['month'] = "Marzo"
		@locations[4]['month'] = "Abril"
		@locations[5]['month'] = "Mayo"
		@locations[6]['month'] = "Junio"
		@locations[7]['month'] = "Julio"
		@locations[8]['month'] = "Agosto"
		@locations[9]['month'] = "Septiembre"
		@locations[10]['month'] = "Octubre"
		@locations[11]['month'] = "Noviembre"
		@locations[12]['month'] = "Diciembre"

	end


	def deactivate_company
		@company = Company.find(params[:id])
		@company.active = false
		# @company.due_amount = 0
		@company.months_active_left = 0
		@company.payment_status_id = PaymentStatus.find_by_name("Inactivo").id
		if @company.save
			flash[:success] = 'Companía editada correctamente.'
			redirect_to :action => 'manage_company', :id => @company.id
		else
			flash[:error] = 'Ocurrió un error al editar la compañía.'
			redirect_to :action => 'manage_company', :id => @company.id
		end
	end


	def activate
		@company.active = true
		@company.save
		redirect_to companies_path
	end

	def deactivate
		@company.active = false
		@company.save
		redirect_to companies_path
	end

	def add_month
		company = Company.find(params[:id])
		if company.payment_status == PaymentStatus.find_by_name("Trial")
			company.plan = Plan.where(custom: false, locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first
		end
        company.months_active_left += 1
        company.due_amount = 0.0
        company.due_date = nil
        company.payment_status_id = PaymentStatus.find_by_name("Activo").id
        if company.save
          CompanyCronLog.create(company_id: company.id, action_ref: 9, details: "OK add_admin_month")
          flash[:success] = 'Mes agregado exitosamente.'
          redirect_to edit_payment_company_path(company)
        else
          CompanyCronLog.create(company_id: company.id, action_ref: 9, details: "ERROR add_admin_month "+company.errors.full_messages.inspect)
          flash[:error] = 'Error al agregar mes.'
          redirect_to edit_payment_company_path(company)
        end
	end

	# GET /companies/1
	# GET /companies/1.json
	def show

	end

	# GET /companies/new
	def new
		@company = Company.new
		@user = User.new
	end

	# GET /companies/1/edit
	def edit
	end

	def edit_payment
	end

	# POST /companies
	# POST /companies.json
	def create
		@company = Company.new(company_params)
		@user = User.find(current_user.id)
		if @user.role_id != Role.find_by_name("Super Admin").id
			@company.payment_status_id = PaymentStatus.find_by_name("Trial").id
			@company.plan_id = Plan.find_by_name("Trial").id
		else
			@company.payment_status_id = PaymentStatus.find_by_name("Admin").id
			@company.plan_id = Plan.find_by_name("Admin").id
			@company.build_company_setting
			@company.company_setting.build_online_cancelation_policy
			@company.owned = false
		end

		respond_to do |format|
			if @company.save
				if @user.role_id != Role.find_by_name("Super Admin").id
					@user.company_id = @company.id
					@user.role_id = Role.find_by_name("Administrador General").id
					@user.save
				end
				format.html { redirect_to dashboard_path, notice: 'Empresa creada exitosamente.' }
				format.json { render action: 'show', status: :created, location: @company }
			else
				format.html { render action: 'add_company', layout: "search" }
				format.json { render json: @company.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /companies/1
	# PATCH/PUT /companies/1.json
	def update
		respond_to do |format|
			if @company.update(company_params)
				format.html { redirect_to edit_company_setting_path(@company.company_setting, anchor: 'company'), notice: 'Empresa actualizada exitosamente.' }
				format.json { head :no_content }
			else
				format.html { render 'company_settings/edit' }
				format.json { render json: @company.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /companies/1
	# DELETE /companies/1.json
	def destroy
		@company.destroy
		respond_to do |format|
			format.html { redirect_to companies_url }
			format.json { head :no_content }
		end
	end

	##### Workflow #####
	def overview
		host = request.host_with_port
		domain = host[host.index(request.domain)..host.length]

		@company = CompanyCountry.find_by(web_address: request.subdomain, country_id: Country.find_by(locale: I18n.locale.to_s)) ? CompanyCountry.find_by(web_address: request.subdomain, country_id: Country.find_by(locale: I18n.locale.to_s)).company : nil
		if @company.nil?
			@company = CompanyCountry.find_by(web_address: request.subdomain.gsub(/www\./i, ''), country_id: Country.find_by(locale: I18n.locale.to_s)) ? CompanyCountry.find_by(web_address: request.subdomain.gsub(/www\./i, ''), country_id: Country.find_by(locale: I18n.locale.to_s)).company : nil
			if @company.nil?
				flash[:alert] = "No existe la compañia buscada."

				redirect_to root_url(:host => domain)
				return
			end
		end

		if @company.plan_id == Plan.find_by_name("Gratis").id
	  		redirect_to root_url(:host => domain), alert: "Esta compañía no tiene minisitio."
	  		return
	  	end

		@locations = Location.actives.where(online_booking: true, country_id: Country.find_by(locale: I18n.locale.to_s), company_id: @company.id).where(id: ServiceProvider.actives.where(company_id: @company.id, online_booking: true).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, company_id: @company.id, online_booking: true).pluck(:id)).pluck(:location_id).uniq).joins(:location_times).ordered

		unless @company.company_setting.activate_workflow && @company.active && @locations.uniq.count > 0
			flash[:alert] = "Lo sentimos, el mini-sitio que estás buscando no se encuentra disponible."

			redirect_to root_url(:host => domain)
			return
		end

		@locations = @locations.group("locations.id")

		@has_images = false
		@locations.each do |location|
			tmp = !(location.image1.url.include? "rectangulo_gris.png") || !(location.image2.url.include? "rectangulo_gris.png") || !(location.image3.url.include? "rectangulo_gris.png")
			@has_images = tmp && @has_images
		end

		# => Domain parser
		@url = @company.company_countries.find_by(country_id: Country.find_by(locale: I18n.locale.to_s)).web_address + '.' + host[host.index(request.domain)..host.length] + '/' + I18n.locale.to_s

		#Selected local from fase II
		if(params[:local])
			@selectedLocal = params[:local]
			if Location.where(:id => @selectedLocal).count > 0
				@selectedLocation = Location.find(@selectedLocal)
			else
				flash[:alert] = "Lo sentimos, el local ingresado no existe."
			end
		else
			@selectedLocation = @locations.first
			@selectedLocal = @selectedLocation.id
		end

		if mobile_request?
			@url = @company.company_countries.find_by(country_id: Country.find_by(locale: I18n.locale.to_s)).web_address + '.' + host[host.index(request.domain)..host.length]
			if params[:local]
				redirect_to workflow_path(:local => params[:local])
				return
			else
				if @locations.length == 1
					redirect_to workflow_path(:local => @locations[0].id)
					return
				end
			end
		end
		render layout: "workflow"
	end

	def workflow
		@company = CompanyCountry.find_by(web_address: request.subdomain, country_id: Country.find_by(locale: I18n.locale.to_s)) ? CompanyCountry.find_by(web_address: request.subdomain, country_id: Country.find_by(locale: I18n.locale.to_s)).company : nil
		if @company.nil?
			@company = CompanyCountry.find_by(web_address: request.subdomain.gsub(/www\./i, ''), country_id: Country.find_by(locale: I18n.locale.to_s)) ? CompanyCountry.find_by(web_address: request.subdomain.gsub(/www\./i, ''), country_id: Country.find_by(locale: I18n.locale.to_s)).company : nil
			if @company.nil?
				flash[:alert] = "No existe la compañia buscada."

				host = request.host_with_port
				domain = host[host.index(request.domain)..host.length]

				redirect_to root_url(:host => domain)
				return
			end
		end

		if @company.plan_id == Plan.find_by_name("Gratis").id
      		redirect_to localized_root_path, error: "Esta compañía no tiene minisitio."
      		return
    	end

		unless @company.company_setting.activate_workflow && @company.active
			flash[:alert] = "Lo sentimos, el mini-sitio que estás buscando no se encuentra disponible."

			host = request.host_with_port
			domain = host[host.index(request.domain)..host.length]

			redirect_to root_url(:host => domain)
			return
		end


		# => Domain parser
		host = request.host_with_port
		@url = @company.company_countries.find_by(country_id: Country.find_by(locale: I18n.locale.to_s)).web_address + '.' + host[host.index(request.domain)..host.length]

		if Location.where(:id => params[:local]).count > 0
			@location = Location.find(params[:local])
			@selectedLocation = @location
		else
			flash[:alert] = "Lo sentimos, el local ingresado no existe."
			redirect_to :action => "overview"
			return
		end

		@online_payment_capable = @company.company_setting.online_payment_capable
		@promo_offerer_capable = @company.company_setting.promo_offerer_capable

		if mobile_request?
			company_setting = @company.company_setting
			now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
			@before_now = (now + company_setting.before_booking / 24.0).rfc2822
			@after_now = (now + company_setting.after_booking * 30).rfc2822
		end

		render layout: 'workflow'
	end

	##### Workflow - Mobile #####
	def select_hour

		if params[:location].blank?
			flash[:alert] = "Lo sentimos, el local ingresado no existe."
			redirect_to :action => "overview"
			return

		elsif params[:serviceStaff].blank? or params[:datepicker].blank?
			flash[:error] = "Error ingresando los datos."
			redirect_to workflow_path(:local => params[:location])
			return
		end
		serviceStaffAux = JSON.parse(params[:serviceStaff], symbolize_names: true)
		serviceStaff = JSON.parse(params[:serviceStaff], symbolize_names: true)
		if serviceStaffAux[0][:bundle] || serviceStaffAux[0][:bundle] == "true"
			bundle = Bundle.find(serviceStaffAux[0][:service])
			if Location.find(params[:location]).company_id != bundle.company_id
				flash[:error] = "Error ingresando los datos."
				redirect_to workflow_path(:local => params[:location])
				return
			end
			services = bundle.services.includes(:service_bundles).order('service_bundles.order asc')
			serviceStaff = []
			services.each do |service|
				serviceStaff << { :service => service.id.to_s, :provider => (serviceStaffAux[0][:provider] == "0" || !ServiceStaff.where(service_id: serviceStaffAux[0][:service]).pluck(:service_provider_id).include?(serviceStaffAux[0][:provider].to_i) ? "0" : serviceStaffAux[0][:service]), :bundle => bundle.id }
			end
		else
			if Location.find(params[:location]).company_id != Service.find(serviceStaffAux[0][:service]).company_id
				flash[:error] = "Error ingresando los datos."
				redirect_to workflow_path(:local => params[:location])
				return
			end
		end

		@mandatory_discount = false
		@is_session_booking = false

		mobile_hours(serviceStaff)
		render layout: 'workflow'

		rescue ActionView::MissingTemplate => e
			redirect_to :action => "overview"
			return

	end

	def select_promo_hour

		if params[:location].blank?
			flash[:alert] = "Lo sentimos, el local ingresado no existe."
			redirect_to :action => "overview"
			return

		elsif params[:serviceStaff].blank? or params[:datepicker].blank?
			flash[:error] = "Error ingresando los datos."
			redirect_to workflow_path(:local => params[:location])
			return
		end

		serviceStaffAux = JSON.parse(params[:serviceStaff], symbolize_names: true)
		serviceStaff = JSON.parse(params[:serviceStaff], symbolize_names: true)
		if serviceStaffAux[0][:bundle] || serviceStaffAux[0][:bundle] == "true"
			bundle = Bundle.find(serviceStaffAux[0][:service])
			if Location.find(params[:location]).company_id != bundle.company_id
				flash[:error] = "Error ingresando los datos."
				redirect_to workflow_path(:local => params[:location])
				return
			end
			services = bundle.services.includes(:service_bundles).order('service_bundles.order asc')
			serviceStaff = []
			services.each do |service|
				serviceStaff << { :service => service.id.to_s, :provider => (serviceStaffAux[0][:provider] == "0" || !ServiceStaff.where(service_id: serviceStaffAux[0][:service]).pluck(:service_provider_id).include?(serviceStaffAux[0][:provider].to_i) ? "0" : serviceStaffAux[0][:service]), :bundle => bundle.id }
			end
		else
			if Location.find(params[:location]).company_id != Service.find(serviceStaffAux[0][:service]).company_id
				flash[:error] = "Error ingresando los datos."
				redirect_to workflow_path(:local => params[:location])
				return
			end
		end

		@mandatory_discount = true
		@is_session_booking = false

		mobile_hours(serviceStaff)
		render layout: 'workflow'

		rescue ActionView::MissingTemplate => e
			redirect_to :action => "overview"
			return

	end

	def select_session_hour

		if params[:location].blank?
			flash[:alert] = "Lo sentimos, el local ingresado no existe."
			redirect_to :action => "overview"
			return

		elsif params[:serviceStaff].blank? or params[:datepicker].blank?
			flash[:error] = "Error ingresando los datos."
			redirect_to workflow_path(:local => params[:location])
			return
		end

		@booking = Booking.find(params[:booking_id])

		@mandatory_discount = false
		@is_session_booking = true

		mobile_hours

		respond_to do |format|
	      format.html { render :partial => 'select_session_hour' }
	      format.json { render json: @available_time }
	    end

	end



	def user_data
		if params[:location].blank?
			flash[:alert] = "Lo sentimos, el local ingresado no existe."
			redirect_to :action => "overview"
			return
		elsif params[:service].blank? or params[:staff].blank? or params[:start].blank? or params[:end].blank? or params[:time_discount].blank? or params[:discount].blank? or params[:service_promo_id].blank? or params[:origin].blank? or params[:provider_lock].blank?
			flash[:error] = "Error ingresando los datos."
			redirect_to workflow_path(:local => params[:location])
			return
		end
		@location = Location.find(params[:location])
		@company = @location.company
		@service = Service.find(params[:service])
		@provider = ServiceProvider.find(params[:staff])
		@start = params[:start]
		@end = params[:end]
		@origin = params[:origin]
		@lock = params[:provider_lock]

		@bookings = params[:bookings]

		@has_time_discount = false
		if params[:has_time_discount] && (params[:has_time_discount] == true || params[:has_time_discount] == "true")
			@has_time_discount = true
		end
		@time_discount = params[:time_discount]
		@has_discount = false
		if params[:has_discount] && (params[:has_discount] == true || params[:has_discount] == "true")
			@has_discount = true
		end
		@discount = params[:discount]

		@online_payable = false
		@is_time_discount = false
		@must_be_paid_online = false
		@hour_discount = 0

		logger.debug "service online_payable: " + @service.online_payable.to_s
		logger.debug "online_payment_capable: " + @company.company_setting.online_payment_capable.to_s
		logger.debug "allows_online_payment: " + @company.company_setting.allows_online_payment.to_s

		if @service.online_payable && @company.company_setting.online_payment_capable && @company.company_setting.allows_online_payment
			@online_payable = true
		end

		if @has_time_discount || @has_discount

			@online_payable = true
			@must_be_paid_online = true
			@has_discount = true

			if @has_time_discount
				@is_time_discount = true
				@hour_discount = @time_discount.to_f
			else
				@hour_discount = @discount.to_f
			end

		end

		logger.debug "online_payable" + @online_payable.to_s

		@service_promo_id = params[:service_promo_id]

		render layout: 'workflow'
		rescue ActionView::MissingTemplate => e
			redirect_to :action => "overview"
	end

	def add_company
		if current_user.company_id
			redirect_to dashboard_path
			return
		end
		@company = Company.new
		@banks = Bank.all
		render :layout => 'login'
	end

	def check_company_web_address
		@company_country = CompanyCountry.find_by(web_address: params[:web_address], country_id: params[:country_id])
		render :json => @company_country.nil?
	end

	def get_link
		@web_address = current_user.company.company_countries.find_by(country_id: Country.find_by(locale: I18n.locale.to_s)).web_address
	end

	def inventory

		if current_user.role_id != Role.find_by_name("Administrador General").id
			errors = ['No tienes suficientes privilegios para ver esta página.']
			format.html { redirect_to products_path, alert: 'No tienes suficientes privilegios para ver esta página.' }
        	format.json { render :json => { :errors => errors }, :status => 422 }
        	return
		end

		@company = current_user.company
		@products = []

		normalized_search = ""

	    if !params[:searchInput].blank?
	      search = params[:searchInput].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

	      normalized_search = search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s
	    end

	    products = nil

	    if normalized_search != ""
	      products = @company.products.search(normalized_search)
	    else
	      products = @company.products
	    end

		if params[:category] != "0" && params[:brand] != "0" && params[:display] != "0"
			@products = products.where(:product_category_id => params[:category], :product_brand_id => params[:brand], :product_display_id => params[:display]).joins(:product_categories).order(name: :asc).joins(:product_category).order('product_categories.name asc').joins(:product_brand).order('product_brands.name asc').order(name: :asc)
		elsif params[:category] != "0" && params[:brand] != "0" && params[:display] == "0"
			@products = products.where(:product_category_id => params[:category], :product_brand_id => params[:brand]).joins(:product_category).order('product_categories.name asc').joins(:product_brand).order('product_brands.name asc').order(name: :asc)
		elsif params[:category] != "0" && params[:brand] == "0" && params[:display] != "0"
			@products = products.where(:product_category_id => params[:category], :product_display_id => params[:display]).joins(:product_category).order('product_categories.name asc').joins(:product_brand).order('product_brands.name asc').order(name: :asc)
		elsif params[:category] != "0" && params[:brand] == "0" && params[:display] == "0"
			@products = products.where(:product_category_id => params[:category]).joins(:product_category).order('product_categories.name asc').joins(:product_brand).order('product_brands.name asc').order(name: :asc)
		elsif params[:category] == "0" && params[:brand] != "0" && params[:display] != "0"
			@products = products.where(:product_brand_id => params[:brand], :product_display_id => params[:display]).joins(:product_category).order('product_categories.name asc').joins(:product_brand).order('product_brands.name asc').order(name: :asc)
		elsif params[:category] == "0" && params[:brand] != "0" && params[:display] == "0"
			@products = products.where(:product_brand_id => params[:brand]).joins(:product_category).order('product_categories.name asc').joins(:product_brand).order('product_brands.name asc').order(name: :asc)
		elsif params[:category] == "0" && params[:brand] == "0" && params[:display] != "0"
			@products = products.where(:product_display_id => params[:display]).joins(:product_category).order('product_categories.name asc').joins(:product_brand).order('product_brands.name asc').order(name: :asc)
		else
			@products = products.joins(:product_category).order('product_categories.name asc').joins(:product_brand).order('product_brands.name asc').order(name: :asc)
		end

    respond_to do |format|
      format.html { render :partial => 'inventory' }
      format.json { render :json => @products }
    end

	end

	def stock_alarm_form

		if current_user.role_id != Role.find_by_name("Administrador General").id
			errors = ['No tienes suficientes privilegios para ver esta página.']
			format.html { redirect_to products_path, alert: 'No tienes suficientes privilegios para ver esta página.' }
        	format.json { render :json => { :errors => errors }, :status => 422 }
        	return
		end

		@stock_alarm_settings = StockAlarmSetting.where(location_id: current_user.company.locations.where(:active => true).pluck(:id))
		respond_to do |format|
	      format.html { render :partial => 'stock_alarm_form' }
	      format.json { render :json => @locations }
	    end
	end

	def get_employee_codes_by_code
		@employee_code = EmployeeCode.find_by_code(params[:employee_code_code])
		render :json => @employee_code
	end

	#Company files that are not associated against any client
	def files

		@company = current_user.company

		s3 = Aws::S3::Client.new
	    resp = s3.list_objects(bucket: ENV['S3_BUCKET'], prefix: 'companies/' +  @company.id.to_s + '/', delimiter: '/')

	    @s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

	    folders_prefixes = resp.common_prefixes
	    @folders = []

	    folders_prefixes.each do |folder|
	      sub_str = folder.prefix[0, folder.prefix.rindex("/")]
	      @folders << sub_str[sub_str.rindex("/") + 1, sub_str.length]
	    end

	end

	#Creates an empty key to late folder
	#Should be deleted once a file is written to that folder
	#When deleting all folder files, should be recreated
	def create_folder

		@company = current_user.company

		full_name = 'companies/' +  @company.id.to_s + '/' + params[:folder_name] + '/'

		#s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])
		s3 = Aws::S3::Client.new
		s3.put_object(bucket: ENV['S3_BUCKET'], key: full_name)
    	#obj = s3_bucket.object(full_name)

    	redirect_to '/get_company_files', notice: 'Carpeta creada correctamente'

	end

	def rename_folder

		@company = current_user.company

		new_folder_name = params[:new_folder_name]
		old_folder_name = params[:old_folder_name]

		#Do nothing if same folder
	    if new_folder_name == old_folder_name
	      redirect_to '/get_company_files', notice: 'Carpeta renombrada correctamente'
	      return
	    end

		s3 = Aws::S3::Client.new

		old_folder_path = 'companies/' +  @company.id.to_s + '/' + old_folder_name + '/'
		new_folder_path = 'companies/' +  @company.id.to_s + '/' + new_folder_name + '/'

		#Create new folder in case there are no files
		s3.put_object(bucket: ENV['S3_BUCKET'], key: new_folder_path)

		s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

		#Move each object to new folder
		@company.company_files.where(folder: old_folder_name).each do |company_file|
			obj = s3_bucket.object(company_file.full_path)

			obj_name = obj.key[obj.key.rindex("/")+1, obj.key.length]

			obj.move_to({bucket: ENV['S3_BUCKET'], key: new_folder_path + obj_name}, {acl: 'public-read', content_type: content_type})

			company_file.full_path = new_folder_path + obj_name
			company_file.public_url = obj.public_url
			company_file.folder = new_folder_name
			company_file.save

		end

		#Delete old folder
		old_folder = s3_bucket.object(old_folder_path)
		old_folder.delete

		redirect_to '/get_company_files', notice: 'Carpeta renombrada correctamente'

	end

	def delete_folder

		@company = current_user.company

		folder_name = params[:folder_name]

		s3 = Aws::S3::Client.new

		folder_path = 'companies/' +  @company.id.to_s + '/' + folder_name + '/'


		s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

		#Move each object to new folder
		@company.company_files.where(folder: folder_name).each do |company_file|

			company_file.destroy

		end

		#Delete old folder
		old_folder = s3_bucket.object(folder_path)
		if old_folder.exists?
			old_folder.delete
		end

		redirect_to '/get_company_files', notice: 'Carpeta eliminada correctamente'

	end

	def upload_file

		@company = current_user.company

		if(params[:file].size/1000/1000 > 25)
	      	redirect_to '/get_company_files', alert: 'Tamaño de archivo no permitido'
	      	return
		end

	    file_name = params[:file_name]
	    folder_name = params[:folder_name]
	    logger.debug "File name: " + params[:file].original_filename
	    file_extension = params[:file].original_filename[params[:file].original_filename.rindex(".") + 1, params[:file].original_filename.length]
	    content_type = params[:file].content_type

	    file_description = ""
	    if !params[:file_description].blank?
	      file_description = params[:file_description]
	    end

	    if !params[:new_folder_name].blank? && folder_name == "select"
	      folder_name = params[:new_folder_name]
	    end

	    full_name = 'companies/' +  @company.id.to_s + '/' + folder_name + '/' + params[:file].original_filename

	    s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

	    old_obj = s3_bucket.object('companies/' +  @company.id.to_s + '/' + folder_name + '/')
    	old_obj.delete

	    obj = s3_bucket.object(full_name)

	    if !obj.exists?
	    	obj.upload_file(params[:file].path(), {acl: 'public-read', content_type: content_type})
	    else
	    	full_name = 'companies/' +  @company.id.to_s + '/' + folder_name + '/' + DateTime.now.to_i.to_s + '_' +  params[:file].original_filename
	    	obj = s3_bucket.object(full_name)
	    	obj.upload_file(params[:file].path(), {acl: 'public-read', content_type: content_type})
	    end

	    @company_file = CompanyFile.new(company_id: @company.id, name: file_name, full_path: full_name, public_url: obj.public_url, size: obj.size, description: file_description, folder: folder_name)


	    # Save the upload
	    if @company_file.save
	    	redirect_to '/get_company_files', notice: 'Archivo guardado correctamente'
	    else
	    	obj.delete
	      	redirect_to '/get_company_files', alert: 'No se pudo guardar el archivo'
	    end

	end

	def move_file

		@company = current_user.company
		@company_file = CompanyFile.find(params[:company_file_id])
		new_folder_name = params[:folder_name]

		#Do nothing if same folder
		if new_folder_name == @company_file.folder
			redirect_to '/get_company_files', notice: 'Archivo movido correctamente'
			return
		end

		new_folder_path = 'companies/' +  @company.id.to_s + '/' + new_folder_name + '/'

		s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

		obj = s3_bucket.object(@company_file.full_path)

		obj_name = obj.key[obj.key.rindex("/")+1, obj.key.length]

		obj.move_to({bucket: ENV['S3_BUCKET'], key: new_folder_path + obj_name}, {acl: 'public-read', content_type: content_type})

		old_folder_path = 'companies/' +  @company.id.to_s + '/' + @company_file.folder + '/'
    	old_folder_obj = s3_bucket.object(old_folder_path)

    	logger.debug "Path: " + old_folder_path
    	logger.debug "Exists? " + old_folder_obj.exists?.to_s

    	if !old_folder_obj.exists?
    		s3 = Aws::S3::Client.new
			s3.put_object(bucket: ENV['S3_BUCKET'], key: old_folder_path)
    	end

		@company_file.full_path = new_folder_path + obj_name
		@company_file.public_url = obj.public_url
		@company_file.folder = new_folder_name

		if @company_file.save
			redirect_to '/get_company_files', notice: 'Archivo movido correctamente'
	    else
	    	redirect_to '/get_company_files', alert: 'Error al mover el archivo'
		end

	end

	def edit_file

		@company = current_user.company
		@company_file = CompanyFile.find(params[:company_file_id])

		@company_file.name = params[:file_name]
		@company_file.description = params[:file_description]

		folder_name = params[:folder_name]

		if !params[:new_folder_name].blank? && folder_name == "select"
	      folder_name = params[:new_folder_name]
	    end

		if folder_name != @company_file.folder

			new_folder_name = folder_name

			new_folder_path = 'companies/' +  @company.id.to_s + '/' + new_folder_name + '/'

			s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

			obj = s3_bucket.object(@company_file.full_path)

			obj_name = obj.key[obj.key.rindex("/")+1, obj.key.length]

			obj.move_to({bucket: ENV['S3_BUCKET'], key: new_folder_path + obj_name}, {acl: 'public-read', content_type: content_type})

			old_folder_path = 'companies/' +  @company.id.to_s + '/' + @company_file.folder + '/'
	    	old_folder_obj = s3_bucket.object(old_folder_path)

	    	logger.debug "Path: " + old_folder_path
	    	logger.debug "Exists? " + old_folder_obj.exists?.to_s

	    	if !old_folder_obj.exists?
	    		s3 = Aws::S3::Client.new
				s3.put_object(bucket: ENV['S3_BUCKET'], key: old_folder_path)
	    	end


			@company_file.full_path = new_folder_path + obj_name
			@company_file.public_url = obj.public_url
			@company_file.folder = new_folder_name

		end

		if @company_file.save
			redirect_to '/get_company_files', notice: 'Archivo editado correctamente'
	    else
	    	redirect_to '/get_company_files', alert: 'Error al mover el archivo'
		end


	end


	def generate_clients_base

		@company = current_user.company

		#respond_to do |format|
	    #  format.xls {render xls: Client.generate_import_file(@company.id)}
	    #end

	    filepath = "#{Rails.root}/public/clients_files/importador_" + @company.id.to_s + "_" + DateTime.now.to_i.to_s + ".xls"
	 	Client.generate_import_file(@company.id, filepath)

	    send_file filepath, filename: "importador_clientes.xls"

		Company.delay(run_at: 2.hours.from_now).delete_booking_file(filepath)

	end

	def select_default_plan

		@company = Company.find(params[:company_id])
		@plan_id = params[:plan_id]
		@plan = Plan.find(@plan_id)

		@company.default_plan_id = @plan_id
		@company.company_plan_setting.base_price = @plan.plan_countries.find_by_country_id(@company.country.id).price

		if @company.save
			@company.company_plan_setting.save
			flash[:success] = 'Plan guardado correctamente. Puedes cambiarlo cuantas veces quieras hasta que acabe tu período de prueba.'
			redirect_to :action => 'select_plan', :controller => 'plans'
		else
			flash[:error] = 'Ocurrió un error al elegir el plan.'
			redirect_to :action => 'select_plan', :controller => 'plans'
		end

  	end

	private

		#Common method to obtain available hours
		def mobile_hours(serviceStaff)

		    require 'date'

		    parser = PostgresParser.new

		    local = Location.find(params[:location])
		    company_setting = local.company.company_setting
		    cancelled_id = Status.find_by(name: 'Cancelado').id
		    # serviceStaff = JSON.parse(params[:serviceStaff], symbolize_names: true)
		    now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
		    session_booking = nil
			@bundle = Bundle.find_by(id: serviceStaff[0][:bundle])

		    #if params[:session_booking_id] && params[:session_booking_id] != ""
		    #  session_booking = SessionBooking.find(params[:session_booking_id])
		    #end

		    if @is_session_booking
		    	session_booking = @booking.session_booking
		    end


		    if params[:datepicker] and params[:datepicker] != ""
		      if params[:datepicker].to_datetime > now
		        now = params[:datepicker].to_datetime
		      end
		    end

		    date = now
		    @date = Date.parse(params[:datepicker])

		    #logger.debug "now: " + now.to_s

		    days_ids = [1,2,3,4,5,6,7]
		    index = days_ids.find_index(now.cwday)
		    ordered_days = days_ids[index, days_ids.length] + days_ids[0, index]

		    book_index = 0
		    book_summaries = []

		    total_hours_array = []

		    loop_times = 0

		    max_time_diff = 0

		    #Save first service and it's providers for later use

		    first_service = Service.find(serviceStaff[0][:service])
		    first_providers = []
		    first_providers_ids = []
		    if serviceStaff[0][:provider] != "0"
		      first_providers << ServiceProvider.find(serviceStaff[0][:provider])
		      first_providers_ids << ServiceProvider.find(serviceStaff[0][:provider]).id
		    else
		      first_providers = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(:order, :public_name)
		      first_providers_ids = first_providers.pluck(:id)
		    end

		    #Look for services and providers and save them for later use.
		    #Also, save total services duration

		    total_services_duration = 0

		    #False if last tried block allocation failed.
		    #Used for searching gaps. They should be looked for only if last block culd be allocated,
		    #because if not, then there isn't anyway that coming back in time cause correct allocation.
		    last_check = false

		    #Checks if the block being allocated is from a gap
		    is_gap_hour = false

		    #Holds current_gap to sum a day's total gap and adjust calendar's height
		    current_gap = 0

		    services_arr = []
		    bundles_arr = []
		    providers_arr = []
		    services = []

		    for i in 0..serviceStaff.length-1
		      services_arr[i] = serviceStaff[i][:service].to_i
		      services << Service.find(services_arr[i])
		      bundles_arr[i] = serviceStaff[i][:bundle_id].nil? ? 0 : serviceStaff[i][:bundle_id].to_i
		      providers_arr[i] = serviceStaff[i][:provider].to_i
		    end

		    db_hours = []
		    pg_hours = []
		    company_id = local.company_id

		    booking_leap = 0
		    if providers_arr.count > 1
		      booking_leap = company_setting.booking_leap;
		    else
		      if providers_arr.count > 0
		          if providers_arr[0].to_i == 0
		            booking_leap = company_setting.booking_leap;
		          else
		            booking_leap = ServiceProvider.find(providers_arr[0]).booking_leap
		          end
		      end
		    end

		    #providers_arr = []
		    #for i
		    hours_array = []

		    after_date = DateTime.now + company_setting.after_booking.months

		    day = now.cwday
			dtp = local.location_times.where(day_id: day).order(:open).first

			if dtp.nil?
				if serviceStaff[0][:provider] == "0"
			    	@lock = false
			    else
			    	@lock = true
			    end

			    @lock
			    @company = local.company
			    @location = local
			    @serviceStaff = serviceStaff
			    @date = Date.parse(params[:datepicker])
			    @service = Service.find(serviceStaff[0][:service])

			    @available_time = hours_array
			    @bookSummaries = book_summaries
				return
			end

			dateTimePointer = dtp.open

			dateTimePointer = DateTime.new(now.year, now.mon, now.mday, dateTimePointer.hour, dateTimePointer.min)
			day_open_time = dateTimePointer

			dateTimePointerEnd = dateTimePointer


			if now > after_date
				if serviceStaff[0][:provider] == "0"
			    	@lock = false
			    else
			    	@lock = true
			    end

			    @lock
			    @company = local.company
			    @location = local
			    @serviceStaff = serviceStaff
			    @date = Date.parse(params[:datepicker])
			    @service = Service.find(serviceStaff[0][:service])

			    @available_time = hours_array
			    @bookSummaries = book_summaries
				return
			end


			day_close = local.location_times.where(day_id: day).order(:close).first.close
			limit_date = DateTime.new(now.year, now.mon, now.mday, day_close.hour, day_close.min)


			hours_array = []

			day = date.cwday
			dtp = local.location_times.where(day_id: day).order(:open).first
			loc_close = local.location_times.where(day_id: day).order(:close).last

			start_date = date.to_datetime.beginning_of_day
			end_date = DateTime.new(start_date.year, start_date.mon, start_date.mday, loc_close.close.hour, loc_close.close.min)

			ActiveRecord::Base.connection.execute("SELECT * FROM available_hours(#{company_id}, #{local.id}, ARRAY#{providers_arr}, ARRAY#{services_arr}, ARRAY#{bundles_arr}, '#{start_date}', '#{end_date}', false, ARRAY#{first_providers_ids})").each do |row|
				db_hours = parser.parse_pg_array(row["hour_array"])
				db_gap = row["positive_gap"].to_i
				###################
				## Hour creation ##
				###################


				#Create bookings array
				#If too slow, adapt views
				#Create
				bookings = []
				db_hours.each_with_index do |db_hour, index|
				  pg_hour = parser.parse_pg_array(db_hour)

				  #pg_hour array definitions
				  # 0: start_datetime
				  # 1: end_datetime
				  # 2: provider_id
				  # 3: provider_name
				  # 4: price
				  # 5: has_time_discount
				  # 6: time_discount
				  # 7: has_treatment_discount
				  # 8: treatment_discount
				  # 9: service_promo_id
				  # 10: treatment_promo_id

				  provider_lock = false
		          if providers_arr[index].to_i != 0
		            provider_lock = true
		          end

				  book_sessions_amount = 0
				  if services[index].has_sessions && services[index].sessions_amount > 0
				    book_sessions_amount = services[index].sessions_amount
				  end

				  bookings << {
				    :service => services[index].id,
				    :provider => pg_hour[2].to_i,
				    :start => pg_hour[0].to_datetime,
				    :end => pg_hour[1].to_datetime,
				    :service_name => services[index].name,
				    :provider_name => pg_hour[3],
				    :provider_lock => provider_lock,
				    :provider_id => pg_hour[2].to_i,
				    :price => services[index].price,
				    :online_payable => services[index].online_payable,
				    :has_discount => services[index].has_discount,
				    :discount => services[index].discount,
				    :show_price => services[index].show_price && (bundles_arr[index] == 0),
				    :has_time_discount => pg_hour[5] == "t" ? true : false,
				    :time_discount => pg_hour[6].to_f,
				    :has_treatment_discount => pg_hour[7] == "t" ? true : false,
				    :treatment_discount => pg_hour[8].to_f,
				    :service_promo_id => pg_hour[9].present? ? pg_hour[9].to_i : "0",
				    :treatment_promo_id => pg_hour[10].present? ? pg_hour[10].to_i : "0",
				    :has_sessions => services[index].has_sessions,
				    :sessions_amount => book_sessions_amount,
				    :must_be_paid_online => services[index].must_be_paid_online,
				    :bundled => @bundle.present?,
				    :bundle_id => @bundle.present? ? @bundle.id : nil
				  }

				end




				#Create hour and append to hours_array
				has_time_discount = false
				has_treatment_discount = false
				bookings_group_discount = 0
				bookings_group_total_price = 0
				bookings_group_computed_price = 0

				if bookings.first[:has_sessions]
				  if (bookings.first[:has_treatment_discount] && bookings.first[:treatment_discount] > 0) || (bookings.first[:has_discount] && bookings.first[:discount] > 0)
				    has_treatment_discount = true
				    if bookings.first[:has_treatment_discount] && !bookings.first[:has_discount]
				      bookings_group_discount = bookings.first[:treatment_discount]
				    elsif !bookings.first[:has_treatment_discount] && bookings.first[:has_discount]
				      bookings_group_discount = bookings.first[:discount]
				    else
				      if bookings.first[:treatment_discount] > bookings.first[:discount]
				        bookings_group_discount = bookings.first[:treatment_discount]
				      else
				        bookings_group_discount = bookings.first[:discount]
				      end
				    end
				  else
				    bookings_group_discount = 0
				  end
				  bookings_group_total_price = bookings.first[:price]
				  bookings_group_computed_price = bookings_group_total_price.to_f*(100.0 - bookings_group_discount.to_f)/100.0
				else
				  bookings.each do |b|
				    bookings_group_total_price = bookings_group_total_price + b[:price]
				    if (b[:has_time_discount] && b[:time_discount] > 0) || (b[:has_discount] && b[:discount] > 0)
				      has_time_discount = true
				      if b[:has_discount] && !b[:has_time_discount]
				        bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
				      elsif !b[:has_discount] && b[:has_time_discount]
				        bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
				      else
				        if b[:discount] > b[:time_discount]
				          bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
				        else
				          bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
				        end
				      end
				    else
				      bookings_group_computed_price = bookings_group_computed_price + b[:price]
				    end
				  end
				end

				if (bookings_group_total_price != 0)
				  bookings_group_discount = (100 - (bookings_group_computed_price/bookings_group_total_price)*100).round(1)
				end

				status = "hora-disponible"

				if has_time_discount || has_treatment_discount
				  if session_booking.nil?
				    status = "hora-promocion"
				  end
				end

				#logger.debug "Time diff: "
				#logger.debug bookings[bookings.length-1][:end].to_s
				#logger.debug bookings[0][:start].to_s
				#logger.debug ((bookings[bookings.length-1][:end] - bookings[0][:start])*24*60).to_f.to_s
				status = "available"

				if has_time_discount
				    if session_booking.nil?
				      status = "discount"
				    end
				end

				hour_time_diff = ((bookings[bookings.length-1][:end] - bookings[0][:start])*24*60).to_f

				if hour_time_diff > max_time_diff
				    max_time_diff = hour_time_diff
				end

				curr_promo_discount = 0

				if bookings.length == 1
				    curr_promo_discount = bookings[0][:time_discount]
				end

				if @mandatory_discount

				  if has_time_discount || has_treatment_discount

				    hour = {
				  		:start => bookings[0][:start].strftime("%H:%M"),
				  		:end => bookings[bookings.length-1][:end].strftime("%H:%M")
					}

				    new_hour = {
		                index: book_index,
		                date: @date,
		                full_date: I18n.l(bookings[0][:start].to_date, format: :day),
		                hour: hour,
		                bookings: bookings,
		                status: status,
		                start_block: bookings[0][:start].strftime("%H:%M"),
		                end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
		                available_provider: bookings[0][:provider_name],
		                provider: bookings[0][:provider_id],
		                promo_discount: curr_promo_discount.to_s,
		                has_time_discount: bookings[0][:has_time_discount],
		                has_discount: bookings[0][:has_discount],
		                time_discount: bookings[0][:time_discount],
		                discount: bookings[0][:discount],
		                time_diff: hour_time_diff,
		                has_sessions: bookings[0][:has_sessions],
		                sessions_amount: bookings[0][:sessions_amount],
		                group_discount: bookings_group_discount.to_s,
		                service_promo_id: bookings[0][:service_promo_id],
						bundled: bookings[0][:bundled],
						bundle_id: bookings[0][:bundle_id]
			        }

				    book_index = book_index + 1
				    book_summaries << new_hour

				    if !hours_array.include?(new_hour)

				      hours_array << new_hour
				      total_hours_array << new_hour

				    end

				  end

				else

					hour = {
				  		:start => bookings[0][:start].strftime("%H:%M"),
				  		:end => bookings[bookings.length-1][:end].strftime("%H:%M")
					}

				  	#I18n.l(bookings[0][:start].to_datetime, format: :hour) + ' - ' + I18n.l(bookings[bookings.length - 1][:end].to_datetime, format: :hour) + ' Hrs'

				    new_hour = {
						index: book_index,
						date: @date,
						full_date: I18n.l(bookings[0][:start].to_date, format: :day),
						hour: hour,
						bookings: bookings,
						status: status,
						start_block: bookings[0][:start].strftime("%H:%M"),
						end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
						available_provider: bookings[0][:provider_name],
						provider: bookings[0][:provider_id],
			          	promo_discount: curr_promo_discount.to_s,
			          	has_time_discount: bookings[0][:has_time_discount],
						has_discount: bookings[0][:has_discount],
						time_discount: bookings[0][:time_discount],
						discount: bookings[0][:discount],
						time_diff: hour_time_diff,
						has_sessions: bookings[0][:has_sessions],
						sessions_amount: bookings[0][:sessions_amount],
						group_discount: bookings_group_discount.to_s,
						service_promo_id: bookings[0][:service_promo_id],
						bundle: @bundle.present? ? @bundle.id : nil
					}

				 	book_index = book_index + 1
				 	book_summaries << new_hour

				  	should_add = true

				  	if should_add
				    	if !hours_array.include?(new_hour)

				      	hours_array << new_hour
				      	total_hours_array << new_hour

				    	end
				  	end

				end



				###################
				###     END     ###
				###################

			end




			if serviceStaff[0][:provider] == "0"
		    	@lock = false
		    else
		    	@lock = true
		    end

		    @lock
		    @company = local.company
		    @location = local
		    @serviceStaff = serviceStaff
		    @date = Date.parse(params[:datepicker])
		    @service = Service.find(serviceStaff[0][:service])

		    @available_time = hours_array
		    @bookSummaries = book_summaries

		    logger.debug @available_time.inspect

		    @available_time

		end

		# Use callbacks to share common setup or constraints between actions.
		def set_company
			@company = Company.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def company_params
			params.require(:company).permit(:name, :plan_id, :logo, :remove_logo, :payment_status_id, :pay_due, :web_address, :description, :cancellation_policy, :months_active_left, :due_amount, :due_date, :active, :show_in_home, :country_id, company_setting_attributes: [:before_booking, :after_booking, :allows_online_payment, :account_number, :company_rut, :account_name, :account_type, :bank_id, :mails_base_capacity, :booking_leap, :allows_overlap_hours, :require_cashier_code], economic_sector_ids: [], company_countries_attributes: [:id, :country_id, :web_address, :active])
		end
end
