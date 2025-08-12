# frozen_string_literal: true
require 'debug'

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "opal_stimulus"

Opal.use_gem("opal_proxy")
Opal.append_path File.expand_path("../lib", __dir__)

require "minitest/autorun"
