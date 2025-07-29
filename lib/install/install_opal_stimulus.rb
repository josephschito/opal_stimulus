APPLICATION_LAYOUT_PATH = Rails.root.join("app/views/layouts/application.html.erb")
APPLICATION_OPAL_STIMULUS_BIN_PATH = Rails.root.join("bin")
APPLICATION_OPAL_STIMULUS_PATH = Rails.root.join("app/opal")

if File.exist? APPLICATION_LAYOUT_PATH
  say "Adding Opal Stimulus to the application layout", :green
  insert_into_file APPLICATION_LAYOUT_PATH, after: "<%= javascript_importmap_tags %>\n" do
    <<-ERB
    <script type="module">
      import "application"
      import "<%= javascript_path("opal") %>"
    </script>
    ERB
  end

  insert_into_file APPLICATION_LAYOUT_PATH, after: "<body>\n" do
    say "Adding `my-opal` to the application layout", :green
    <<-ERB
    <span data-controller="my-opal"></span>
    ERB
  end

  say "Creating Opal Stimulus files", :green
  if Rails.root.join("Procfile.dev").exist?
    append_to_file "Procfile.dev", "opal: bin/opal --watch\n"
  else
    say "Add default Procfile.dev"
    copy_file "#{__dir__}/Procfile.dev", "Procfile.dev"

    say "Ensure foreman is installed"
    run "gem install foreman"
  end
  insert_into_file Rails.root.join("app/javascript/controllers/application.js") do
    <<-JS
import { Controller } from "@hotwired/stimulus";

window.application = application;
window.Controller = Controller;
    JS
  end
  append_to_file ".gitignore", "/.opal-cache\n"
  append_to_file ".gitignore", "app/assets/builds/opal.js\n"
  append_to_file ".gitignore", "app/assets/builds/opal.js.map\n"
  empty_directory APPLICATION_OPAL_STIMULUS_BIN_PATH
  empty_directory APPLICATION_OPAL_STIMULUS_PATH
  empty_directory "#{APPLICATION_OPAL_STIMULUS_PATH}/controllers"
  empty_directory "#{APPLICATION_OPAL_STIMULUS_PATH}/app/assets/builds"
  create_file "app/assets/builds/.keep"
  copy_file "#{__dir__}/opal", "#{APPLICATION_OPAL_STIMULUS_BIN_PATH}/opal"
  FileUtils.chmod("+x", "#{APPLICATION_OPAL_STIMULUS_BIN_PATH}/opal")
  copy_file "#{__dir__}/dev", "#{APPLICATION_OPAL_STIMULUS_BIN_PATH}/dev"
  FileUtils.chmod("+x", "#{APPLICATION_OPAL_STIMULUS_BIN_PATH}/dev")
  copy_file "#{__dir__}/application.rb", "#{APPLICATION_OPAL_STIMULUS_PATH}/application.rb"
  copy_file "#{__dir__}/controllers_requires.rb", "#{APPLICATION_OPAL_STIMULUS_PATH}/controllers_requires.rb"
  copy_file "#{__dir__}/controllers/my_opal_controller.rb", "#{APPLICATION_OPAL_STIMULUS_PATH}/controllers/my_opal_controller.rb"
end
