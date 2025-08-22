APPLICATION_LAYOUT_PATH = Rails.root.join("app/views/layouts/application.html.erb")
APPLICATION_OPAL_STIMULUS_BIN_PATH = Rails.root.join("bin")
APPLICATION_OPAL_STIMULUS_PATH = Rails.root.join("app/opal")

if File.exist? APPLICATION_LAYOUT_PATH
  say "Adding Opal Stimulus to the application layout", :green
  insert_into_file APPLICATION_LAYOUT_PATH, after: "<%= javascript_importmap_tags %>\n" do
    <<-ERB
    <script type="module">
      import "<%= javascript_path("opal") %>"
    </script>
    ERB
  end

  say "Creating Opal Stimulus files", :green
  if Rails.root.join("Procfile.dev").exist?
    append_to_file "Procfile.dev", "opal: bin/rails opal_stimulus:watch\n"
  else
    say "Add default Procfile.dev"
    copy_file "#{__dir__}/Procfile.dev", "Procfile.dev"

    say "Ensure foreman is installed"
    run "gem install foreman"
  end

  manifest = Rails.root.join("app/assets/config/manifest.js")
  if manifest.exist?
    append_to_file manifest, "//= link opal.js"
  end
  append_to_file ".gitignore", "/.opal-cache\n"
  append_to_file ".gitignore", "app/assets/builds/opal.js\n"
  append_to_file ".gitignore", "app/assets/builds/opal.js.map\n"
  empty_directory APPLICATION_OPAL_STIMULUS_BIN_PATH
  empty_directory APPLICATION_OPAL_STIMULUS_PATH
  empty_directory "#{APPLICATION_OPAL_STIMULUS_PATH}/controllers"
  keep_file "#{APPLICATION_OPAL_STIMULUS_PATH}/controllers"
  keep_file "app/assets/builds"
  copy_file "#{__dir__}/dev", "#{APPLICATION_OPAL_STIMULUS_BIN_PATH}/dev"
  FileUtils.chmod("+x", "#{APPLICATION_OPAL_STIMULUS_BIN_PATH}/dev")
  copy_file "#{__dir__}/application.rb", "#{APPLICATION_OPAL_STIMULUS_PATH}/application.rb"
end
