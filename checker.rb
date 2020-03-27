#!/usr/bin/env ruby
$stdout.sync = true
require 'dotenv/load'
require 'capybara'
require 'date'
require 'capybara/dsl'
require 'logger'
require 'selenium/webdriver'

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  [
    'headless',
    'window-size=1280x1280',
    'disable-gpu',
    'no-sandbox',
    'disable-dev-shm-usage'
  ].each { |arg| options.add_argument(arg) }

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# uncomment for debug
# Capybara.default_driver = Capybara.javascript_driver = :selenium_chrome

Capybara.default_driver = Capybara.javascript_driver = :headless_chrome

class SlotChecker
  include Capybara::DSL

  attr_reader :logger
  def initialize(username:, password:)
    @username = username
    @password = password
    @logger = Logger.new($stdout)
    @cookies_accepted = false
  end

  def accept_cookies
    return if @cookies_accepted

    visit 'https://www.waitrose.com/ecom/shop/browse/groceries'
    logger.info 'Accepting cookies'
    click_on 'Yes, allow all'
    self
  end

  def login
    visit 'https://www.waitrose.com/ecom/shop/browse/groceries'
    logger.info 'Logging in'
    logger.info 'clicking book slot'
    click_on 'Book slot'
    logger.info 'clicking book a delivery slot'
    find('#bookDeliverySlot', wait: 3).click
    find('#email').fill_in with: username
    find('#password').fill_in with: password
    click_on 'Sign in'
    self
  end

  def slots_available?
    has_text?('Sign out', wait: 5)
    result = has_no_css?('h1', text: /all slots are unavailable/i, wait: 1) &&
             has_no_css?('h1', text: /We're supporting the vulnerable and elderly/i, wait: 1)
    logger.info "Slots available: #{result}"
    result
  end

  def logout
    logger.info 'Logging out'
    click_on 'Sign out'
  rescue
    require 'pry'; binding.pry
  end

  private

  attr_reader :username, :password
end

if $PROGRAM_NAME == __FILE__
  checker = SlotChecker.new(
    username: ENV['TROSE_USER'],
    password: ENV['TROSE_PASSWORD']
  )
  checker.accept_cookies
  checker.login

  begin
    checker.slots_available?
  rescue Capybara::ElementNotFound => e
    logger.error e
  ensure
    checker.logout
  end
end
