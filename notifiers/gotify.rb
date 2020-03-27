require 'httparty'
require 'dotenv/load'

class GotifyNotifier
  include HTTParty
  base_uri ENV.fetch('GOTIFY_URL')
  headers 'X-Gotify-Key' => ENV.fetch('GOTIFY_APP_TOKEN')

  def notify_slots_available
    message(
      title: 'Waitrose slot checker',
      message: 'There are new slots available!',
      priority: 5
    )
  end

  private

  def message(title:, message:, priority: 3)
    self.class.post('/message',
      query: {
        title: title,
        message: message,
        priority: priority
      })
  end
end
