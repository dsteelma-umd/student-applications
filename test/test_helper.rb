require 'simplecov'
require 'simplecov-rcov'
require 'database_cleaner'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]
SimpleCov.start

require 'securerandom'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'minitest/rails/capybara'

# Improved Minitest output (color and progress bar)
require 'minitest/reporters'

# add  Minitest::Reporters::SpecReporter.new to first param if you want to see
# what's running so slow.
Minitest::Reporters.use!(
  # Minitest::Reporters::SpecReporter.new,
  Minitest::Reporters::ProgressReporter.new,
  ENV,
  Minitest.backtrace_filter
)

# Capybara integration
require 'capybara/rails'
require 'capybara-screenshot/minitest'

# To see test in browser,
# use ":selenium_chrome" instead of ":selenium_chrome_headless"
Capybara.default_driver = :selenium_chrome_headless
Capybara.javascript_driver = :selenium_chrome_headless

require 'rack_session_access/capybara'

DatabaseCleaner.strategy = :truncation, { only: %w(prospects) }

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  self.use_transactional_tests = false
  # Add more helper methods to be used by all tests here...

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  # this returns a hash of a fixture with an existing fixture with a random
  # directory_id to pass validations
  def dup_fixture( name = :all_valid )
    fixture = prospects(:all_valid)
    fixture.directory_id = SecureRandom.hex
    fixture
  end


end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Screenshot::MiniTestPlugin

  before :after do
    DatabaseCleaner.clean
    Capybara.reset_sessions!
  end
end

# See: https://gist.github.com/mperham/3049152
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @shared_connection = nil

  def self.connection
    @shared_connection || ConnectionPool::Wrapper.new(size: 1) { retrieve_connection }
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

def drag_until(locator, options = {}, &block)
  slider = find(locator)
  event_input = slider.native
  page.driver.browser.action.click_and_hold(event_input).move_by(options[:by],0).release.perform until block.call(slider['aria-valuenow'].to_i)
  slider
end
