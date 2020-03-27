#!/usr/bin/env ruby
require_relative 'checker'
require_relative 'notifier'

checker = SlotChecker.new(
  username: ENV['TROSE_USER'],
  password: ENV['TROSE_PASSWORD']
).login

begin
  slots_available = checker.slots_available?
rescue Capybara::ElementNotFound => e
  logger.error e
ensure
  checker.logout
end

if slots_available
  Notifier.new.message(
    title: 'Waitrose slot checker',
    message: 'Chyba są nowe sloty!',
    priority: 5
  )
end
