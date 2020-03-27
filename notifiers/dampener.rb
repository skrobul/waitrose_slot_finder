class Dampener
  attr_reader :notifier
  def initialize(notifier, period_seconds = nil)
    @notifier = notifier
    @period_seconds = period_seconds ||
                      Integer(ENV.fetch('NOTIFY_PERIOD_HOURS', '8')) * 3600
    @last = Time.now - @period_seconds
  end

  def method_missing(method, *args)
    now = Time.now
    return unless now > (@last + @period_seconds)

    @last = now

    notifier.public_send(method, *args)
  end

  def respond_to_missing?(method, *)
    notifier.respond_to?(method)
  end
end
