module WebdriverHelpers
  def setup
    super

    options = headless_options
    options.add_option("goog:loggingPrefs", { browser: "ALL" })

    @driver = Selenium::WebDriver.for(:chrome, options: options)
  end

  def teardown
    super

    @driver.quit
  end

  def index_url
    file_path = File.expand_path("templates/stimulus@3.2.2.html", __dir__)
    "file://#{file_path}"
  end

  private

  def compile_opal(code)
    stimulus_controller =      Opal::Builder.build('opal_stimulus/stimulus_controller').to_s
    code =                     Opal::Compiler.new(code, requirable: false).compile
    controllers_registration = Opal::Compiler.new('StimulusController.register_all!', requirable: false).compile

    [ stimulus_controller, code, controllers_registration ].join("\n")
  end

  def headless_options
    Selenium::WebDriver::Chrome::Options.new.tap do |opts|
      opts.add_argument("--headless=new") unless ENV["NO_HEADLESS"]
      opts.add_argument("--disable-gpu")
      opts.add_argument("--no-sandbox")
      opts.add_argument("--disable-web-security")
      opts.add_argument("--allow-running-insecure-content")
      opts.add_argument("--enable-logging")
      opts.add_argument("--log-level=0")
      opts.add_argument("--v=1")
    end
  end

  extend self
end
