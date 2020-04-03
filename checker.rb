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
Capybara.default_driver = Capybara.javascript_driver = :selenium_chrome

# Capybara.default_driver = Capybara.javascript_driver = :headless_chrome
class NoMoreSlots < Capybara::ElementNotFound; end
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
    result = has_no_css?('h1', text: /all slots are unavailable/i, wait: 3) &&
             has_no_css?('h1', text: /We're supporting the vulnerable and elderly/i, wait: 0) &&
             has_no_css?('h1', text: /slots are unavailable/i, wait: 0)
             logger.info "Slots may be available: #{result}"
    if result
      page.save_screenshot('/tmp/slots.png')
      parse_grid
    else
      false
    end
  end

  def parse_grid
    loop do
      # logger.debug "Parsing slot grid"
      if all_slots_taken?
        logger.info "No slots on #{slot_name}"
        next_grid
      else
        logger.info "SLOTS AVAILABLE on #{slot_name}"
        return true
      end
    end
  rescue NoMoreSlots, Capybara::ElementNotFound => err
    logger.error err.inspect
    logger.info "No more slot pages"
  end

  def slot_name
    find('div[data-test=bookslot-date-selection] > div.row').find_all('span')[1].text
  end

  def next_grid
    btn = find('button', text: 'Later')
    raise NoMoreSlots if btn['class'].include?('disabled')

    btn.click
  end

  def all_slots_taken?
    slot_grid = find('div[data-test=slot-grid]', wait: 5)
    slot_grid.find_all('button>span', text: 'Unavailable').size == 85
  end

  def logout
    logger.info 'Logging out'
    click_on 'Sign out'
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
    $stderr.puts e
  ensure
    checker.logout
  end
end
