require "opal_stimulus/stimulus_controller"
require "controllers_requires"

StimulusController.subclasses.each do |controller|
  controller.define_method(:dummy) { }

  return if `Stimulus.controllers`.include?(`#{controller.stimulus_name}`)
  `Stimulus.register(#{controller.stimulus_name}, #{controller.stimulus_controller})`
end
