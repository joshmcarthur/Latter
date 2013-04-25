Latter!
====

[![Build Status](https://secure.travis-ci.org/joshmcarthur/Latter.png)](http://travis-ci.org/#!/joshmcarthur/latter)

> Latter is a table-tennis ladder web application used at [3months](http://3months.com). It uses the [Elo](http://en.wikipedia.org/wiki/Elo_rating_system) rating system to keep track of players' ratings and is fast and easy to use.

### History

Latter started life as a Sinatra application - in fact, one of the first apps that I had built. Due to it's awful original design and lack of usability though, it fell into disuse.

Following a surge in table tennis playing at 3months, I took a look at what it was trying to do, and refactored the application design and UI to make it more usable. 

After a few months of use, and a great deal of extra features, bugfixes and change, I made the decision to switch to Rails, in order to more closely fit with technologies I was comfortable with, to make it easier for contributors to contribute, and because I felt that the Sinatra app would need more and more 'Rails-ness' added to it to continue to grow.

### The Application

Latter is a standard Rails application, based around ActiveRecord. It is 97% covered by specs (although the coverage can be off by a few percentage points), and is very tidily organized.

### Set up

The set up for the application is very simple, and standard for a Ruby on Rails application. The only point that you probably havent' done before is the set up for the websockets updates, using [sync](https://github.com/chrismccord/sync)

* Clone the repository
* Run bundle install
* Run rake db:setup
* Copy the database YAML file: `cp config/database.yml.example config/database.yml`
* Copy the Sync YAML file: `cp config/sync.yml.example config/sync.yml`
* Assuming you're using Faye (which you should in development): `cp Procfile.faye Procfile`
* Start the Rails server: `foreman start`


### Deployment

The application will run quite happily on Heroku - that's where it's deployed for 3months. It should also run just fine on any other standard Rails deploy targets. The main non-railsy dependencies is either [Faye](http://faye.jcoglan.com/) or [Pusher](http://pusher.com/) - see `config/sync.yml.example` for details of how to configure for each of these.

### Author

Latter was originally developed, and then refactored by [Josh McArthur](http://github.com/joshmcarthur). I continue to vet and suggest improvements on pull requests, and oversee future improvements to keep the application as usable as possible while packing the most cool features in.

### License

I'd like others to get use out of this application, so this application is licensed under the Poetic form of the MIT License.

© 2012, Josh McArthur

<pre>
This work ‘as-is’ we provide.
No warranty express or implied.
We’ve done our best,
to debug and test.
Liability for damages denied.

Permission is granted hereby,
to copy, share, and modify.
Use as is fit,
free or for profit.
These rights, on this notice, rely.
</pre>