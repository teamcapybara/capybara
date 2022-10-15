# frozen_string_literal: true

Capybara.register_server :default do |app, port, _host|
  Capybara.run_default_server(app, port)
end

Capybara.register_server :webrick do |app, port, host, **options|
  require 'rack/handler/webrick'
  options = { Host: host, Port: port, AccessLog: [], Logger: WEBrick::Log.new(nil, 0) }.merge(options)
  Rack::Handler::WEBrick.run(app, **options)
end

Capybara.register_server :puma do |app, port, host, **options|
  begin
    require 'rack/handler/puma'
  rescue LoadError
    raise LoadError, 'Capybara is unable to load `puma` for its server, please add `puma` to your project or specify a different server via something like `Capybara.server = :webrick`.'
  else
    unless Rack::Handler::Puma.respond_to?(:config)
      raise LoadError, 'Capybara requires `puma` version 3.8.0 or higher, please upgrade `puma` or register and specify your own server block'
    end
  end

  # If we just run the Puma Rack handler it installs signal handlers which prevent us from being able to interrupt tests.
  # Therefore construct and run the Server instance ourselves.
  # Rack::Handler::Puma.run(app, { Host: host, Port: port, Threads: "1:4", workers: 0, daemon: false }.merge(options))
  default_options = { Host: host, Port: port, Threads: '1:4', workers: 0, daemon: false }
  options = default_options.merge(options)

  conf = Rack::Handler::Puma.config(app, options)
  conf.clamp

  puma_ver = Gem::Version.new(Puma::Const::PUMA_VERSION)

  set_threads = false

  # Puma 6 - Events split into two classes, Events & LogWriter
  if Gem::Requirement.new('>= 6.0.0').satisfied_by?(puma_ver)
    events = nil # defaults to Events.new
    logger = conf.options[:log_writer] = conf.options[:Silent] ? ::Puma::LogWriter.strings : ::Puma::LogWriter.stdio
  else
    logger = events = conf.options[:Silent] ? ::Puma::Events.strings : ::Puma::Events.stdio
    if Gem::Requirement.new('< 5.0.3').satisfied_by?(puma_ver)
      set_threads = true
      require_relative 'patches/puma_ssl' if Gem::Requirement.new('>=4.0.0', '< 4.1.0').satisfied_by?(puma_ver)
    end
  end

  logger.log 'Capybara starting Puma...'
  logger.log "* Version #{puma_ver} , codename: #{Puma::Const::CODE_NAME}\n" \
  logger.log "* Min threads: #{conf.options[:min_threads]}, max threads: #{conf.options[:max_threads]}"

  Puma::Server.new(conf.app, events, conf.options).tap do |s|
    s.binder.parse conf.options[:binds], logger
    if set_threads
      s.min_threads, s.max_threads = conf.options[:min_threads], conf.options[:max_threads]
    end
  end.run.join
end
