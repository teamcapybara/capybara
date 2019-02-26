# frozen_string_literal: true

module Capybara
  module Selenium
    module Find
      def find_xpath(selector, uses_visibility: false, styles: nil, **_options)
        find_by(:xpath, selector, uses_visibility: uses_visibility, texts: [], styles: styles)
      end

      def find_css(selector, uses_visibility: false, texts: [], styles: nil, **_options)
        find_by(:css, selector, uses_visibility: uses_visibility, texts: texts, styles: styles)
      end

    private

      def find_by(format, selector, uses_visibility:, texts:, styles:)
        els = find_context.find_elements(format, selector)
        hints = []

        if (els.size > 2) && !ENV['DISABLE_CAPYBARA_SELENIUM_OPTIMIZATIONS']
          els = filter_by_text(els, texts) unless texts.empty?

          hints_js = +''
          functions = []
          if uses_visibility && !is_displayed_atom.empty?
            hints_js << <<~VISIBILITY_JS
              var vis_func = #{is_displayed_atom};
            VISIBILITY_JS
            functions << 'vis_func'
          end

          if styles.is_a? Hash
            hints_js << <<~STYLE_JS
              var style_func = function(el){
                var el_styles = window.getComputedStyle(el);
                return #{styles.keys.map(&:to_s)}.reduce(function(res, style){
                  res[style] = el_styles[style];
                  return res;
                }, {});
              };
            STYLE_JS
            functions << 'style_func'
          end

          unless functions.empty?
            hints_js << <<~EACH_JS
              return arguments[0].map(function(el){
                return [#{functions.join(',')}].map(function(fn){ return fn.call(null, el) });
              });
            EACH_JS

            hints = es_context.execute_script hints_js, els
            hints.map! do |results|
              result = {}
              result[:style] = results.pop if styles.is_a? Hash
              result[:visible] = results.pop if uses_visibility
              result
            end
          end
        end
        els.map.with_index { |el, idx| build_node(el, hints[idx] || {}) }
      end

      def filter_by_text(elements, texts)
        es_context.execute_script <<~JS, elements, texts
          var texts = arguments[1]
          return arguments[0].filter(function(el){
            var content = el.textContent.toLowerCase();
            return texts.every(function(txt){ return content.indexOf(txt.toLowerCase()) != -1 });
          })
        JS
      end

      def es_context
        respond_to?(:execute_script) ? self : driver
      end

      def is_displayed_atom # rubocop:disable Naming/PredicateName
        @@is_displayed_atom ||= begin
          browser.send(:bridge).send(:read_atom, 'isDisplayed')
                                rescue StandardError
                                  # If the atom doesn't exist or other error
                                  ''
        end
      end
    end
  end
end
