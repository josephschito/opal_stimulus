module OpalStimulus
  class Railtie < Rails::Railtie
    initializer "opal_stimulus.ignore_opal_dir" do
      Rails.autoloaders.each do |autoloader|
        autoloader.ignore(Rails.root.join("app/opal"))
      end
    end
  end
end
