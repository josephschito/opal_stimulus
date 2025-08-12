require "test_helper"
require "selenium-webdriver"
require "webdriver_helpers"

class TestOpalStimulus < Minitest::Test
  include WebdriverHelpers

  parallelize_me!

  def test_initialization
    opal_code = <<~RUBY
      JS::Proxy.new($$.document).body.inner_html = <<~HTML
        <div data-controller="hello"></div>
      HTML

      class HelloController < StimulusController
        def initialize
          puts "initialized"
        end
      end
    RUBY

    @driver.navigate.to(index_url)
    @driver.execute_script(compile_opal(opal_code))
    logs = @driver.logs.get(:browser)

    assert_equal logs.length, 1
    assert logs.first.message.include? "initialized"
  end

  def test_connection
    opal_code = <<~RUBY
      JS::Proxy.new($$.document).body.inner_html = <<~HTML
        <div data-controller="hello"></div>
      HTML

      class HelloController < StimulusController
        def connect
          puts "connected"
        end
      end
    RUBY

    @driver.navigate.to(index_url)
    @driver.execute_script(compile_opal(opal_code))
    logs = @driver.logs.get(:browser)

    assert_equal 1, logs.length
    assert logs.first.message.include? "connected"
  end

  def test_added_method
    opal_code = <<~'RUBY'
      JS::Proxy.new($$.document).body.inner_html = <<~HTML
        <div data-controller="hello">
          <button data-action='hello#greet'>Greet Pagani!</button>
        </div>
      HTML

      class HelloController < StimulusController
        def greet
          puts "Hello Horacio!"
        end
      end
    RUBY

    @driver.navigate.to(index_url)
    @driver.execute_script(compile_opal(opal_code))
    @driver.find_element(css: '[data-action="hello#greet"]').click
    logs = @driver.logs.get(:browser)

    assert_equal 1, logs.length
    assert logs.first.message.include? "Hello Horacio!"
  end

  def test_added_method_with_event
    opal_code = <<~'RUBY'
      JS::Proxy.new($$.document).body.inner_html = <<~HTML
        <div data-controller="resize-logger" data-action="resize@window->resize-logger#resizing"></div>
      HTML

      class ResizeLoggerController < StimulusController
        def resizing(event)
          @resized ||= false
          return if @resized
          @resized = true
          puts "Resized to: #{event.target.inner_width}"
        end
      end
    RUBY

    @driver.navigate.to(index_url)
    @driver.execute_script(compile_opal(opal_code))
    @driver.manage.window.resize_to(601, 200)
    logs = @driver.logs.get(:browser)

    assert_equal 1, logs.length
    assert logs.first.message.include? "Resized to: 601"
  end

  def test_targets
    opal_code = <<~'RUBY'
      JS::Proxy.new($$.document).body.inner_html = <<~HTML
        <div data-controller="hello">
          <h1 data-hello-target="header" data-action="click->hello#delete_header"></h1>
        </div>
      HTML

      class HelloController < StimulusController
        self.targets = ["header"]

        def header_target_connected
          if has_header_target && `#{header_targets.first.to_n} === #{header_target.to_n}`
            header_target.text_content = "Hello from target!"
          end
        end

        def header_target_disconnected
          puts "header target disconnected"
        end

        def delete_header(event)
          event.target.remove
        end
      end
    RUBY

    @driver.navigate.to(index_url)
    @driver.execute_script(compile_opal(opal_code))

    assert_equal(@driver.find_elements(css: '[data-controller="hello"]').first.text, "Hello from target!")

    @driver.find_element(css: '[data-hello-target="header"]').click
    logs = @driver.logs.get(:browser)

    assert_equal 1, logs.length
    assert logs.first.message.include? "header target disconnected"
  end

  def test_outlets
    opal_code = <<~'RUBY'
      JS::Proxy.new($$.document).body.inner_html = <<~HTML
        <div data-controller="hello" data-hello-message-outlet=".message">
          <button data-action="hello#delete_outlet">Delete outlet</button>
        </div>
        <div data-controller="message" class="message"></div>
      HTML

      class MessageController < StimulusController
        def log(message)
          puts message
        end

        def remove
          element.remove
        end
      end

      class HelloController < StimulusController
        self.outlets = ["message"]

        def delete_outlet
          message_outlet.remove
        end

        def message_outlet_connected(outlet, element)
          if message_outlet && has_message_outlet && "#{message_outlets.first} === #{message_outlet}"
            message_outlet.log("message outlet's `log` method called from hello Controller")
          end
        end

        def message_outlet_disconnected(outlet, element)
          puts "message outlet disconnected"
        end
      end
    RUBY

    @driver.navigate.to(index_url)
    @driver.execute_script(compile_opal(opal_code))
    @driver.find_element(css: '[data-action="hello#delete_outlet"]').click
    logs = @driver.logs.get(:browser)

    assert_equal 2, logs.length
    assert logs[0].message.include? "message outlet's `log` method called from hello Controller"
    assert logs[1].message.include? "message outlet disconnected"
  end

  def test_values
    opal_code = <<~'RUBY'
      JS::Proxy.new($$.document).body.inner_html = <<~HTML
        <div
          data-controller="hello"
            data-hello-name-value="Zonda HH"
            data-hello-year-value="2004"
            data-hello-amazing-value="true"
            data-hello-clients-value='["A secret american"]'
            data-hello-author-value='{"name": "Horacio Pagani", "country": "Argentina"}'
        >
          <button data-action="hello#log_name">Log name</button>
        </div>
      HTML

      class HelloController < StimulusController
        self.values = {
          name:    :string,
          year:    :number,
          amazing: :boolean,
          clients: :array,
          author:  :object,
        }

        def connect
          puts name_value
          puts year_value
          puts amazing_value
          puts clients_value
          puts author_value[:name]
          puts author_value[:country]
          x = author_value.merge!({ country: "Italy" })
          self.author_value = x
        end

        def name_value_changed(new_value, old_value)
          puts "name: from #{old_value} to #{new_value}"
        end

        def year_value_changed(new_value, old_value)
          puts "year: from #{old_value} to #{new_value}"
        end

        def amazing_value_changed(new_value, old_value)
          puts "amazing: from #{old_value} to #{new_value}"
        end

        def clients_value_changed(new_value, old_value)
          puts "clients: from #{old_value} to #{new_value}"
        end

        def author_value_changed(new_value, old_value)
          puts "author: from #{old_value} to #{new_value}"
        end
      end
    RUBY

    @driver.navigate.to(index_url)
    @driver.execute_script(compile_opal(opal_code))
    logs = @driver.logs.get(:browser)

    assert_equal 12, logs.length
    assert logs[0].message.include? 'name: from  to Zonda HH\n'
    assert logs[1].message.include? 'year: from 0 to 2004\n'
    assert logs[2].message.include? 'amazing: from false to true\n'
    assert logs[3].message.include? 'clients: from  to A secret american\n'
    assert logs[4].message.include? 'author: from {} to {\"name\":\"Horacio Pagani\",\"country\":\"Argentina\"}\n'
    assert logs[5].message.include? "Zonda HH"
    assert logs[6].message.include? "2004"
    assert logs[7].message.include? "true"
    assert logs[8].message.include? "A secret american"
    assert logs[9].message.include? "Horacio Pagani"
    assert logs[10].message.include? "Argentina"
    assert logs[11].message.include? 'author: from {\"name\":\"Horacio Pagani\",\"country\":\"Argentina\"} to {\"$$id\":82,\"native\":{\"name\":\"Horacio Pagani\",\"country\":\"Italy\"}}\n'
  end

  def test_classes
    opal_code = <<~'RUBY'
      JS::Proxy.new($$.document).body.inner_html = <<~HTML
        <div data-controller="hello" data-hello-active-class="active"></div>
      HTML

      class HelloController < StimulusController
        self.classes = ["active"]

        def connect
          if has_active_class && `#{active_classes.first.to_n} === #{active_class.to_n}`
            element.class_list.add(active_class)
          end
        end
      end
    RUBY

    @driver.navigate.to(index_url)

    assert @driver.find_elements(css: '[class="active"]').none?

    @driver.execute_script(compile_opal(opal_code))

    assert @driver.find_elements(css: '[class="active"]').any?
  end

  def test_element
    opal_code = <<~'RUBY'
      JS::Proxy.new($$.document).body.inner_html = <<~HTML
        <div data-controller="hello" data-hello-target="element"></div>
      HTML

      class HelloController < StimulusController
        self.targets = ["element"]

        def connect
          puts `#{element.to_n} === #{element_target.to_n}`
        end
      end
    RUBY

    @driver.navigate.to(index_url)
    @driver.execute_script(compile_opal(opal_code))
    logs = @driver.logs.get(:browser)

    assert 1, logs.length
    assert logs[0].message.include? "true"
  end
end
