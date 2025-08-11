# Opal Stimulus for Rails

**Opal Stimulus** is a Stimulus wrapper made with Opal (a source-to-source Ruby to JavaScript compiler) that allows you to write Stimulus controllers in Ruby instead of JavaScript (It works only with Rails).

[![Ruby](https://github.com/josephschito/opal_stimulus/actions/workflows/main.yml/badge.svg)](https://github.com/josephschito/opal_stimulus/actions/workflows/main.yml)

## Installation

Add this line to your Gemfile:

```ruby
gem 'opal_stimulus'
```

Execute:

```bash
bundle install
rails opal_stimulus:install
```

Start application:

```bash
bin/dev
```

## Basic Example

Here's a Hello World example with OpalStimulus. Compare with the [original JavaScript example](https://stimulus.hotwired.dev/#:~:text=%2F%2F%20hello_controller.js%0Aimport%20%7B%20Controller%20%7D%20from%20%22stimulus%22%0A%0Aexport%20default%20class%20extends%20Controller%20%7B%0A%20%20static%20targets%20%3D%20%5B%20%22name%22%2C%20%22output%22%20%5D%0A%0A%20%20greet()%20%7B%0A%20%20%20%20this.outputTarget.textContent%20%3D%0A%20%20%20%20%20%20%60Hello%2C%20%24%7Bthis.nameTarget.value%7D!%60%0A%20%20%7D%0A%7D):

**Ruby Controller:**

```ruby
# app/opal/controllers/hello_controller.rb
# new controllers will be automatically added to app/opal/controllers_requires.rb
#   (ordered files load is not supported yet)
class HelloController < StimulusController
  self.targets = ["name", "output"]

  def greet
    output_target.text_content = "Hello, #{name_target.value}!"
  end
end
```

**HTML:**

```html
<div data-controller="hello">
  <input data-hello-target="name" type="text">

  <button data-action="click->hello#greet">
    Greet
  </button>

  <span data-hello-target="output">
  </span>
</div>
```

**Result**

https://github.com/user-attachments/assets/c51ed28c-13d2-4e06-b882-1cc997e9627b

**Notes:**

- In general any reference method is snake cased, so `container` target will produce `container_target` and not ~`containerTarget`~
- Any `target`, `element`, `document`, `window` and `event` is a `JS::Proxy` instance, that provides a dynamic interface to JavaScript objects in Opal
- The frontend definition part will remain the same


## Some examples based on [Stimulus Reference](https://stimulus.hotwired.dev/reference/controllers)

### Lifecycle Callbacks
```ruby
class AlertController < StimulusController
  def initialize; end
  def connect; end
  def disconnect; end
end
```

### Actions
```ruby
class WindowResizeController < StimulusController
  def resized(event)
    if !@resized && event.target.inner_width >= 1080
      puts "Full HD? Nice!"
      @resized = true
    end
  end
end
```

### Targets
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
```ruby
class SearchController < StimulusController
  self.classes = [ "loading" ]

  def loadResults
    element.class_list.add loading_class
  end
end
```

## Extra tools
### Window
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

### Document
```ruby
class DocumentController < StimulusController
  def connect
    headers = document.querySelectorAll("h1")
    headers.each do |h1|
      h1.text_content = "Opal is great!"
    end
  end
end
```

## Run tests
`bundle exec rake`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/josephschito/opal_stimulus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
