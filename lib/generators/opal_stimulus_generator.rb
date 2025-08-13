require "rails/generators/named_base"

class OpalStimulusGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def create_controller_file
    template "controller.rb.tt", File.join("app/opal/controllers", class_path, "#{file_name}_controller.rb")
  end
end
