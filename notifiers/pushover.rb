require 'rushover'

class PushoverNotifier
  def initialize
    @client = Rushover::Client.new(
      ENV.fetch('PUSHOVER_APP_TOKEN')
    )
  end

  def notify_slots_available(name)
    client.notify(
      user_key,
      "Delivery slot available: #{name}!",
      priority: 1,
      title: 'Waitrose slot checker'
    )
  end

  private

  def user_key
    ENV.fetch('PUSHOVER_USER_KEY')
  end

  attr_reader :client
end
