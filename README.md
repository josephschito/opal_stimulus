# Opal Stimulus for Rails

Write your [Stimulus](https://stimulus.hotwired.dev/) controllers in Ruby instead of JavaScript! 🎉

**Opal Stimulus** uses the [Opal Ruby-to-JavaScript compiler](https://opalrb.com/) to bring the elegance of Ruby to your frontend controllers. If you love Ruby and prefer its syntax over JavaScript, this gem is for you.

**Compatibility:** Rails 7.2+ to 8.0.2

[![Ruby](https://github.com/josephschito/opal_stimulus/actions/workflows/main.yml/badge.svg)](https://github.com/josephschito/opal_stimulus/actions/workflows/main.yml)

## Quick Start

Add to your Rails app and get started in seconds:

```bash
bundle add opal_stimulus
rails opal_stimulus:install
bin/dev
```

Generate your first Ruby controller:

```bash
bin/rails generate opal_stimulus hello
```

This creates `app/opal/controllers/hello_controller.rb`. If you have an existing JavaScript controller, you can remove it:

```bash
bin/rails destroy stimulus hello  # removes app/javascript/controllers/hello_controller.js
```

## Example: Hello World

Here's the classic Stimulus example, but in Ruby! Compare with the [JavaScript version](https://stimulus.hotwired.dev/#:~:text=%2F%2F%20hello_controller.js%0Aimport%20%7B%20Controller%20%7D%20from%20%22stimulus%22%0A%0Aexport%20default%20class%20extends%20Controller%20%7B%0A%20%20static%20targets%20%3D%20%5B%20%22name%22%2C%20%22output%22%20%5D%0A%0A%20%20greet()%20%7B%0A%20%20%20%20this.outputTarget.textContent%20%3D%0A%20%20%20%20%20%20%60Hello%2C%20%24%7Bthis.nameTarget.value%7D!%60%0A%20%20%7D%0A%7D).

**Ruby Controller (`app/opal/controllers/hello_controller.rb`):**

```ruby
class HelloController < StimulusController
  self.targets = ["name", "output"]

  def greet
    output_target.text_content = "Hello, #{name_target.value}!"
  end
end
```

**HTML (unchanged from regular Stimulus):**

```html
<div data-controller="hello">
  <input data-hello-target="name" type="text">
  <button data-action="click->hello#greet">Greet</button>
  <span data-hello-target="output"></span>
</div>
```

### Key Differences from JavaScript Stimulus

- **Snake case**: JavaScript's `containerTarget` becomes `container_target` in Ruby
- **DOM objects**: All `target`, `element`, `document`, `window`, and `event` objects are `JS::Proxy` instances that provide Ruby-friendly access to JavaScript APIs
- **HTML stays the same**: Your templates and data attributes work exactly like regular Stimulus

## Reference Examples

Based on the [Stimulus Reference](https://stimulus.hotwired.dev/reference/controllers), here's how common patterns work in Ruby:

### Lifecycle Callbacks

> 📚 [Stimulus Lifecycle Callbacks Reference](https://stimulus.hotwired.dev/reference/lifecycle-callbacks)

```ruby
class AlertController < StimulusController
  def initialize; end
  def connect; end
  def disconnect; end
end
```

### Actions & Events

> 📚 [Stimulus Actions Reference](https://stimulus.hotwired.dev/reference/actions)

```ruby
class WindowResizeController < StimulusController
  def resized(event)
    if !@resized && event.target.inner_width >= 1080
      puts "Full HD detected!"
      @resized = true
    end
  end
end
```

### Targets

> 📚 [Stimulus Targets Reference](https://stimulus.hotwired.dev/reference/targets)

```ruby
class ContainerController < StimulusController
  self.targets = ["container"]

  def container_target_connected
    container_target.inner_html = <<~HTML
      <h1>Test connected!</h1>
    HTML
  end

  def container_target_disconnected
    puts "Container disconnected!"
  end
end
```

### Outlets

> 📚 [Stimulus Outlets Reference](https://stimulus.hotwired.dev/reference/outlets)

```ruby
class ChatController < StimulusController
  self.outlets = [ "user-status" ]

  def connect
    user_status_outlets.each do |status|
      puts status
    end
  end
end
```

### Values

> 📚 [Stimulus Values Reference](https://stimulus.hotwired.dev/reference/values)

```ruby
class LoaderController < StimulusController
  self.values = { url: :string }

  def connect
    window.fetch(url_value).then do |response|
      response.json().then do |data|
        load_data(data)
      end
    end
  end

  private

  def load_data(data)
    # ...
  end
end
```

### CSS Classes

> 📚 [Stimulus CSS Classes Reference](https://stimulus.hotwired.dev/reference/css-classes)

```ruby
class SearchController < StimulusController
  self.classes = ["loading"]

  def load_results
    element.class_list.add(loading_class)
  end
end
```

## Working with the DOM

Opal Stimulus gives you Ruby-friendly access to all the browser APIs you know and love:

### `window`
```ruby
class WindowController < StimulusController
  def connect
    window.alert "Hello world!"
    window.set_timeout(-> {
      puts "1. Timeout test OK (1s delay)"
    }, 1000)
  end
end
```

### `document`
```ruby
class DocumentController < StimulusController
  def connect
    document.querySelectorAll("h1").each do |h1|
      h1.text_content = "Opal is great!"
    end
  end
end
```


## Development

Run the test suite:

```bash
bundle exec rake
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/josephschito/opal_stimulus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
