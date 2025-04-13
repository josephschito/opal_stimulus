# OpalStimulus: Write Stimulus.js in Ruby

**OpalStimulus** allows you to write your [Stimulus](https://stimulus.hotwired.dev/) controllers in pure Ruby. No more context switching between Ruby and JavaScript in your Rails apps - do everything in Ruby while maintaining all Stimulus functionality.

## Why OpalStimulus?

- Write Stimulus controllers in Ruby instead of JavaScript
- Use Ruby naming conventions (snake_case instead of camelCase)
- Automatic type conversion between Ruby and JavaScript
- Elegant syntax for defining targets, classes, values, and actions
- Maintain a consistent development experience in a single language

## Installation

Add this line to your Gemfile:

```ruby
gem 'opal_stimulus'
```

Then execute:

```bash
bundle install
rails generate opal_stimulus:install
```

This command installs everything you need, including Opal configuration files, Stimulus importmaps, and an example controller.

## Basic Example

Here's a Hello World example with OpalStimulus. Compare with the [original JavaScript example](https://stimulus.hotwired.dev/handbook/hello-stimulus):

**Ruby Controller:**

```ruby
# app/opal/controllers/hello_controller.rb
class HelloController < StimulusController
  self.targets = ["name"]

  def greet
    if has_name_target
      element.text_content = "Hello, #{name_target.value}!"
    else
      element.text_content = "Hello, World!"
    end
  end
end
```

**HTML:**

```html
<div data-controller="hello">
  <input data-hello-target="name" type="text">
  <button data-action="click->hello#greet">Greet</button>
  <span></span>
</div>
```

## Advanced Features

### Targets

```ruby
class MyController < StimulusController
  self.targets = ["counter", "button"]

  def connect
    if has_counter_target
      counter_target.text_content = "0"
    end
  end

  def counter_target_connected
    puts "Counter target connected!"
  end
end
```

### Values

```ruby
class PreferenceController < StimulusController
  self.values = {
    theme: String,
    count: Integer,
    notifications: Boolean,
    contacts: Array,
    settings: Hash
  }

  def toggle_theme
    current = theme
    new_theme = current == "dark" ? "light" : "dark"
    `this.themeValue = #{new_theme}`
  end

  def theme_value_changed(new_value, old_value)
    puts "Theme changed from #{old_value} to #{new_value}"
  end
end
```

### CSS Classes

```ruby
class UiController < StimulusController
  self.classes = ["loading", "active", "error"]

  def start_loading
    add_loading_class
    has_loading_class?

    add_class("shake", my_element)
  end
end
```

### Actions

```ruby
class FormController < StimulusController
  def handle_submit
    puts "Form submitted! Event type: #{event.type}"

    if has_param?("redirect")
      redirect_url = get_param("redirect")
    end

    dispatch_event("form:submitted", { success: true })
  end
end
```

## How It Works

OpalStimulus uses [Opal](https://opalrb.com) to compile your Ruby code into JavaScript, creating bridges between the two worlds. Everything is managed for you, eliminating the need to write JavaScript code.

Behind the scenes, OpalStimulus creates bridges between Ruby snake_case methods and JavaScript camelCase methods, allowing you to follow Ruby conventions while producing Stimulus-compatible JavaScript code.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

For experimenting, use `bin/console` for an interactive prompt.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/josephschito/opal_stimulus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
