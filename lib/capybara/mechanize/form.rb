require 'mechanize'

class Capybara::Mechanize::Form < Mechanize::Form
  
  def initialize(node, mech=nil, page=nil)
    super(strip_disabled_nodes(node), mech, page)
    normalize_uploads
  end
  
  private
  
  def strip_disabled_nodes(form_node)
    stripped_form_node = form_node.clone
    stripped_form_node.search('*[disabled=disabled]').remove
    stripped_form_node
  end
  
  def normalize_uploads
    if self.enctype.downcase =~ /^multipart\/form-data/
      assign_files_to_uploads
    else
      create_dummy_fields
    end
  end
  
  def assign_files_to_uploads
    self.file_uploads.each do |upload|
      file_path = upload.node["value"]
      upload.file_name = file_path if !file_path.nil? && file_path != ''
    end 
  end
  
  def create_dummy_fields
    self.file_uploads.each do |upload|
      file_path = upload.node["value"]
      
      if !file_path.nil? && file_path != ''        
        new_field = Mechanize::Form::Field.new(upload.node, File.basename(file_path))
        self.fields << new_field
      end
    end 
  end
end
