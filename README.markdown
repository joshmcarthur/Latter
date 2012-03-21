Latter!
====

[![Build Status](https://secure.travis-ci.org/joshmcarthur/Latter.png)](http://travis-ci.org/joshmcarthur/Latter)


Latter is a simple ladder application built for the staff of [3Months](http://www.3months.com) by [Josh McArthur](http://twitter.com/sudojosh). It's hacked together pretty badly, but does have the dubious honour of being the first of my projects to be properly covered by tests.

Installation:
---

* Get the code: `git clone https://github.com/joshmcarthur/Latter.git`
* Install dependencies: `bundle install`
* Create the SQLite database: `sqlite3 db/latter.db.sqlite3`
* Run the application: `rackup`

Tests:
---

Tests are a mixture of Rack::Test and Capybara/Selenium. Selenium requires Firefox be installed and accessible somewhere on your path, everything else should be fine.

You can run the tests by executing `bundle exec rake spec` from within the project directory.

License:
---


MIT License
