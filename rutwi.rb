require "twitter"
require "sequel"

class User
   attr_accessor :id, :screen_name, :followers, :following
   def initialize(id, screen_name, followers, following)
      @id = id
      @screen_name = screen_name
      @followers = followers
      @following = following
   end
end

class Walker
   def walk(source, depth)
      puts "Fetching data for first user #{source}"
      user = User.new(Twitter.user(source).id,source, [],[])
      puts "Now recursing, depth = #{depth}"
      self.recurse(user, depth) 
      return user
   end

   def recurse(user, depth)
      if depth == 0
         puts "Depth reached, now returning"
         return
      end
      puts "Now recursing user #{user.screen_name}, depth = #{depth}"
      puts "Fetching friends..."
      friends = Twitter.friend_ids(user.screen_name)
      puts "Fetching followers..."
      followers = Twitter.follower_ids(user.screen_name)
      puts "Populating friends..."
      friends = friends.ids.collect do |id| 
         User.new(id, Twitter.user(id).screen_name, [],[])
      end
      user.friends = friends
      puts "Populating followers..."
      followers = followers.ids.collect do |id|
         User.new(id, Twitter.user(id).screen_name, [],[])
      end
      user.followers = followers
      friends.each do |friend|
         puts "Going down on friends of #{user.screen_name} , depth is #{depth - 1}"
         self.recurse(friend, depth - 1)
      end
#      followers.each do |follower|
#         puts "Going down on followers of #{user.screen_name} , depth is #{depth - 1}"
#         self.recurse(follower, depth - 1)
#      end
   end
end  
