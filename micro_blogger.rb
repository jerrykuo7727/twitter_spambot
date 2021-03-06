require 'jumpstart_auth'
require 'bitly'

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

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      print "Enter command ('help' to list all commands): "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1], parts[2..-1].join(" "))
        when 'spam' then spam_my_followers(parts[1..-1].join(" "))
        when 'elt' then everyones_last_tweet
        when 's' then shorten(parts[1..-1].join(" "))
        when 'turl' then tweet(parts[1..-2].join(" ") << " " << shorten(parts[-1]))
        when 'help' then help
        else
          puts "Sorry, '#{command}' is not a valid command."
      end
    end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    if screen_names.include?(target)
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "Error: You can only DM people who follow you"
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each { |follower| screen_names << @client.user(follower).screen_name }
    screen_names
  end

  def spam_my_followers(message)
    followers_list.each { |follower| dm(follower, message) }
  end

  def everyones_last_tweet
    friends = @client.friends
    friends = friends.sort_by do |id|
      @client.user(id).name.downcase
    end
    puts ""
    friends.each do |id|
      friend = @client.user(id)
      friend_name = friend.name
      last_message = friend.status.text
      timestamp = friend.status.created_at
      puts "#{friend_name} said this on #{timestamp.strftime("%A, %b %d")}..."
      puts "#{last_message}"
      puts ""
    end
  end

  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    short_url = bitly.shorten(original_url).short_url
    puts "Done! Short URL: #{short_url}"
    short_url
  end

  def help
    puts ""
    puts "'q': quit the twitter client"
    puts "'t': post a tweet (format: t <text>)"
    puts "'dm': send a direct message (format: dm <name> <message>)"
    puts "'spam': send a direct message to all followers (format: spam <message>)"
    puts "'elt': show all last tweets of who you are following"
    puts "'s': shorten a URL (format: s <URL>)"
    puts "'turl': post a tweet ending with a URL shorten (format: turl <text> <URL>)"
    puts ""
  end
end

blogger = MicroBlogger.new
blogger.run