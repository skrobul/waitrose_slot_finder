require 'httparty'
require 'dotenv/load'

class Notifier
  include HTTParty
  base_uri ENV.fetch('GOTIFY_URL')
  headers 'X-Gotify-Key' => ENV.fetch('GOTIFY_APP_TOKEN')


  def message(title: , message: , priority: 3)
    self.class.post('/message',
      query: {
        title: title,
        message: message,
        priority: priority
      })
  end
end
