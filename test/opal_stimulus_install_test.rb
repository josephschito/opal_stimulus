# test/opal_stimulus_install_test.rb
require "minitest/autorun"
require "fileutils"
require "open3"
require "tmpdir"

class OpalStimulusInstallTest < Minitest::Test
  parallelize_me!

  def setup
    @tmpdir = Dir.mktmpdir
    @app_path = File.join(@tmpdir, "dummy_app")
  end

  def teardown
    FileUtils.remove_entry @tmpdir
  end

  def run_command(cmd, chdir: @tmpdir)
    out, err, status = Open3.capture3(cmd, chdir: chdir)
    unless status.success?
      flunk "Command failed: #{cmd}\nSTDOUT:\n#{out}\nSTDERR:\n#{err}"
    end
    out
  end

  def test_install_opal_stimulus_in_rails_7_2
    test_on_rails("7.2")
  end

  def test_install_opal_stimulus_in_rails_8
    test_on_rails("8")
  end

  private

  def test_on_rails(version)
    run_command("gem install rails -v #{version}")
    run_command("rails _#{version}_ new dummy_app --skip-bootsnap", chdir: @tmpdir)

    gemfile_path = File.join(@app_path, "Gemfile")
    gemfile = File.read(gemfile_path)
    gemfile << "\ngem 'opal_stimulus', path: '../../'\n"
    File.write(gemfile_path, gemfile)

    FileUtils.rm_f(File.join(@app_path, "config", "initializers", "assets.rb"))

    run_command("bundle install", chdir: @app_path)

    out, err, status = Open3.capture3("bin/rails opal_stimulus:install", chdir: @app_path)
    unless status.success?
      flunk "opal_stimulus:install failed\nSTDOUT:\n#{out}\nSTDERR:\n#{err}"
    end

    ["my", "my/best"].each do |gen|
      Open3.capture3("bin/rails g opal_stimulus #{gen}", chdir: @app_path)
    end
    Open3.capture3("bin/rails g controller pages index", chdir: @app_path)

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
