require "twitter"
require "mongo"
require 'yaml'
require 'socket'
require 'logger'

class User
   attr_accessor :id, :screen_name, :followers, :following
   def initialize(id, screen_name, followers, following)
      @id = id
      @screen_name = screen_name
      @followers = followers
      @following = following
   end
end

class Worker
   attr_accessor :dbconfig, :worker_id, :db, :max
   def initialize
      @log = Logger.new(STDOUT)
      config = YAML.load_file('config.yaml')
      settings = config["application"]
      @max = settings["max"]                            #Max number of user fetched by worker, for testing (?) purposes
      @dbconfig = config["database"] 
      @worker_id = Socket.gethostname
      connection = Mongo::Connection.new(@dbconfig["host"])
      @db = connection.db(@dbconfig["db"])
      begin
         auth = @db.authenticate(@dbconfig["user"], @dbconfig["password"])
      rescue Mongo::AuthenticationError => authError
         @log.fatal "Error while authenticating : #{authError.message}"
         abort
      end   
      Twitter.configure do |config|
         config.consumer_key = settings["consumer_key"]
         config.consumer_secret = settings["consumer_secret"]
         config.oauth_token = settings["oauth_token"]
         config.oauth_token_secret = settings["oauth_token_secret"]
      end
   end
   def work() 
      userTBD = db.collection("userTBD")
      worklog = db.collection("worklog")
      userinfo = db.collection("user")
      next_user = userTBD.find_one                                   #finding next user to fetch 
      if userinfo.find("id" => next_user["id"]).count > 0    # User has already been looked up in twitter
         log = self.make_log(next_user["id"])
         log["action"] = "discarding (already fetched)"
         worklog.insert(log)
         @log.info("discarding user #{next_user["id"]}")
      else
         log = self.make_log(next_user["id"])
         log["action"] = "fetching"
         worklog.insert(log)                                            #Inserting log action 
         userTBD.remove("_id" => next_user["_id"])                      #removing user from the queue
         begin
            @log.info("fetching user #{next_user['id']}")           
            user = self.fetch_user(next_user["id"])
            userinfo.insert(user)                                       # fetching user and storing result 
            @log.info("Inserting followers in the TBD queue...") 
            user["followers"].each { |id|
               if userTBD.find("id" => id).count == 0
                  userTBD.insert({ "id" => id})
               end
            }
            @log.info("Inserting friends in the TBD queue...")
            user["friends"].each { |id|
               if userTBD.find("id" => id).count == 0
                  userTBD.insert({"id" => id})
               end
            }
         rescue Twitter::Error => error                                 #Something went wrong, we put back user in queue and go to sleep until we can act again
                                                                        #Time to sleep depends of the error raised 
                                                         
            delay = 10                                                  # By default, wait for 10 seconds
            if Twitter.remaining_hits == 0                              # Did we hit the hourly limit?
               delay = Twitter.reset_time_in_seconds
               logger.error("We did hit the twitter API limit")
            end
            logger.error("Going to sleep for #{delay} seconds, because of #{error.message}")
            log = self.make_log(next_user["id"])
            log["action"] = "Going to sleep for #{delay}"
            worklog.insert(log)
            userTBD.insert({"id" => next_user["id"]})           #Putting back the user in queue...

            return {"status" => :error, "delay" => delay}
         end
      end
      return {"status" => :ok}
   end

   def make_log(userid)
      return { "worker" => @worker_id,
               "timestamp" => Time.new,
               "id" => userid}
   end

   def fetch_user(userid)
      user = {}
      userTwitter = Twitter.user(userid)
      @log.info("Fetching #{userTwitter.followers_count} followers of user #{userTwitter.screen_name} - id #{userid}")
      followersTwitter = Twitter.follower_ids(userid)
      @log.info("Fetching #{userTwitter.friends_count} friends of user #{userTwitter.screen_name} - id #{userid}")
      friendsTwitter = Twitter.friend_ids(userid)
      user["id"] = userTwitter.id
      user["name"] = userTwitter.screen_name
      user["followers_count"] = userTwitter.followers_count
      user["friends_count"] = userTwitter.friends_count
      user["followers"] = followersTwitter.ids
      user["friends"] = friendsTwitter.ids
      return user
   end

   def run
      iter = 0
      while iter < max
         result = self.work
         iter = iter + 1
         if result['status'] == :error
            sleep(result['delay'])
         end
      end
   end
end
