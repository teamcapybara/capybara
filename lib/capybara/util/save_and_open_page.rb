module Capybara
  class << self
    def save_page(html, file_name=nil)
      file_name ||= "capybara-#{Time.new.strftime("%Y%m%d%H%M%S")}#{rand(10**10)}.html"
      name = File.join(*[Capybara.save_and_open_page_path, file_name].compact)

      unless Capybara.save_and_open_page_path.nil? || File.directory?(Capybara.save_and_open_page_path )
        FileUtils.mkdir_p(Capybara.save_and_open_page_path)
      end
      FileUtils.touch(name) unless File.exist?(name)

      tempfile = File.new(name,'w')
      tempfile.write(rewrite_css_and_image_references(html))
      tempfile.close
      tempfile.path
    end

    def save_and_open_page(html, file_name=nil)
      open_in_browser save_page(html, file_name)
    end

  protected

    def open_in_browser(path) # :nodoc
      require "launchy"
      Launchy.open(path)
    rescue LoadError
      warn "Sorry, you need to install launchy (`gem install launchy`) and " <<
        "make sure it's available to open pages with `save_and_open_page`."
    end

    def rewrite_css_and_image_references(response_html) # :nodoc:
      root = Capybara.asset_root
      return response_html unless root
      directories = Dir.new(root).entries.select { |name|
        (root+name).directory? and not name.to_s =~ /^\./
      }
      if not directories.empty?
        response_html.gsub!(/("|')\/(#{directories.join('|')})/, '\1' + root.to_s + '/\2')
      end
      return response_html
    end
  end
end
