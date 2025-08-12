# backtick_javascript: true

require "opal"
require "stimulus@3.2.2.umd.js"
%x{
  window.Stimulus    = Stimulus
  window.Controller  = Stimulus.Controller
  window.application = Stimulus.Application.start()
}
require "opal_stimulus/stimulus_controller"

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end
