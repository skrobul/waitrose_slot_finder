#!/usr/bin/env ruby
$stdout.sync = true
require_relative 'checker'
require_relative 'notifier'

@checker = SlotChecker.new(
  username: ENV['TROSE_USER'],
  password: ENV['TROSE_PASSWORD']
).accept_cookies

@logger = Logger.new($stdout)

def single_check
  begin
    @checker.login
    slots_available = @checker.slots_available?
    @checker.logout
  rescue Capybara::ElementNotFound => e
    @logger.error e
  end


  return unless slots_available

  Notifier.new.message(
    title: 'Waitrose slot checker',
    message: 'Chyba są nowe sloty!',
    priority: 5
  )
end

def sleep_time
  @sleep_time ||= Integer(ENV.fetch('CHECK_EVERY_MINUTES', '60')) * 60
end

def check_loop
  loop do
    begin
      single_check
    rescue StandardError => e
      @logger.error e
    end
    @logger.info "Sleeping for #{sleep_time / 60} minutes"
    sleep sleep_time
  end
end


check_loop if $PROGRAM_NAME == __FILE__
