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
      self.source = "#{TMPL_DIR}/_#{self.name}"
      self.thumb = "#{IMG_DIR}/#{self.name}.png"
    end

    def create_file
      unless File.exist?(src_fmt)
        File.open(src_fmt, 'w+') do |f|
          f.write(File.read("#{Rails.root}/app/views/#{TMPL_DIR}/base.html.erb"))
        end
      end
    end

    def delete_file
      File.delete(src_fmt) if File.exist?(src_fmt)
    end

    def src_fmt
      File.absolute_path("./app/views/#{self.source}.html.erb")
    end

end
