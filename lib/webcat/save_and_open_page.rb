module Webcat
  module SaveAndOpenPage
    extend(self)

    def save_and_open_page(html)
      require 'tempfile'
      tempfile = Tempfile.new("webcat#{rand(1000000)}")
      tempfile.write(rewrite_css_and_image_references(html))
      tempfile.close
      open_in_browser(tempfile.path)
    end

    def open_in_browser(path) # :nodoc
      require "launchy"
      Launchy::Browser.run(path)
    rescue LoadError
      warn "Sorry, you need to install launchy to open pages: `gem install launchy`"
    end

    def rewrite_css_and_image_references(response_html) # :nodoc:
      return response_html unless Webcat.asset_root
      response_html.gsub(/("|')\/(stylesheets|images)/, '\1' + Webcat.asset_root + '/\2')
    end
  end
end
