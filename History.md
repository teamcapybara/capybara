#Version 2.6.2
Relase date: 2016-01-27

### Fixed
* support for more than just addressable 2.4.0 [Thomas Walpole]

# Version 2.6.1
Release date: 2016-01-27

### Fixed
* Add missing require for addressable [Jorge Bejar]

# Version 2.6.0
Relase date: 2016-01-17

### Fixed
* Fixed path escaping issue with current_path matchers [Tom Walpole, Luke Rollans] (Issue #1611)
* Fixed circular require [David Rodríguez]
* Capybara::RackTest::Form no longer overrides Object#method [David Rodriguez]
* options and with_options filter for :select selector have more intuitive visibility behavior [Nathan]
* Test for nested modal API method support [Tom Walpole]


### Added
* Capybara.modify_selector [Tom Walpole]
* xfeature and ffeature aliases added when using RSpec [Filip Bartuzi]
* Selenium driver supports a :clear option to #set to handle different strategies for clearing a field [Tom Walpole]
* Support the use of rack 2.0 with the rack_test driver [Travis Grathwell, Tom Walpole]
* Disabled option for default selectors now supports true, false, or :all [Jillian Rosile, Tom Walpole]
* Modal API methods now default wait time to Capybara.default_max_wait_time [Tom Walpole]

# Version 2.5.0
Release date: 2015-08-25

### Fixed
* Error message now raised correctly when invalid options passed to 'have_text'/'have_content' [Tom Walpole]
* Rack-test driver correctly gets document title when elements on the page have nested title elements (SVG) [Tom Walpole]
* 'save_page' no longer errors when using Capybara.asset_host if the page has no \<head> element [Travis Grathwell]
* rack-test driver will ignore clicks on links with href starting with '#' or 'javascript:'

### Added
* has_current_path? and associated asserts/matchers added [Tom Walpole]
* Implement Node#path in selenium driver [Soutaro Matsumoto]
* 'using_session' is now nestable [Tom Walpole]
* 'switch_to_window' will now use waiting behavior for a matching window to appear [Tom Walpole]
* Warning when attempting to select a disabled option
* Capybara matchers are now available in RSpec view specs by default [Joshua Clayton]
* 'have_link' and 'click_link' now accept Regexp for href matching [Yaniv Savir]
* 'find_all' as an alias of 'all' due to collision with RSpec
* Capybara.wait_on_first_by_default setting (default is false)
  If set to true 'first' will use Capybaras waiting behavior to wait for at least one element to appear by default
* Capybara waiting behavior uses the monotonic clock if supported to ease restrictions on freezing time in tests [Dmitry Maksyoma, Tom Walpole]
* Capybara.server_errors setting that allows to configure what type of errors will be raised from the server thread [Tom Walpole]
* Node#send_keys to allow for sending keypresses directly to elements [Tom Walpole]
* 'formmethod' attribute support in RackTest driver [Emilia Andrzejewska]
* Clear field using backspaces in Selenium driver by using `:fill_options => { :clear => :backspace }` [Joe Lencioni]

### Deprecated
* Capybara.default_wait_time deprecated in favor of Capybara.default_max_wait_time to more clearly explain its purpose [Paul Pettengill]

#Version 2.4.4
Release date: 2014-10-13

### Fixed
* Test for visit behavior updated [Phil Baker]
* Removed concurrency prevention in favor of a note in the README - due to load order issues

# Version 2.4.3
Relase date: 2014-09-21

### Fixed
* Update concurrency prevention to match Rails 4.2 behavior

# Version 2.4.2
Release date: 2014-09-20

### Fixed
* Prevent concurrency issue when testing Rails app with default test environment [Thomas Walpole]
* Tags for windows API tests fixed [Dmitry Vorotilin]
* Documentation Fixes [Andrey Botalov]
* Always convert visit url to string, fixes issue with visit when always_include_port was enabled [Jake Goulding]
* Check correct rspec version before including ::RSpec::Matchers::Composable in Capybara RSpec matchers [Thomas Walpole, Justin Ko]

# Version 2.4.1

Release date: 2014-07-03

### Added

* 'assert_text', 'assert_no_text', 'assert_title', 'assert_no_title' methods added [Andrey Botalov]
* have_title matcher now supports :wait option [Andrey Botalov]
* More descriptive have_text error messages [Andrey Botalov]
* New modal API ('accept_alert', 'accept_confirm', 'dismiss_confirm', 'accept_prompt', 'dismiss_prompt') - [Mike Pack, Thomas Walpole]
* Warning when attempting to set contents of a readonly element
* Suport for and/or compounding of Capybara's RSpec matchers for RSpec 3 [Thomas Walpole]
* :fill_options option for 'fill_in' method that propagates to 'set' to allow for driver specific modification of how fields are filled in [Gabriel Sobrinho, Thomas Walpole]
* Improved selector/filter description in failure messages [Thomas Walpole]

### Fixed

* HaveText error message now shows the text checked all the time
* RackTest driver no longer attempts to follow an anchor tag without an href attribute
* Warnings under RSpec 3
* Handle URI schemes like about: correctly [Andrey Botalov]
* RSpecs expose_dsl_globally option is now followed [Myron Marston, Thomas Walpole]

# Version 2.3.0

Release date: 2014-06-02

### Added
* New window management API [Andrey Botalov]
* Speed improvement for visible text detection in RackTest [Thomas Walpole]
  Thanks to Phillipe Creux for instigating this
* RSpec 3 compatability
* 'save_and_open_screenshot' functionality [Greg Lazarev]
* Server errors raised on visit and synchronize [Jonas Nicklas]

### Fixed

* CSSHandlers now derives from BasicObject so globally included functions (concat, etc) shouldn't cause issues [Thomas Walpole]
* touched reset after session is reset [lesliepc16]

# Version 2.2.1

Release date: 2014-01-06

### Fixed

* Reverted a change in 2.2.0 which navigates to an empty file on `reset`.
  Capybara, now visits `about:blank` like it did before. [Jonas Nicklas]

# Version 2.2.0

Release date: 2013-11-21

### Added

* Add `go_back` and `go_forward` methods. [Vasiliy Ermolovich]
* Support RSpec 3 [Thomas Holmes]
* `has_button?`, `has_checked_field?` and `has_unchecked_field?` accept
  options, like other matchers. [Carol Nichols]
* The `assert_selector` and `has_text?` methods now support the `:wait` option
  [Vasiliy Ermolovich]
* RackTest's visible? method now checks for the HTML5 `hidden` attribute.
* Results from `#all` now delegate the `sample` method. [Phil Lee]
* The `set` method now works for contenteditable attributes under Selenium.
  [Jon Rowe]
* radio buttons and check boxes can be filtered by option value, useful when
  selecting by name [Jonas Nicklas]
* feature blocks can be nested within other feature blocks in RSpec tests
  [Travis Gaff]

### Fixed

* Fixed race conditions causing stale element errors when filtering by text.
  [Jonas Nicklas]
* Resetting the page is now synchronous and navigates to an empty HTML file,
  instead of `about:blank`, fixing hanging issues in JRuby. [Jonas Nicklas]
* Fixed cookies not being set when path is blank under RackTest [Thomas Walpole]
* Clearing fields now correctly causes change events [Jonas Nicklas]
* Navigating to an absolute URI without trailing slash now works as expected
  under RackTest [Jonas Nicklas]
* Checkboxes without assigned value default to `on` under RackTest [Nigel Sheridan-Smith]
* Clicks on buttons with no form associated with them are ignored in RackTest
  instead of raising an obscure exception. [Thomas Walpole]
* execute_script is now a session method [Andrey Botalov]
* Nesting `within_window` and `within_frame` inside `within` resets the scope
  so that they behave like a user would expect [Thomas Walpole]
* Improve handling of newlines in textareas [Thomas Walpole]
* `Capybara::Result` delegates its inspect method, so as not to confuse users
  [Sam Rawlins]
* save_page always returns a full path, fixes problems with Launchy [Jonas Nicklas]
* Selenium driver's `quit` method does nothing when browser hasn't been loaded
  [randoum]
* Capybara's WEBRick server now propertly respects the server_host option
  [Dmitry Vorotilin]
* gemspec now includes license information [Jonas Nicklas]

# Version 2.1.0

Release date: 2013-04-09

### Changed

* Hard version requirement on Ruby >= 1.9.3. Capybara will no longer install
  on 1.8.7. [Felix Schäfer]
* Capybara no longer depends on the `selenium-webdriver` gem. Add it to
  your Gemfile if you wish to use the Selenium driver. [Jonas Nicklas]
* `Capybara.ignore_hidden_elements` defaults to `true`. [Jonas Nicklas]
* In case of multiple matches `smart` matching is used by default. Set
  `Capybara.match = :one` to revert to old behaviour. [Jonas Nicklas].
* Options in select boxes use smart matching and no longer need to match
  exactly. Set `Capybara.exact_options = false` to revert to old behaviour.
  [Jonas Nicklas].
* Visibility of text depends on `Capybara.ignore_hidden_elements` instead of
  always returning only visible text. Set `Capybara.visible_text_only = true`
  to revert to old behaviour. [Jonas Nicklas]
* Cucumber cleans up session after scenario instead. This is consistent with
  RSpec and makes more sense, since we raise server errors in `reset!`.
  [Jonas Nicklas]

### Added

* All actions (`click_link`, `fill_in`, etc...) and finders now take an options
  hash, which is passed through to `find`. [Jonas Nicklas]
* CSS selectors are sent straight through to driver instead of being converted
  to XPath first. Enables the use of some pseudo selectors, such as `invalid`
  in some drivers. [Thomas Walpole]
* `Capybara.asset_host` option, which inserts a `base` tag into the page on
  `save_and_open_page`, eases debugging with the Rails asset pipeline.
  [Steve Hull]
* `exact` option, can specify whether to match substrings or entire text.
  [Jonas Nicklas]
* `match` option, can specify behaviour in case of multiple matches.
  [Jonas Nicklas]
* `wait` option, can specify how long to wait for a given action/finder.
  [Jonas Nicklas]
* Config option which disables bubbling of errors raised inside server.
  [Jonas Nicklas]
* `text` now takes a parameter which makes it possible to return either all
  text or only visible text. The default depends on
  `Capybara.ignore_hidden_elements`. `Capybara.visible_text_only` option is
  available for compatibility. [Jonas Nicklas]
* `has_content?` and `has_text?` now take the same count options as `has_selector?`
  [Andrey Botalov]
* `current_scope` is now public API, returns the current element when `within`
  is used. [Martijn Walraven]
* `find("input").disabled?` returns true if a node is disabled. [Ben Lovell]
* Find disabled fields and buttons with `:disabled => false`. [Jonas Nicklas]
* `find("input").hover` moves the mouse to the element in supported drivers.
  [Thomas Walpole]
* RackTest driver now support `form` attribute on form elements.
  [Thomas Walpole]
* `page.title` returns the page title. [Terry Progetto]
* `has_title?` matcher to assert on page title. [Jonas Nicklas]
* The gem is now signed with a certicficate. The public key is available in the
  repo. [Jonas Nicklas]
* `:select` and `:textarea` are valid options for the `:type` filter on `find_field`
  and `has_field?`. [Yann Plancqueel]

### Fixed

* Fixed race conditions when synchronizing across multiple nodes [Jonas Nicklas]
* Fixed race conditions in deeply nested selectors [Jonas Nicklas]
* Fix issue with `within_frame`, where selecting multiple nested frames didn't
  work as intended. [Thomas Walpole]
* RackTest no longer fills in readonly textareas. [Thomas Walpole]
* Don't use autoload to load files, require them directly instead. [Jonas Nicklas]
* Rescue weird exceptions when booting server [John Wilger]
* Non strings are now properly cast when using the maxlength attribute [Jonas Nicklas]

# Version 2.0.3

Release date: 2013-03-26

* Check against Rails version fixed to work with Rails' master branch now returning
  a Gem::Version [Jonas Nicklas]
* Use posix character class for whitespace replace, solves various encoding
  problems on Ruby 2.0.0 and JRuby. [Ben Cates]

# Version 2.0.2

Release date: 2012-12-31

### Changed

* Capybara no longer uses thin as a server if it is available, due to thread
  safety issues. Now Capybara always defaults to WEBrick. [Jonas Nicklas]

### Fixed

* Suppress several warnings [Kouhei Sutou]
* Fix default host becoming nil [Brian Cardarella]
* Fix regression in 2.0.1 which caused node comparisons with non node objects
  to throw an exception [Kouhei Sotou]
* A few changes to the specs, only relevant to driver authors [Jonas Nicklas]
* Encoding error under JRuby [Piotr Krawiec]
* Ruby 2 encoding fix [Murahashi Sanemat Kenichi]
* Catch correct exception on server timeout [Jonathan del Strother]

# Version 2.0.1

Release date: 2012-12-21

### Changed

* Move the RackTest driver override with the `:respect_data_method` option
  enabled from capybara/rspec to capybara/rails, so that it is enabled in
  Rails projects that don't use RSpec. [Carlos Antonio da Silva]
* `source` is now an alias for `html`. RackTest no longer returns modifications
  to `html`. This basically codifies the behaviour which we've had for a while
  anyway, and should have minimal impact for end users. For driver authors, it
  means that they only have to implement `html`, and not `source`. [Jonas
  Nicklas]

### Fixed

* Visiting relative URLs when `app_host` is set and no server is running works
  as expected. [Jonas Nicklas]
* `fill_in` works properly under Selenium again when the caret is not at the
  end of the field before the method is called. [Douwe Maan, Jonas Nicklas, Jari
  Bakken]
* `attach_file` can once again be given a Pathname [Jake Goulding]

# Version 2.0.0

Release date: 2012-11-05

### Changed

* Dropped official support for Ruby 1.8.x. [Jonas Nicklas]
* `respect_data_method` default to `false` for the RackTest driver in non-rails
  applications. That means that Capybara no longer picks up `data-method="post"`
  et. al. from links by default when you haven't required capybara/rails
  [Jonas Nicklas]
* `find` now raises an error if more than one element was found. Since `find` is
  used by most actions, like `click_link` under the surface, this means that all
  actions need to unambiguous in the future. [Jonas Nicklas]
* All methods which find or manipulate fields or buttons now ignore them when
  they are disabled. [Jonas Nicklas]
* Can no longer find elements by id via `find(:foo)`, use `find("#foo")` or
  `find_by_id("foo")` instead. [Jonas Nicklas]
* `Element#text` on RackTest now only returns visible text and normalizes
  (strips) whitespace, as with Selenium [Mark Dodwell, Jo Liss]
* `has_content?` now checks the text value returned by `Element#text`, as opposed to
  querying the DOM. Which means it does not match hidden text.
  [Ryan Montgomery, Mark Dodwell, Jo Liss]
* #394: `#body` now returns the unmodified source (like `#source`), not the current
  state of the DOM (like `#html`), by popular request [Jonas Nicklas]
* `Node#all` no longer returns an array, but rather an enumerable `Capybara::Result`
  [Jonas Nicklas]
* The arguments to `select` and `unselect` needs to be the exact text of an option
  in a select box, substrings are no longer allowed [Jonas Nicklas]
* The `options` option to `has_select?` must match the exact set of options. Use
  `with_options` for the old behaviour. [Gonzalo Rodriguez]
* The `selected` option to `has_select?` must match all selected options for multiple
  selects. [Gonzalo Rodriguez]
* Various internals for running driver specs, this should only affect driver authors
  [Jonas Nicklas]
* Rename `Driver#body` to `Driver#html` (relevant only for driver authors) [Jo
  Liss]

### Removed

* No longer possible to specify `failure_message` for custom selectors. [Jonas Nicklas]
* #589: `Capybara.server_boot_timeout` has been removed in favor of a higher
  (60-second) hard-coded timeout [Jo Liss]
* `Capybara.prefer_visible_elements` has been removed, as it is no longer needed
  with the changed find semantics [Jonas Nicklas]
* `Node#wait_until` and `Session#wait_until` have been removed. See `Node#synchronize`
  for an alternative [Jonas Nicklas]
* `Capybara.timeout` has been removed [Jonas Nicklas]
* The `:resynchronize` option has been removed from the Selenium driver [Jonas Nicklas]
* The `rows` option to `has_table?` has been removed without replacement.
  [Jonas Nicklas]

### Added

* Much improved error message [Jonas Nicklas]
* Errors from inside the session for apps running in a server are raised when
  session is reset [James Tucker, Jonas Nicklas]
* A ton of new selectors built in out of the box, like `field`, `link`, `button`,
  etc... [Adam McCrea, Jonas Nicklas]
* `has_text?` has been added as an alias for `has_content?` [Jonas Nicklas]
* Add `Capybara.server_host` option (default: 127.0.0.1) [David Balatero]
* Add `:type` option for `page.has_field?` [Gonzalo Rodríguez]
* Custom matchers can now be specified in CSS in addition to XPath [Jonas Nicklas]
* `Node#synchronize` method to rerun a block of code if certain errors are raised
  [Jonas Nicklas]
* `Capybara.always_include_port` config option always includes the server port in
  URLs when using `visit`. Facilitates testing different domain names. [Douwe Maan]
* Redirect limit for RackTest driver is configurable [Josh Lane]
* Server port can be manually specified during initialization of server.
  [Jonas Nicklas, John Wilger]
* `has_content?` and `has_text?` can be given a regular expression [Vasiliy Ermolovich]
* Multiple files can be uploaded with `attach_file` [Jarl Friis]

### Fixed

* Nodes found via `all` are no longer reloaded. This fixes weird quirks where
  nodes would seemingly randomly replace themselves with other nodes [Jonas Nicklas]
* Session is only reset if it has been modified, dramatically improves performance if
  only part of the test suite runs Capybara. [Jonas Nicklas]
* Test suite now passes on Ruby 1.8 [Jo Liss]
* #565: `require 'capybara/dsl'` is no longer necessary [Jo Liss]
* `Rack::Test` now respects ports when changing hosts [Jo Liss]
* #603: `Rack::Test` now preserves the original referer URL when following a
  redirect [Rob van Dijk]
* Rack::Test now does not send a referer when calling `visit` multiple times
  [Jo Liss]
* Exceptions during server boot now propagate to main thread [James Tucker]
* RSpec integration now cleans up before the test instead of after [Darwin]
* If `respect_data_method` is true, the data-method attribute can be capitalized
  [Marco Antonio]
* Rack app boot timing out raises an error as opposed to just logging to STDOUT
  [Adrian Irving-Beer]
* `#source` returns an empty string instead of nil if no pages have been visited
  [Jonas Nicklas]
* Ignore first leading newline in textareas in RackTest [Vitalii Khustochka]
* `within_frame` returns the value of the given block [Alistair Hutchison]
* Running `Node.set` on text fields will not trigger more than one change event
  [Andrew Kasper]
* Throw an error when an option is given to a finder method, like `all` or
  `has_selector?` which Capybara doesn't understand [Jonas Nicklas]
* Two references to the node now register as equal when comparing them with `==`
  [Jonas Nicklas]
* `has_text` (`has_content`) now accepts non-string arguments, like numbers.
  [Jo Liss]
* `has_text` and `text` now correctly normalize Unicode whitespace, such as
  `&nbsp;`. [Jo Liss]
* RackTest allows protocol relative URLs [Jonas Nicklas]
* Arguments are cast to string where necessary, so that e.g. `click_link(:foo)` works
  as expected. [Jonas Nicklas]
* `:count => 0` now works as expected [Jarl Friis]
* Fixed race conditions on negative assertions when removing nodes [Jonas Nicklas]

# Version 1.1.4

Release date: 2012-11-28

### Fixed

* Fix more race conditions on negative assertions. [Jonas Nicklas]

# Version 1.1.3

Release date: 2012-10-30

### Fixed:

* RackTest driver ignores leading newline in textareas, this is consistent with
  the spec and how browsers behave. [Vitalii Khustochka]
* Nodes found via `all` and `first` are never reloaded. This fixes issues where
  a node would sometimes magically turn into a completely different node.
  [Jonas Nicklas]
* Fix race conditions on negative assertions. This fixes issues where removing
  an element and asserting on its non existence could cause
  StaleElementReferenceError and similar to be thrown. [Jonas Nicklas]
* Options are no longer lost when reloading elements. This fixes issues where
  reloading an element would cause a non-matching element to be found, because
  options to `find` were ignored. [Jonas Nicklas]

# Version 1.1.2

Release date: 2011-11-15

### Fixed

* #541: Make attach_file work with selenium-webdriver >=2.12 [Jonas Nicklas]

# Version 1.1.0

Release date: 2011-09-02

### Fixed

* Sensible inspect for Capybara::Session [Jo Liss]
* Fix headers and host on redirect [Matt Colyer, Jonas Nicklas, Kim Burgestrand]
* using_driver now restores the old driver instead of reverting to the default [Carol Nichols]
* Errors when following links relative to the root path under rack-test [Jonas Nicklas, Kim Burgestrand]
* Make sure exit codes are propagated properly [Edgar Beigarts]

### Changed

* resynchronization is off by default under Selenium

### Added

* Elements are automatically reloaded (including parents) during wait [Jonas Nicklas]
* Rescue driver specific element errors, such as the dreaded ObsoleteElementError and retry [Jonas Nicklas]
* Raise an error if something has frozen time [Jonas Nicklas]
* Allow within to take a node instead of a selector [Peter Williams]
* Using wait_time_time to change wait time for a block of code [Jonas Nicklas, Kim Burgestrand]
* Option for rack-test driver to disable data-method hack [Jonas Nicklas, Kim Burgestrand]

# Version 1.0.1

Release date: 2011-08-12

### Fixed

* Dependend on selenium-webdriver ~>2.0 and fix deprecations [Thomas Walpole, Jo Liss]
* Depend on Launch 2.0 [Jeremy Hinegardner]
* Rack-Test ignores fill in on fields with maxlength=""

# Version 1.0.0

Release date: 2011-06-14

### Added

* Added DSL for acceptance tests, inspired by Luismi Cavallé's Steak [Luismi Cavalle and Jonas Nicklas]
* Selenium driver automatically waits for AJAX requests to finish [mgiambalvo, Nicklas Ramhöj and Jonas Nicklas]
* Support for switching between multiple named sessions [Tristan Dunn]
* failure_message can be specified for Selectors [Jonas Nicklas]
* RSpec matchers [David Chelimsky and Jonas Nicklas]
* Added save_page to save tempfile without opening in browser [Jeff Kreeftmeijer]
* Cucumber now switches automatically to a registered driver if the tag matches the name [Jonas Nicklas]
* Added Session#text [Jonas Nicklas and Scott Cytacki]
* Added Session#html as an alias for Session#body [Jo Liss]
* Added Session#current_host method [Jonas Nicklas]
* Buttons can now be clicked by title [Javier Martin]
* :headers option for RackTest driver to set custom HTTP headers [Jonas Nicklas]

### Removed

* Culerity and Celerity drivers have been removed and split into separate gems [Gabriel Sobrinho]

### Deprecated

* `include Capybara` has been deprecated in favour of `include Capybara::DSL` [Jonas Nicklas]

### Changed

* Rack test driver class has been renamed from Capybara::Driver::RackTest to Capybara::RackTest::Driver [Jonas Nicklas]
* Selenium driver class has been renamed from Capybara::Driver::Selenium to Capybara::Selenium::Driver [Jonas Nicklas]
* Capybara now prefers visible elements over hidden elements, disable by setting Capybara.prefer_visible_elements = false [Jonas Nicklas and Nicklas Ramhöj]
* For RSpec, :type => :request is now supported (and preferred over :acceptance) [Jo Liss]
* Selenium driver tried to wait for AJAX requests to finish before proceeding [Jonas Nicklas and Nicklas Ramhöj]
* Session no longer uses method missing, uses explicit delegates instead [Jonas Nicklas]

### Fixed

* The Rack::Test driver now respects maxlength on text fields [Guilherme Carvalho]
* Allow for more than one save_and_open_page call per second [Jo Liss]
* Automatically convert options to :count, :minimum, :maximum, etc. to integers [Keith Marcum]
* Rack::Test driver honours maxlength on input fields [Guilherme Carvalho]
* Rack::Test now works as expected with domains and subdomains [Jonas Nicklas]
* Session is reset more thoroughly between tests. [Jonas Nicklas]
* Raise error when uploading non-existant file [Jonas Nicklas]
* Rack reponse body should respond to #each [Piotr Sarnacki]
* Deprecation warnings with selenium webdriver 0.2.0 [Aaron Gibraltar]
* Selenium Chrome no longer YELLS tagname [Carl Jackson & David W. Frank]
* Capybara no longer strips encoding before sending to Rack [Jonas Nicklas]
* Improve handling of relative URLs [John Barton]
* Readd and fix build_rack_mock_session [Jonas Nicklas, Jon Leighton]

# Version 0.4.1

Release date: 2011-01-21

### Added

* New click_on alias for click_link_or_button, shorter yet unambiguous. [Jonas Nicklas]
* Finders now accept :visible => false which will find all elements regardless of Capybara.ignore_hidden_elements [Jonas Nicklas]
* Configure how the server is started via Capybara.server { |app, port| ... }. [John Firebough]
* Added :between, :maximum and :minimum options to has_selector and friends [James B. Byrne]
* New Capybara.string util function which allows matchers on arbitrary strings, mostly for helper and view specs [David Chelimsky and Jonas Nicklas]
* Server boot timeout is now configurable, via Capybara.server_boot_timeout [Adam Cigánek]
* Built in support for RSpec [Jonas Nicklas]
* Capybara.using_driver to switch to a different driver temporarily [Jeff Kreeftmeijer]
* Added Session#first which is somewhat speedier than Session#all, use it internally for speed boost [John Firebaugh]

### Changed

* Session#within now accepts the same arguments as other finders, like Session#all and Session#find [Jonas Nicklas]

### Removed

* All deprecations from 0.4.0 have been removed. [Jonas Nicklas]

### Fixed

* Don't mangle URLs in save_and_open_page when using self-closing tags [Adam Spiers]
* Catch correct error when server boot times out [Jonas Nicklas]
* Celerity driver now properly passes through options, making it configurable [Jonas Nicklas]
* Better implementation of attributes in C[ue]lerity, should fix issues with attributes with strange names [Jonas Nicklas]
* Session#find no longer swallows errors [Jonas Nicklas]
* Fix problems with multiple file inputs [Philip Arndt]
* Submit multipart forms as multipart under rack-test even if they contain no files [Ryan Kinderman]
* Matchers like has_select? and has_checked_field? now work with dynamically changed values [John Firebaugh]
* Preserve order of rack params [Joel Chippindale]
* RackTest#reset! is more thorough [Joel Chippindale]

# Version 0.4.0

Release date: 2010-10-22

### Changed

* The Selector API was changed slightly, use Capybara.add_selector, see README

### Fixed

* Celerity driver is registered properly
* has_selector? and has_no_selector? added to DSL
* Multiple selects return correct values under C[cu]lerity
* Naked query strings are handled correctly by rack-test

# Version 0.4.0.rc

Release date: 2010-10-12

### Changed

* within and find/locate now follow the XPath spec in that //foo finds all nodes in the document, instead of
  only for the context node. See this post for details: http://groups.google.com/group/ruby-capybara/browse_thread/thread/b129067979df21b3
* within now executes within the first found instance of the selector, not in all of them
* find now waits for AJAX requests and raises an exception when the element is not found (same as locate used to do)
* The default selector is now CSS, not XPath

### Deprecated

* Session#click has been renamed click_link_or_button and the old click has been deprecated
* Node#node has been renamed native
* Node#locate is deprecated in favor of Node#find, which now behaves identically
* Session#drag is deprecated, please use Node#drag_to(other_node) instead

### Added

* Pretty much everything is properly documented now
* It's now possible to call all session methods on nodes, like `find('#foo').fill_in(...)`
* Custom selectors can be added with Capybara::Selector.add
* The :id selector is added by default, use it lile `find(:id, 'foo')` or `find(:foo)`
* Added Node#has_selector? so any kind of selector can be queried.
* Added Capybara.configure for less wordy configuration
* Added within_window to switch between different windows (currently Selenium only)
* Capybara.server_port to provide a fixed port if wanted (defaults to automatic selection)

### Fixed

* CSS selectors with multiple selectors, such as "h1, h2" now work correctly
* Port is automatically assigned instead of guessing
* Strip encodings in rack-test, no more warnings!
* RackTest no longer submits disabled fields
* Servers no longer output annoying debug information when started
* TCP port selection is left to Ruby to decide, no more port guessing
* Select boxes now return option value instead of text if present
* The default has been changed from localhost to 127.0.0.1, should fix some obscure selenium bugs
* RackTest now supports complex field names, such as foo[bar][][baz]

# Version 0.3.9

Release date: 2010-07-03

### Added

* status_code which returns the HTTP status code of the last response (no Selenium!)
* Capybara.save_and_open_page to store tempfiles
* RackTest and Culerity drivers now clean up after themselves properly

### Fixed

* When no rack app is set and the app is called, a more descriptive error is raised
* select now works with optgroups
* Don't submit image buttons unless they were clicked under rack-test
* Support custom field types under Selenium
* Support input fields without a type, treat them as though they were text fields
* Redirect now throws an error after 5 redirects, as per RFC
* Selenium now properly raises an error when Node#trigger is called
* Node#value now returns the correct value for textareas under rack-test

# Version 0.3.8

Release date: 2010-05-12

### Added

* Within_frame method to execute a block of code within a particular iframe (Selenium only!)

### Fixed

* Single quotes are properly escaped with `select` under rack-test and Selenium.
* The :text option for searches now escapes regexp special characters when a string is given.
* Selenium now correctly checks already checked checkboxes (same with uncheck)
* Timing issue which caused Selenium to hang under certain circumstances.
* Selenium now resolves attributes even if they are given as a Symbol

# Version 0.3.7

Release date: 2010-04-09

This is a drop in compatible maintainance release. It's mostly
important for driver authors.

### Added

* RackTest scans for data-method which rails3 uses to change the request method

### Fixed

* Don't hang when starting server on Windoze

### Changed

* The driver and session specs are now located inside lib! Driver authors can simply require them.

# Version 0.3.6

Release date: 2010-03-22

This is a maintainance release with minor bug fixes, should be
drop in compatible.

### Added

* It's now possible to load in external drivers

### Fixed

* has_content? ignores whitespace
* Trigger events when choosing radios and checking checkboxes under Selenium
* Make Capybara.app totally optional when running without server
* Changed fallback host so it matches the one set up by Rails' integration tests

# Version 0.3.5

Release date: 2010-02-26

This is a mostly backwards compatible release, it does break
the API in some minor places, which should hopefully not affect
too many users, please read the release notes carefully!

### Breaking

* Relative searching in a node (e.g. find('//p').all('//a')) will now follow XPath standard
  this means that if you want to find descendant nodes only, you'll need to prefix a dot!
* `visit` now accepts fully qualified URLs for drivers that support it.
* Capybara will always try to run a rack server, unless you set Capybara.run_sever = false

### Changed

* thin is preferred over mongrel and webrick, since it is Ruby 1.9 compatible
* click_button and click will find <input type="button">, clicking them does nothing in RackTest

### Added

* Much improved error messages in a multitude of places
* More semantic page querying with has_link?, has_button?, etc...
* Option to ignore hidden elements when querying and interacting with the page
* Support for multiple selects

### Fixed

* find_by_id is no longer broken
* clicking links where the image's alt attribute contains the text is now possible
* within_fieldset and within_table work when the default selector is CSS
* boolean attributes work the same across drivers (return true/false)

