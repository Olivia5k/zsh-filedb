# zsh-filedb!
Quickfast access to configuration files and logs \o/

## Features

![An image says, um, like... a lot of words!](http://ompldr.org/vY2htcQ)

* Filename agnostic file database: Just saying *nginx* is enough! You don't need to care whether it is */etc/nginx/nginx.conf* or */etc/nginx/conf.d/nginx.conf*. The script will find out for you!
* Automatic sudo if insufficient permissions.
* Awareness of global and local configuration files (*/etc/my.cnf* vs *~/.my.cnf*).
* Blissful tab completion! The completion only lists configs actually present on your system.
* Easy contributing! See the **PLZ HELP!** section further down for great justice!

## Usage

c \[CONFIG\] \[global|local\] -- Edit configuration files.

l \[LOG\] \[tail|page|edit\]

filedb \[add|commit\]


## Installation

1. Clone this repository
2. Put **source /path/to/filedb.zsh** somewhere in your .zshrc


## PLZ HELP!

A project such as this is never really useful unless others can contribute with
more files than the ones I have. To make this as easy as possible, some extra
tools have been added to the **filedb** command.

Think of the warm and fuzzy feeling you'll get when you've contributed! :heart:


## Author

  Lowe Thiderman (lowe.thiderman@gmail.com)

## Contributors

[Erik Honn][0] - Inspiring me to start this project


## Copyright

Copyright 2012 the **zsh-filedb** AUTHOR and CONTRIBUTORS as listed above.

[0]: https://github.com/Honn

