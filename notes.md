Things to do
------------
* After a certain threshold, stop adding to the tbd collection?
* If user has followers/friends above a certain limit, don't include him (the star effect, ex elisa dushku with 1M + followers)
* Adding index on ID didn't really improves performances. What can I do? inserting ids in the TBD queue is long.
Maybe by using bulk insert. Got a few hits on Google, should pass an array of docs to #insert. 
Ok, it is the way to go:

With bulk insert 

   I, [2012-07-23T00:18:08.715790 #2888]  INFO -- : fetching user 36171035
   I, [2012-07-23T00:18:09.534926 #2888]  INFO -- : Fetching 8864 followers of user BrianFargo - id 36171035
   I, [2012-07-23T00:18:10.798022 #2888]  INFO -- : Fetching 165 friends of user BrianFargo - id 36171035
   I, [2012-07-23T00:18:11.685569 #2888]  INFO -- : Inserting followers in the TBD queue...
   I, [2012-07-23T00:18:12.425168 #2888]  INFO -- : Inserting friends in the TBD queue...

Without bulk insert

   I, [2012-07-23T00:08:05.295379 #2888]  INFO -- : fetching user 104811017
   I, [2012-07-23T00:08:06.425039 #2888]  INFO -- : Fetching 1056 followers of user jeanpierredenis - id 104811017
   I, [2012-07-23T00:08:07.403641 #2888]  INFO -- : Fetching 133 friends of user jeanpierredenis - id 104811017
   I, [2012-07-23T00:08:08.330914 #2888]  INFO -- : Inserting followers in the TBD queue...
   I, [2012-07-23T00:08:37.797158 #2888]  INFO -- : Inserting friends in the TBD queue...

As performances is (yet) no longer an issue, I won't investigate the use of native extension for the mongo driver

* How to be certain that we do a breadth-first and not a depth first? Should I add a timestamp to the TBD collection and sort on it for getting the next user? or maybe add a user field, and exhaust all relating to the user? In this case I should need to indicate which user I'm working on so that other workers can help to to exhaust my queue.

* As the twitter limit is IP based for anonymous and Oauth-token based for authenticated access, I will do all my request as unautenticated, so I can use multiple workers on different servers in parallel. The 350 vs 150 request per hour in authenticated mode is not a factor as with 3 workers I can do 3*150 requests (450)

* We put back the user in the TBD queue if we have a problem during the request. What if the user was fetched, but her friends/followers didn't? Do we ensure that the user is not put in the user collection (which implies that the tbd user would be skipped next time,thus maybe leading to inconsistency regarding the friends / followers not retrieved in the user collection for this particular user)
In fact, as we insert the user as a whole (with the friends and followers), the atomicity of the operation garaantees that we won't have an half populated user in the user collection.

* Well, it seems the timestamping method doesnt work (I'm fetching korean users but should be only working with my own account...)
In fact it would work if I was'nt such an ass. I was using a descendign sort to get the oldest timestamp - it was giving me the most recent... Idiot.

* users which generates error during the retrieval of information should not be put bac in the queue (they will again raise an error, and we'll could eventually get stuc on them if they became the oldest entry in the TBD)

* Should I capp the numbre of user looked up, by specifying a maximal graph diameter from the starting user? Is it feasible?

Regarding the use of AWS
------------------------
The linux Amazon AMi comes with ruby 1.8.7 and needs a bit of install, got 1.9.3 running by following [this | http://www.johnvarghese.com/installing-ruby-1-9-3-on-a-linux-ami-on-amazon-aws/].
Maybe should I try a standard ubuntu , and install 1.9.3 with synaptic. WOuld it be faster (the install on amazon AMI takes about 30 minutes) ?
In fact, I created a new instance based on the one I customized. All is OK.

