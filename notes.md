Things to do
------------
* After a certain threshold, stop adding to the tbd collection?
* If user has followers/friends above a certain limit, don't include him (the star effect, ex elisa dushku with 1M + followers)
* Adding index on ID didn't really improves performances. What can I do? inserting ids in the TBD queue is long.
** Maybe by using bulk insert. Got a few hits on Google, should pass an array of docs to #insert. 
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

