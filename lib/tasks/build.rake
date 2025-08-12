require "bundler/setup"
require "listen"
require "opal"

namespace :opal_stimulus do
  def prepare_paths
    [ "opal_proxy", "opal_stimulus" ].each do |gem_name|
      Opal.use_gem(gem_name) rescue Opal.append_path(File.expand_path("lib", Bundler.rubygems.find_name(gem_name).first.full_gem_path))
    end

    Opal.append_path(Rails.root.join("app/opal"))
  end

  def compile
    puts "🔨 Compiling Opal..."

    builder = Opal::Builder.new
    result = builder.build("application")
    output_path = Rails.root.join("app/assets/builds/opal.js")
    code = result.to_s

    if Rails.env.development?
      code += "//# sourceMappingURL=/assets/opal.js.map"
      sourcemap_path = "#{output_path}.map"
      source_map_json = result.source_map.to_json
      File.write(sourcemap_path, source_map_json)
    end

    File.write(output_path, code)

    puts "✅ Compiled to #{output_path}"
  end

  desc "Build Opal Stimulus controllers"
  task build: [:environment] do
    prepare_paths
    compile
  end

  desc "Watch and build Opal Stimulus controllers"
  task watch: [:environment] do
    prepare_paths

    compile

    listen = Listen.to(Rails.root.join("app/opal")) { compile }

    puts "👀 Watching app/opal for changes..."
    listen.start
    Signal.trap("INT") { listen.stop }
    sleep
  end
end
