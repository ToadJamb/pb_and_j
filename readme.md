[![Build Status](https://travis-ci.org/ToadJamb/pb_and_j.svg?branch=master)](https://travis-ci.org/ToadJamb/pb_and_j)

PBAndJ
======

Want a progress bar that's going to stay put and yet leave you satisfied?

Look no further.
With no artificial flavors (dependencies),
entirely organic ingredients
(ServingSeconds actually came out of original code for PBAndJ),
and no GMOs (all Ruby objects are left unharmed),
PBAndJ is a progress bar you can feel good about giving to your kids.
And your Ruby projects.


Install
=======

	$ gem install pb_and_j


Gemfile
=======

	$ gem 'pb_and_j'


Require
=======

	$ require 'pb_and_j'


Examples
========

Basic usage would go something like this:

NOTE: `tick` will call `start` if it has not already been invoked.

```
count = things.count # Assume an array of Thing objects

bar = PBAndJ::ProgressBar.new('things', count) # description and total count
bar.start                                      # set the start time and print initial status

things.each do |thing|
  # do something with things
  bar.tick # automatically increase the counter and displays the updated progress bar
end

bar.stop # prints the current status and then a line feed
```

In the case that you do not wish to update for every iteration,
`tick` also accepts the current index as a parameter:

```
count = things.count # Assume an array of Thing objects

bar = PBAndJ::ProgressBar.new('things', count) # description and total count
bar.start                                      # set the start time and print initial status

things.each_with_index do |thing, i|
  # do something with things
  bar.tick i + 1 if i % 100 == 0 # only update the progress bar every 100th iteration
end

bar.stop # prints the current status and then a line feed
```

And for the really crazy stuff,
`tick` also accepts the time that you expect it to complete
and uses that for the expected completion time,
as well as the expected elapsed time:

```
count = things.count # Assume an array of Thing objects

bar = PBAndJ::ProgressBar.new('things', count) # description and total count
bar.start                                      # set the start time and print initial status

things.each_with_index do |thing, i|
  # do something with things
  time = my_crazy_non_linear_completion_time_calculation
  bar.tick i + 1, time # tell PBAndJ when the process is expected to complete.
end

bar.stop # prints the current status and then a line feed
```


Initialization
==============

The full parameters for initialization are:

		PBAndJ::ProgressBar.new label, count, pad: 0, width: 80, show: true, stream: STDOUT

* `label` (required)
	* the description to use for the progress bar
* `count` (required)
	* the total number of expected iterations
* `pad`
	* padding to use around the label
	* with a label of 'foo' and padding of 5, the label would be rendered as 'foo  '
* `width`
	* the total width that the progress bar should use
* `show`
	* whether the progress bar should be automatically printed in the console.
* `stream`
	* this is unlikely to be used outside of testing, but if it's useful, go for it.


More Complex Usage
==================

Multiple progress bars may be managed by using ANSI codes:

```
is = 3
js = 50

ibar = PBAndJ::ProgressBar.new('i', is)

ibar.start
ibar.stop

is.times do |i|
  jbar = PBAndJ::ProgressBar.new('j', js)
  jbar.start
  js.times do |j|
    jbar.tick
    sleep 0.1
  end
  jbar.stop # outputs a line break

  print "\e[A" * 2 # move up 2 lines

  ibar.tick
  ibar.stop
  sleep 1
end
```

If you want to use the output in some other way,
set `show` to false and simply use `#message`:

```
count = things.count # Assume an array of Thing objects

bar = PBAndJ::ProgressBar.new('things', count, show: false)

things.each_with_index do |thing, i|
  # do something with things
  bar.tick # does not print anything out
  print "\r" + bar.message # this is essentially what PBAndJ does when show is true
end

bar.stop # only necessary if you wish to see a message after everything is complete
```
