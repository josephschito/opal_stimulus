# backtick_javascript: true

require "opal"
require "native"
require "js/proxy"

class StimulusController < `Controller`
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
        try {
          var wrappedArgs = args.map(function(arg) {
            if (arg && typeof arg === "object" && !arg.$$class) {
              return Opal.JS.Proxy.$new(arg);
            }
            return arg;
          });
          return this['$' + name].apply(this, wrappedArgs);
        } catch (e) {
          console.error("Uncaught", e);
        }
      }
    }
  end

  def self.register_all!
    subclasses.each do |controller|
      controller.define_method(:dummy) {}

      return if `application.controllers`.include?(`#{controller.stimulus_name}`)
      `application.register(#{controller.stimulus_name}, #{controller.stimulus_controller})`
    end
  end

  def self.targets=(targets = [])
    `#{self.stimulus_controller}.targets = targets`

    targets.each do |target|
      js_name = target.to_s
      ruby_name = self.to_ruby_name(target)

      define_method(ruby_name + "_target") do
        JS::Proxy.new(`this[#{js_name + "Target"}]`)
      end

      define_method(ruby_name + "_targets") do
        `this[#{js_name + "Targets"}]`.map do |el|
          JS::Proxy.new(el)
        end
      end

      define_method("has_" + ruby_name + "_target") do
        `this[#{"has" + js_name.capitalize + "Target"}]`
      end

      snake_case_connected = ruby_name + "_target_connected"
      camel_case_connected = js_name + "TargetConnected"
      %x{
        #{self.stimulus_controller}.prototype[#{camel_case_connected}] = function() {
          if (this['$respond_to?'] && this['$respond_to?'](#{snake_case_connected})) {
            return this['$' + #{snake_case_connected}]();
          }
        }
      }

      snake_case_disconnected = ruby_name + "_target_disconnected"
      camel_case_disconnected = js_name + "TargetDisconnected"
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
      js_name = outlet.to_s
      ruby_name = self.to_ruby_name(outlet)

      define_method(ruby_name + "_outlet") do
        `return this[#{js_name + "Outlet"}]`
      end

      define_method(ruby_name + "_outlets") do
        `this[#{js_name + "Outlets"}]`
      end

      define_method("has_" + ruby_name + "_outlet") do
        `return this[#{"has" + js_name.capitalize + "Outlet"}]`
      end

      snake_case_connected = ruby_name + "_outlet_connected"
      camel_case_connected = js_name + "OutletConnected"
      %x{
        #{self.stimulus_controller}.prototype[#{camel_case_connected}] = function() {
          if (this['$respond_to?'] && this['$respond_to?'](#{snake_case_connected})) {
            return this['$' + #{snake_case_connected}]();
          }
        }
      }

      snake_case_disconnected = ruby_name + "_outlet_disconnected"
      camel_case_disconnected = js_name + "OutletDisconnected"
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
      name = self.to_ruby_name(name)

      js_type = case type
      when :string then `String`
      when :number then `Number`
      when :boolean then `Boolean`
      when :array then `Array`
      when :object then `Object`
      else
        raise ArgumentError,
          "Unsupported value type: #{type}, please use :string, :number, :boolean, :array, or :object"
      end

      js_values[name] = js_type

      `#{self.stimulus_controller}.values = #{js_values.to_n}`

      define_method(name + "_value") do
        Native(`this[#{name + "Value"}]`)
      end

      define_method(name + "_value=") do |value|
        Native(`this[#{name + "Value"}]= #{value}`)
      end

      define_method("has_#{name}") do
        `return this[#{"has" + name.to_s.capitalize + "Value"}]`
      end

      snake_case_changed = "#{name}_value_changed"
      camel_case_changed = "#{name}ValueChanged"
      %x{
        #{self.stimulus_controller}.prototype[#{camel_case_changed}] = function(value, previousValue) {
          if (#{type == :object}) {
            value = JSON.stringify(value)
            previousValue = JSON.stringify(previousValue)
          }
          if (this['$respond_to?'] && this['$respond_to?'](#{snake_case_changed})) {
            return this['$' + #{snake_case_changed}](value, previousValue);
          }
        }
      }
    end
  end

  def self.classes=(class_names = [])
    `#{self.stimulus_controller}.classes = class_names`

    class_names.each do |class_name|
      js_name = class_name.to_s
      ruby_name = self.to_ruby_name(class_name)

      define_method("#{ruby_name}_class") do
        `return this[#{js_name + "Class"}]`
      end

      define_method("#{ruby_name}_classes") do
        `return this[#{js_name + "Classes"}]`
      end

      define_method("has_#{ruby_name}_class") do
        `return this[#{"has" + js_name.capitalize + "Class"}]`
      end
    end
  end

  def element
    JS::Proxy.new(`this.element`)
  end

  def self.to_ruby_name(name)
    name
      .to_s
      .gsub(/([A-Z]+)/) { "_#{$1.downcase}" }
      .sub(/^_/, '')
  end

  def window
    @window ||= JS::Proxy.new($$.window)
  end

  def document
    @document ||= JS::Proxy.new($$.document)
  end
end
