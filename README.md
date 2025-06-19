# Opal Stimulus for Rails

**Opal Stimulus** is a Stimulus wrapper made with Opal (a source-to-source Ruby to JavaScript compiler) that allows you to write Stimulus controllers in Ruby instead of JavaScript (It works only with Rails).

## Installation

Add this line to your Gemfile:

```ruby
gem 'opal_stimulus'
```

Execute:

```bash
bundle install
rails generate opal_stimulus:install
```

Start application:

```bash
bin/dev
```

## Basic Example

Here's a Hello World example with OpalStimulus. Compare with the [original JavaScript example](https://stimulus.hotwired.dev/handbook/hello-stimulus):

**Ruby Controller:**

```ruby
# app/opal/controllers/hello_controller.rb
# new controllers will be automatically added to app/opal/controllers_requires.rb
#   (ordered files load is not supported yet)
class HelloController < StimulusController
  self.targets = ["name", "output"]

  def greet
    output_target.JS[:textContent] = "Hello, #{name_target.JS[:value]}!"
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




## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/josephschito/opal_stimulus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
