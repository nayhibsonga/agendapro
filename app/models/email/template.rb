class Email::Template < ActiveRecord::Base
  has_many :contents, class_name: 'Email::Content'
  validates_presence_of :name
  validates_uniqueness_of :name

  before_save :set_defaults
  after_create :create_file
  after_destroy :delete_file

  alias_attribute :thumbnail, :thumb

  SHARED = "email/full/templates"
  IMG_DIR = "#{SHARED}"
  TMPL_DIR = "clients/#{SHARED}"

  def to_s
    self.name.titleize.gsub('_',' ')
  end

  def src
    "#{TMPL_DIR}/#{self.name}"
  end

  private

    def set_defaults
      self.source = TMPL_DIR
      self.thumb = "#{IMG_DIR}/#{self.name}.png"
    end

    def create_file
      unless File.exist?(file_name)
        File.open(file_name, 'w+') do |f|
          f.write(File.read("#{Rails.root}/app/views/#{TMPL_DIR}/base.html.erb"))
        end
      end
    end

    def delete_file
      File.delete(file_name) if File.exist?(file_name)
    end

    def file_name
      File.absolute_path("./app/views/#{TMPL_DIR}/_#{self.name}.html.erb")
    end

end
