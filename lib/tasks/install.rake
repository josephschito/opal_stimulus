namespace :opal_stimulus do
  desc "Install Opal Stimulus into the app"
  task install: [:environment] do
    system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../install/install_opal_stimulus.rb", __dir__)}"
  end
end
