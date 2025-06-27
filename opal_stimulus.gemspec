# frozen_string_literal: true

require_relative "lib/opal_stimulus/version"

Gem::Specification.new do |spec|
  spec.name = "opal_stimulus"
  spec.version = OpalStimulus::VERSION
  spec.authors = ["Joseph Schito"]
  spec.email = ["joseph.schito@gmail.com"]

  spec.summary = "Opal Stimulus: Write Stimulus controllers in Ruby"
  spec.description = "Opal Stimulus provides a way to write Stimulus controllers in Ruby, leveraging the Opal compiler to convert Ruby code into JavaScript. This allows developers familiar with Ruby to use the Stimulus framework without needing to write JavaScript directly."
  spec.homepage = "https://github.com/josephschito/opal_stimulus"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/josephschito/opal_stimulus"
  spec.metadata["changelog_uri"] = "https://github.com/josephschito/opal_stimulus/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
      f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile install/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "opal", "~> 1.8.2"
  spec.add_dependency "listen", "~> 3.9.0"
  spec.add_dependency "opal-browser", "~> 0.3.5"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
