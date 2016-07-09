require 'jumpstart_auth'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Messages can't be more than 140 characters!"
    end
  end
end

blogger = MicroBlogger.new
blogger.tweet("".ljust(140, "testing..."))