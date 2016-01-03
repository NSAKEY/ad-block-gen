ad-block-gen
===================

ad-block-gen is a project for shutting down advertisers and other miscreants. It works by downloading popular hosts files for blocking advertisers, malware domains, etc. and combines/de-duplicates them. Not only that, but the resulting hosts file is also converted into a block list which can be used with Unbound. In other words: If you want to do hosts file-based blocking or DNS blocking, this project has you covered.

The idea of this script originally came about when I bought a new phone, and didn't want to root it (And lose things like OTA updates) just to have decent ad-blocking. Instead, I opted to push the job of blocking hosts out to a DNS server, and that approach has worked reasonably well. Though the YouTube app still lets ads through, I can visit m.youtube.com with Chrome and never see advertising.

We live in a world where:

1. Ad networks are commonly used to spread malware.
2. Net neutrality doesn't exist on mobile networks, meaning that your mobile data plan is eaten up more quickly if you allow advertising to be seen while you browse. Even the Interactive Advertising Bureau has admitting that it messed up by shoveling overly bloated advertising on everyone with wild abandon.
3. Online advertising has increasingly become a "Little Brother" surveillance platform since the dot-com bubble popped in 2000.

Blocking all advertising is the only sane option if you care about any of the above.

This script has been tested on the following platforms:

- Debian Jessie
- FreeBSD 10.x
- OpenBSD 5.7
- Solaris 11.2

Combine with extensions like Privacy Badger and uBlock Origin for defense in depth. Proper documentation can be found in the comments of the script.
