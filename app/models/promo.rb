class Promo < ActiveRecord::Base
	require 'pg_search'
	include PgSearch

	belongs_to :service_promo
	belongs_to :day
	belongs_to :location

	has_one :service_category, :through => :service

	pg_search_scope :search, 
	:associated_against => {
		:service => :name,
		:service_category => :name
	},
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

end
