#!/usr/bin/env ruby
$stdout.sync = true
require_relative 'checker'
require_relative 'notifiers/dampener'
require_relative 'notifiers/gotify'
require_relative 'notifiers/pushover'

@checker = SlotChecker.new(
  username: ENV['TROSE_USER'],
  password: ENV['TROSE_PASSWORD']
).accept_cookies

@logger = Logger.new($stdout)

def setup_notifier
  instance = case ENV['NOTIFIER']
         when 'pushover' then PushoverNotifier.new
         else GotifyNotifier.new
         end
  if ENV['NO_DAMPENING']
    instance
  else
    Dampener.new(instance)
  end
end

@notifier = setup_notifier

def single_check
  begin
    @checker.login
    available_slot_name = @checker.slots_available?
    @checker.logout
  rescue Capybara::ElementNotFound => e
    @logger.error e
  end

  return unless available_slot_name

  @logger.info "Sending notification for #{available_slot_name}."
  @notifier.notify_slots_available(available_slot_name)
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
