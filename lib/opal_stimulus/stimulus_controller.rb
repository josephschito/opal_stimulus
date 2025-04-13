# backtick_javascript: true

require "opal"
require "native"

class StimulusController < `Controller`
  include Native::Wrapper

  DEFAULT_METHODS = %i[initialize connect disconnect dispatch]
  DEFAULT_GETTERS = %i[element]

  def self.inherited(subclass)
    ::Opal.bridge(subclass.stimulus_controller, subclass)
  end

  def self.stimulus_controller
    return @stimulus_controller if @stimulus_controller
    @stimulus_controller = `class extends Controller {}`
    @stimulus_controller
  end

  def self.stimulus_name
    self.name.gsub(/Controller$/, '').gsub(/([a-z])([A-Z])/, '\1-\2').downcase
  end

  def self.method_added(name)
    return if DEFAULT_GETTERS.include?(name)

    # Register Stimulus controller after connect method is added
    define_method(:dummy) {} if name == :connect && self.stimulus_controller != `Controller`

    return if name.to_s.end_with?("_target_connected") || name.to_s.end_with?("_target_disconnected")

    self.bridge_method(name)
    unless DEFAULT_METHODS.include?(name)
      return if `Stimulus.controllers`.include?(`#{self.stimulus_name}`)
      `Stimulus.register(#{self.stimulus_name}, #{self.stimulus_controller})`
    end
  end

  def self.register(controller)
    `Stimulus.register(#{self.stimulus_name}, #{controller})`
  end

  def self.bridge_method(name)
    %x{
      #{self.stimulus_controller}.prototype[name] = function (...args) {
        return #{self.stimulus_controller}.prototype['$' + name].apply(this, args);
      }
    }
  end

  def self.targets=(targets = [])
    `#{self.stimulus_controller}.targets = targets`

    targets.each do |target|
      define_method(target + "_target") do
        `return this[#{target + 'Target'}]`
      end

      define_method(target + "_targets") do
        `return this[#{target + 'Targets'}]`
      end

      define_method("has_" + target + "_target") do
        `return this[#{'has' + target.capitalize + 'Target'}]`
      end

      snake_case_connected = target + "_target_connected"
      camel_case_connected = target + "TargetConnected"
      %x{
        #{self.stimulus_controller}.prototype[#{camel_case_connected}] = function() {
          if (this['$respond_to?'] && this['$respond_to?'](#{snake_case_connected})) {
            return this['$' + #{snake_case_connected}]();
          }
        }
      }

      # Define target disconnected callback bridge
      snake_case_disconnected = target + "_target_disconnected"
      camel_case_disconnected = target + "TargetDisconnected"
      %x{
        #{self.stimulus_controller}.prototype[#{camel_case_disconnected}] = function() {
          if (this['$respond_to?'] && this['$respond_to?'](#{snake_case_disconnected})) {
            return this['$' + #{snake_case_disconnected}]();
          }
        }
      }
    end
  end

  def self.outlets=(outlets = [])
    `#{self.stimulus_controller}.outlets = outlets`

    outlets.each do |outlet|
      define_method(outlet + "_outlet") do
        `return this[#{outlet + 'Outlet'}]`
      end

      define_method(outlet + "_outlets") do
        `return this[#{outlet + 'Outlets'}]`
      end

      define_method("has_" + outlet + "_outlet") do
        `return this[#{'has' + outlet.capitalize + 'Outlet'}]`
      end

      # Define outlet connected callback bridge
      snake_case_connected = outlet + "_outlet_connected"
      camel_case_connected = outlet + "OutletConnected"
      %x{
        #{self.stimulus_controller}.prototype[#{camel_case_connected}] = function() {
          if (this['$respond_to?'] && this['$respond_to?'](#{snake_case_connected})) {
            return this['$' + #{snake_case_connected}]();
          }
        }
      }

      # Define outlet disconnected callback bridge
      snake_case_disconnected = outlet + "_outlet_disconnected"
      camel_case_disconnected = outlet + "OutletDisconnected"
      %x{
        #{self.stimulus_controller}.prototype[#{camel_case_disconnected}] = function() {
          if (this['$respond_to?'] && this['$respond_to?'](#{snake_case_disconnected})) {
            return this['$' + #{snake_case_disconnected}]();
          }
        }
      }
    end
  end

  def element
    `this.element`
  end
end
