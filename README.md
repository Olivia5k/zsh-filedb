# zsh-filedb!
## Quickfast access to configuration files and logs \o/


# DESCRIPTION

zsh-filedb is a small set of utilities designed to give the user speedier
access to configuration files and logs.

### Configs
Instead of wondering whether the main apache config file is
/etc/apache2/apache2.conf or /etc/httpd/httpd.conf or
/etc/apache/conf.d/apache.conf you can just type **c apache** and filedb will
find the right one for you. Of course, you can just type **c ap<tab>** since
zsh will complete it for you (unless you don't have apache installed, in which
case you won't be bothered with it).
Oh, and you don't need to prefix anything with sudo, the script will do that
for you should you not have the necessary permissions.

The script distinguishes two form of configurations:
 * Global configurations:
   System wide configuration files. Almost all of them found in /etc
 * Local configurations:
   User files, found somewhere in the depths of $HOME.

### Logs
The same thing, really, except there is currently only support for global logs
(the ones in /var/log/).


# USAGE

c \[CONFIG\] \[global|local\] -- Edit configuration files.
l \[LOG\] \[tail|page|edit\]
filedb \[add|commit\]


# INSTALLATION

1. Clone this repository
2. Put **source /path/to/filedb.zsh** somewhere in your .zshrc


# PLZ HELP!

A project such as this is never really useful unless others can contribute with
more files than the ones I have. To make this as easy as possible, some extra
tools have been added to the **filedb** command.

Think of the warm and fuzzy feeling you'll get when you've contributed! :heart:


# AUTHOR

[Lowe Thiderman][1]
lowe.thiderman@gmail.com

# CONTRIBUTORS

[Erik Honn][0] - Inspiring me to start this project


# COPYRIGHT

Copyright 2012 the **zsh-filedb** AUTHOR and CONTRIBUTORS as listed above.

[0]: https://github.com/Honn
[1]: https://github.com/daethorian
