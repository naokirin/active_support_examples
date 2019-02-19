require 'active_support'
require 'active_support/subscriber'

# Example for ActiveSupport::Subscriber
class Subscriber < ActiveSupport::Subscriber
  def perform(event)
    puts "name: #{event.payload[:name]}, duration: #{event.duration.round(2)}ms"
  end
end
Subscriber.attach_to :foo

ActiveSupport::Notifications.instrument('perform.foo', name: 'Bob') do
  sleep(0.2)
end

# Doesn't call subscriber because doesn't attach_to :bar
ActiveSupport::Notifications.instrument('perform.bar', name: 'Alice') do
  sleep(0.1)
end


# Example for Notifications.subscribe
ActiveSupport::Notifications.subscribe('sample') do |_name, start, finish, _id, payload|
  puts "name: #{payload[:name]}, \
duration: #{((finish - start) * 1000).round(2)}ms"
end

ActiveSupport::Notifications.instrument('sample', name: 'John') do
  sleep(0.1)
end

