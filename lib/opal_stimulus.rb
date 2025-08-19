# frozen_string_literal: true

require 'rake'

if RUBY_ENGINE == 'opal'
  require_relative "opal_stimulus/stimulus_controller"
else
  require "opal"
  require_relative "opal_stimulus/version"
  require "opal_stimulus/railtie" if defined?(Rails)

  Opal.append_path File.expand_path('lib', __dir__)
end

Dir.glob(File.expand_path("../tasks/**/*.rake", __FILE__)).each { |r| load r }

module OpalStimulus
end
