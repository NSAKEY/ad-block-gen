#!/bin/sh
###############################################################################
#                                                                             #
# ad-block-gen                                                                #
# by _NSAKEY                                                                  #
#                                                                             #
# This project exists because I wanted a means of ad-blocking on Android that #
# didn't require me to root my new phone, thus voiding its warranty.          #
# This project is was designed to grab a lot of the popular hosts files from  #
# the Intenet, combine them into one big hosts file, and then convert the     #
# hosts file into a configuration file that Unbound understands. If you want  #
# to go with hosts-based or DNS-based ad blocking, this script covers both.   #
# Of course, you should still look into some sort of in-browser ad-blocking,  #
# just for the sake of having defense in depth.                               #
# I was inspired by the following GitHub projects:                            #
#                                                                             #
# - https://github.com/jodrell/unbound-block-hosts                            #
# - https://github.com/StevenBlack/hosts                                      #
# - https://github.com/nomadturk/vpn-adblock                                  #
#                                                                             #
# KNOWN ISSUES:                                                               #
# 1. ad_servers.txt downloads a fresh copy every time the script runs.        #
#                                                                             #
###############################################################################


# We'll use the -O flag to dump these files into text files whose name somewhat
# reflects where we'll get them.
# yoyo.txt's URL has to be wrapped in quotes because it's special.

printf "Checking for list updates...\n"
wget -q -N -P lists/someonewhocares http://someonewhocares.org/hosts/hosts
wget -q -N -P lists/adaway https://adaway.org/hosts.txt
wget -q -N -P lists/winhelp2002 http://winhelp2002.mvps.org/hosts.txt
wget -q -N -P lists/hosts-file http://hosts-file.net/ad_servers.txt
wget -q -N -P lists/yoyo "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
wget -q -N -P lists/malwaredomainlist http://www.malwaredomainlist.com/hostslist/hosts.txt
printf "Cleaning up and combining the lists...\n"

# winhelp2002 has 0.0.0.0 as the IP for each entry, instead of 127.0.0.1.
# 0.0.0.0 is faster, so we're going to convert all the other files to use it.
# GNU sed is the only sed version which supports in-place editing, so that's
# been avoided here for portability reasons.

printf "Generating a hosts file...\n"
sed 's/127.0.0.1/0.0.0.0/g' lists/someonewhocares/hosts lists/adaway/hosts.txt lists/hosts-file/ad_servers.txt lists/malwaredomainlist/hosts.txt lists/winhelp2002/hosts.txt lists/yoyo/serverlist.php\?hostformat\=hosts\&showintro\=0\&mimetype\=plaintext > tmp/hosts.1

# These next lines just remove the localhost-specific lines. They're completely
# harmless, but there's no real sense in keeping them around, so out they go.
# yoyo.txt doesn't have any localhost entries to remove, because again,
# it's special.

sed /localhost/d tmp/hosts.1 > tmp/hosts.2
sed /broadcasthost/d tmp/hosts.2 > tmp/hosts.3
#sed /\tlocal/d tmp/hosts3 > tmp/hosts.4 # The \t is a tab.

# This next one-liner pipes all the collected hosts files into a grep process,
# which collects all the lines which begin with "0.0.0.0" That output is then
# piped into a succession of seds, which convert double spaces into spaces,
# and remove any trailing comments. That output is piped into sort -u, which
# de-duplicates everything we have thus far. Finally, the end result is
# dumped into a# text file. This could have been broken up across multiple
# lines, but I really didn't feel like dealing with temp file clean-up.
# Also, queue the Useless Uses Of Cat bug reports.

#cat lists/someonewhocares/hosts lists/adaway/hosts.txt lists/hosts-file/ad_servers.txt lists/malwaredomainlist/hosts.txt lists/yoyo/serverlist.php\?hostformat\=hosts\&showintro\=0\&mimetype\=plaintext lists/winhelp2002/hosts.txt | grep ^0.0.0.0 | sed 's/  / /g' | sed 's/#[^#]*$//' | sort -u > hosts
cat tmp/hosts.3 | grep ^0.0.0.0 | sed 's/  / /g' | sed 's/#[^#]*$//' | sort -u > hosts

# The next section takes the hosts file we just made and adds <local-data>
# tags, then converts 0.0.0.0 to 127.0.0.1 so that we can
# throw the resulting hosts.txt file at unbound-block-hosts.

printf "Generating Unbound blocklist...\n"
awk '{print $2,$1}' hosts > tmp/block.conf.1
sed 's/^/local-data: \"/g' tmp/block.conf.1 > tmp/block.conf.2
sed 's/0.0.0.0/A 0.0.0.0"/g' tmp/block.conf.2 > tmp/block.conf.3
#sed 's/$/"/g' tmp/block.conf.3 > tmp/block.conf.4
tr -d "\015" < tmp/block.conf.3 | sort -u > block.conf # Strip ^M characters. Source: http://www.theunixschool.com/2011/03/different-ways-to-delete-m-character-in.html
rm tmp/* # Clean-up.

printf "That's it!\n"
printf "If you want to do hosts-based blocking, you need to run something like the following:\n"
printf "\tcat /etc/hosts hosts > hosts.combined ; cp hosts.combined /etc/hosts\n"
printf "It should take effect immediately.\n"
printf "If your plan is to do DNS-based blocking, you have to copy block.conf to Unbound's configuration folder and add something like this to unbound.conf:\n"
printf "\tinclude: /etc/unbound/block.conf\n"
printf "Once you're done with that, restart Unbound.\n"

# That's it. You're now ready to dump the new hosts file on a web server where
# unbound-block-hosts can grab and transform it into a configuration file that
# Unbound can understand. Or, you can append to a hosts file.
#     Zzzzz  |\      _,,,--,,_        +-----------------------------+
#           /,`.-'`'   ._  \-;;,_     |   Just a little something   |
#          |,4-  ) )_   .;.(  `'-'    |   to upset the UUOC crowd   |
#         '---''(_/._)-'(_\_)         +-----------------------------+
# Happy ad-blocking!
