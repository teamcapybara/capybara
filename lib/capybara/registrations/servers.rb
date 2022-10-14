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
  # Rack::Handler::Puma.run(app, { Host: host, Port: port, Threads: "0:4", workers: 0, daemon: false }.merge(options))
  default_options = { Host: host, Port: port, Threads: '0:4', workers: 0, daemon: false }
  options = default_options.merge(options)

  puma_ver = Gem::Version.new(Puma::Const::PUMA_VERSION)

  if Gem::Requirement.new('>=6.0.0').satisfied_by?(puma_ver)
    log_writer = options[:Silent] ? ::Puma::LogWriter.strings : ::Puma::LogWriter.stdio
    options[:log_writer] = log_writer
  end

  conf = Rack::Handler::Puma.config(app, options)
  conf.clamp
  events = conf.options[:Silent] ? ::Puma::Events.strings : ::Puma::Events.stdio if Gem::Requirement.new('< 6.0.0').satisfied_by?(puma_ver)

  require_relative 'patches/puma_ssl' if Gem::Requirement.new('>=4.0.0', '< 4.1.0').satisfied_by?(puma_ver)

  if Gem::Requirement.new('>=6.0.0').satisfied_by?(puma_ver)
    log_writer.log 'Capybara starting Puma...'
    log_writer.log "* Version #{Puma::Const::PUMA_VERSION} , codename: #{Puma::Const::CODE_NAME}"
    log_writer.log "* Min threads: #{conf.options[:min_threads]}, max threads: #{conf.options[:max_threads]}"

    Puma::Server.new(conf.app, nil, conf.options).tap do |s|
      s.binder.parse conf.options[:binds], s.log_writer
    end.run.join
  else
    events.log 'Capybara starting Puma...'
    events.log "* Version #{Puma::Const::PUMA_VERSION} , codename: #{Puma::Const::CODE_NAME}"
    events.log "* Min threads: #{conf.options[:min_threads]}, max threads: #{conf.options[:max_threads]}"

    Puma::Server.new(conf.app, events, conf.options).tap do |s|
      s.binder.parse conf.options[:binds], s.events
      s.min_threads, s.max_threads = conf.options[:min_threads], conf.options[:max_threads]
    end.run.join
  end
end
