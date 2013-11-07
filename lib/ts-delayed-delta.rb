require 'thinking_sphinx'
require 'thinking_sphinx/deltas/delayed_delta'
require 'thinking_sphinx/deltas/delayed_delta/railtie' if defined?(Rails) && Rails::VERSION::MAJOR == 3
