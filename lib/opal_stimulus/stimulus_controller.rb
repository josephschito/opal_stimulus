# backtick_javascript: true

require "opal"
require "native"
require "promise"
require "browser/setup/full"

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
    self.name.gsub(/Controller$/, "").gsub(/([a-z])([A-Z])/, '\1-\2').gsub("::", "--").downcase
  end

  def self.method_added(name)
    return if DEFAULT_GETTERS.include?(name)

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
        Browser::DOM::Element.new(`this[#{target + "Target"}]`)
      end

      define_method(target + "_targets") do
        `this[#{target + "Targets"}]`.map do |el|
          Browser::DOM::Element.new(el)
        end
      end

      define_method("has_" + target + "_target") do
        `return this[#{"has" + target.capitalize + "Target"}]`
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
        Browser::DOM::Element.new(`this[#{outlet + "Outlet"}]`)
      end

      define_method(outlet + "_outlets") do
        `this[#{outlet + "Outlets"}]`.map do |outlet|
          Browser::DOM::Element.new(outlet)
        end
      end

      define_method("has_" + outlet + "_outlet") do
        `return this[#{"has" + outlet.capitalize + "Outlet"}]`
      end

      snake_case_connected = outlet + "_outlet_connected"
      camel_case_connected = outlet + "OutletConnected"
      %x{
        #{self.stimulus_controller}.prototype[#{camel_case_connected}] = function() {
          if (this['$respond_to?'] && this['$respond_to?'](#{snake_case_connected})) {
            return this['$' + #{snake_case_connected}]();
          }
        }
      }

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

  def self.values=(values_hash = {})
    js_values = {}

    values_hash.each do |name, type|
      js_type = case type
      when String  then "String"
      when Integer, Float, Numeric then "Number"
      when TrueClass, FalseClass, Boolean then "Boolean"
      when Array  then "Array"
      when Hash, Object then "Object"
      else "String" # Default to String for unknown types
      end

      js_values[name] = js_type

      # Define value getter method (snake_case)
      define_method(name.to_s) do
        # Convert JavaScript value to appropriate Ruby type
        js_value = `this[#{name + "Value"}]`
        case type
        when String
          js_value.to_s
        when Integer
          js_value.to_i
        when Float
          js_value.to_f
        when TrueClass, FalseClass, Boolean
          !!js_value
        when Array
          Native::Array.new(js_value)
        when Hash, Object
          Native::Object.new(js_value)
        else
          js_value
        end
      end

      define_method("has_#{name}") do
        `return this[#{"has" + name.to_s.capitalize + "Value"}]`
      end

      snake_case_changed = "#{name}_value_changed"
      camel_case_changed = "#{name}ValueChanged"
      %x{
        #{self.stimulus_controller}.prototype[#{camel_case_changed}] = function(value, previousValue) {
          if (this['$respond_to?'] && this['$respond_to?'](#{snake_case_changed})) {
            return this['$' + #{snake_case_changed}](value, previousValue);
          }
        }
      }
    end

    `#{self.stimulus_controller}.values = #{js_values.to_n}`
  end

  def self.classes=(class_names = [])
    `#{self.stimulus_controller}.classes = #{class_names.to_n}`

    class_names.each do |class_name|
      define_method("add_#{class_name}_class") do
        `this.#{class_name}Classes.add()`
      end

      define_method("remove_#{class_name}_class") do
        `this.#{class_name}Classes.remove()`
      end

      define_method("has_#{class_name}_class?") do
        `return this.#{class_name}Classes.has()`
      end

      define_method("toggle_#{class_name}_class") do
        `this.#{class_name}Classes.toggle()`
      end
    end
  end

  def add_class(class_name, element = nil)
    if element
      `this.addClass(#{class_name}, #{element})`
    else
      `this.addClass(#{class_name})`
    end
  end

  def remove_class(class_name, element = nil)
    if element
      `this.removeClass(#{class_name}, #{element})`
    else
      `this.removeClass(#{class_name})`
    end
  end

  def has_class?(class_name, element = nil)
    if element
      `return this.hasClass(#{class_name}, #{element})`
    else
      `return this.hasClass(#{class_name})`
    end
  end

  def toggle_class(class_name, force = nil, element = nil)
    if element && force != nil
      `this.toggleClass(#{class_name}, #{force}, #{element})`
    elsif element
      `this.toggleClass(#{class_name}, #{element})`
    elsif force != nil
      `this.toggleClass(#{class_name}, #{force})`
    else
      `this.toggleClass(#{class_name})`
    end
  end

  def element
    `this.element`
  end
end
