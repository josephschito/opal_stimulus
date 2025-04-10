# frozen_string_literal: true

require 'rake'
require "opal"

unless RUBY_ENGINE == 'opal'
  require 'opal'
  require_relative "opal_stimulus/version"

  Opal.append_path File.expand_path('../..', __FILE__)
end

Dir.glob(File.expand_path("../tasks/**/*.rake", __FILE__)).each { |r| load r }

module OpalStimulus
end
