# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

require 'opal/rspec/rake_task'
require "opal"

Opal.use_gem("opal_proxy")
Opal.append_path File.expand_path('../lib', __FILE__)
Opal.append_path File.expand_path('../shared_fixtures', __FILE__)

Opal::RSpec::RakeTask.new("rspec-opal") do |server, task|
  server.debug = true
  task.runner = :chrome
end

task default: %i[rspec-opal]
