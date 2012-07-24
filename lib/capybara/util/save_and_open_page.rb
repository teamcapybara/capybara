module Capybara
  class << self
    def save_page(html, path=nil)
      path ||= "capybara-#{Time.new.strftime("%Y%m%d%H%M%S")}#{rand(10**10)}.html"
      path = File.expand_path(path, Capybara.save_and_open_page_path) if Capybara.save_and_open_page_path

      FileUtils.mkdir_p(File.dirname(path))

      File.open(path,'w') { |f| f.write(html) }
      path
    end

    def save_and_open_page(html, file_name=nil)
      require "launchy"
      path = save_page(html, file_name)
      Launchy.open(path)
    rescue LoadError
      warn "Please install the launchy gem to open page with save_and_open_page"
    end
  end
end
