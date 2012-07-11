Big idea
--------
Walking the twitter follower/following of a given user. Fetching them, and storing them locally. Being able to spit a relation graph in a format edible for Gephi

Details
-------

* Collecting
level = 0 (max_level default is 1 - just fetching user and its follow[er/ing] list - overriden at will)
Being given a user name, fetching all followers and followings.
Store them all (two tables : one with users details, one with relationship - graph is directed, so user_id, user_id, direction (followed / folowwing))
level = level +1
if level < max_level, redo from start for EACH - be warned, I said EACH - user in the follow[er/ing] list. What a big mess.

* Spiting
I think the GDF format ( http://gephi.org/users/supported-graph-formats/gdf-format/ ) is a good try.
So , spit the user table in a file, then the edge table.

* News.
Twitter limit of 150 request per hour. Gasp. So, putting a third table, storing users still to be queried, withdrawed when data are fecthed (make a kind of queue). Running as daemon? 
Doing my 150 request, sleeping, waking, doing my request etc.
