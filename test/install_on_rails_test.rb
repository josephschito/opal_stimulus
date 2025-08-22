# test/opal_stimulus_install_test.rb
require "minitest/autorun"
require "fileutils"
require "open3"
require "tmpdir"

class InstallOnRailsTest < Minitest::Test
  parallelize_me!

  def setup
    @tmpdir = Dir.mktmpdir
    @app_path = File.join(@tmpdir, "dummy")
  end

  def teardown
    FileUtils.remove_entry @tmpdir
  end

  def run_command(cmd, chdir: @app_path)
    Open3.capture3(cmd, chdir: chdir)
  end

  def test_installation
    run_command("cp -R #{File.expand_path('test/dummy')} #{@tmpdir}", chdir: @tmpdir)
    run_command("bin/rails opal_stimulus:install", chdir: @app_path)

    ["my", "my/best"].each do |gen|
      Open3.capture3("bin/rails g opal_stimulus #{gen}", chdir: @app_path)
    end

    procfile_path = File.join(@app_path, "Procfile.dev")
    assert File.exist?(procfile_path)
    assert File.read(procfile_path).include?("opal: bin/rails opal_stimulus:watch")
    assert File.exist?(File.join(@app_path, "app/assets/builds/.keep"))
    assert File.exist?(File.join(@app_path, "app/opal/controllers/.keep"))
    assert File.exist?(File.join(@app_path, "app/opal/controllers/my_controller.rb"))
    assert File.exist?(File.join(@app_path, "app/opal/controllers/my/best_controller.rb"))
    assert File.exist?(File.join(@app_path, "app/opal/application.rb"))
    assert File.exist?(File.join(@app_path, "app/views/layouts/application.html.erb"))
    assert File.exist?(File.join(@app_path, "bin/dev"))
    manifest_path = File.join(@app_path, "app/assets/config/manifest.js")
    if File.exist?(manifest_path)
      assert File.read(manifest_path).include?("//= link opal.js")
    end
    gitignore = File.join(@app_path, ".gitignore")
    assert File.exist?(gitignore)
    content = File.read(gitignore)
    assert content.include?("/.opal-cache")
    assert content.include?("app/assets/builds/opal.js")
    assert content.include?("app/assets/builds/opal.js.map")

    run_command("bin/rails assets:precompile", chdir: @app_path)
    assert Dir.glob(File.join(@app_path, "public/assets/opal-*.js")).any?
  end
end
