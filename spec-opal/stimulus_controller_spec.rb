# backtick_javascript: true

require "spec_helper"

RSpec.describe StimulusController do
  describe ".inherited" do
    class MyController < described_class; end

    it "bridges inherited class to Opal" do
      expect {
        Opal.bridge(described_class, MyController)
      }.to raise_error("already bridged")
    end
  end

  describe ".stimulus_controller" do
    class MyController < described_class; end

    it "sets `stimulus_controller` with a basic Controller" do
      expect(`Object.getPrototypeOf(#{MyController.stimulus_controller})`).to eq(`Controller`)
    end
  end

  describe ".stimulus_name" do
    context "when is one word" do
      class MyController < described_class; end

      it "it returns it downcased" do
        expect(MyController.stimulus_name).to eq("my")
      end
    end

    context "when is multiple words" do
      class MyBestController < described_class; end

      it "it returns them separated by `-`" do
        expect(MyBestController.stimulus_name).to eq("my-best")
      end
    end

    context "when has namespaces" do
      module My; end
      class My::VeryBestController < described_class; end

      it "it returns them separated by `--`" do
        expect(My::VeryBestController.stimulus_name).to eq("my--very-best")
      end
    end
  end

  describe ".method_added" do
    it "returns the same bridged class method result" do
      class MyController < described_class
        def hello_world
          "Hello world!"
        end
      end

      expect(MyController.new.hello_world).to eq(`#{MyController.stimulus_controller}.prototype["hello_world"]()`)
    end
  end

  describe ".to_ruby_name" do
    it "converts camelCase to snake_case" do
      expect(described_class.to_ruby_name("myMethod")).to eq("my_method")
      expect(described_class.to_ruby_name("anotherExample")).to eq("another_example")
      expect(described_class.to_ruby_name("YetAnotherTest")).to eq("yet_another_test")
    end

    it "does not change already snake_case names" do
      expect(described_class.to_ruby_name("already_snake_case")).to eq("already_snake_case")
    end
  end

  describe ".register_all!" do
    class MyController < described_class; end
    StimulusController.register_all!

    it "should register controller" do
      expect(`application.router.modules[0].definition.identifier`).to eq("my")
    end

    it "sould respond to `dummy` method" do
      expect(MyController.new).to respond_to(:dummy)
    end
  end

  describe ".targets=" do
    class MyController < described_class
      self.targets = ["container"]

      def container_target_connected = "Container Target connected!"
      def container_target_disconnected = "Container Target disconnected!"
    end

    it "defines all target methods and maps callbacks" do
      my_controller = MyController.new
      expect(my_controller).to respond_to(:container_target)
      expect(my_controller).to respond_to(:container_targets)
      expect(my_controller).to respond_to(:has_container_target)
      expect(MyController.new.container_target_connected)
        .to eq(`#{MyController.stimulus_controller}.prototype["containerTargetConnected"]()`)
      expect(MyController.new.container_target_disconnected)
        .to eq(`#{MyController.stimulus_controller}.prototype["containerTargetDisconnected"]()`)
    end

    it "returns a `JS::Proxy` instance whe `container_target` is called" do
      my_controller = MyController.new
      expect(my_controller.container_target).to be_a(JS::Proxy)
    end
  end

  describe ".outlets=" do
    class MyController < described_class
      self.outlets = ["container"]

      def container_outlet_connected = "Container Outlet connected!"
      def container_outlet_disconnected = "Container Outlet disconnected!"
    end

    it "defines all outlet methods and maps callbacks" do
      my_controller = MyController.new
      expect(my_controller).to respond_to(:container_outlet)
      expect(my_controller).to respond_to(:container_outlets)
      expect(my_controller).to respond_to(:has_container_outlet)
      expect(MyController.new.container_outlet_connected)
        .to eq(`#{MyController.stimulus_controller}.prototype["containerOutletConnected"]()`)
      expect(MyController.new.container_outlet_disconnected)
        .to eq(`#{MyController.stimulus_controller}.prototype["containerOutletDisconnected"]()`)
    end
  end

  describe ".values=" do
    it "sets bridged class `values`" do
      class MyController < described_class
        self.values = {
          name:  :string,
          age:   :number,
          alive: :boolean,
          cars:  :array,
          notes: :object
        }
      end

      expect(`#{MyController}.stimulus_controller.values.name === String`).to be_truthy
      expect(`#{MyController}.stimulus_controller.values.age === Number`).to be_truthy
      expect(`#{MyController}.stimulus_controller.values.alive === Boolean`).to be_truthy
      expect(`#{MyController}.stimulus_controller.values.cars === Array`).to be_truthy
      expect(`#{MyController}.stimulus_controller.values.notes === Object`).to be_truthy
    end

    it "defines all values methods" do
      class MyController < described_class
        self.values = {
          name: :string
        }

        def name_value_changed(value, previous_value)
          "Name value changed from #{previous_value} to #{value}!"
        end
      end

      my_controller = MyController.new
      expect(my_controller).to respond_to(:name_value)
      expect(my_controller).to respond_to(:name_value=)
      expect(my_controller).to respond_to(:has_name)
      expect(MyController.new.name_value_changed(:new, :prev))
        .to eq(`#{MyController.stimulus_controller}.prototype["nameValueChanged"]("new", "prev")`)
    end

    context "when unsupported type is passed" do
      it "raises `ArgumentError`" do
        expect {
          class MyController < described_class
            self.values = { age: :parsec }
          end
        }.to raise_error("Unsupported value type: parsec, please use :string, :number, :boolean, :array, or :object")
      end
    end
  end

  describe ".classes" do
    it "defines all classes methods" do
      class MyController < described_class
        self.classes = ["active"]
      end

      my_controller = MyController.new
      expect(my_controller).to respond_to(:active_class)
      expect(my_controller).to respond_to(:active_classes)
      expect(my_controller).to respond_to(:has_active_class)
    end
  end

  describe "#element" do
    it "has been tested with selenium" do
    end
  end

  describe "#window" do
    it "returns a `JS::Proxy`" do |example|
      class MyController < described_class; end

      expect(MyController.new.window).to be_a(JS::Proxy)
    end
  end

  describe "#document" do
    it "returns a `JS::Proxy`" do
      class MyController < described_class; end

      expect(MyController.new.document).to be_a(JS::Proxy)
    end
  end
end
