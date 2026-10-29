.PHONY: help checksyslink checklinks

help:
	@echo Helpful targets
	@echo
	@echo checklinks - checks for broken links inside all config subdirs
	@echo checksyslinks - checks the root filesystem for symlinks into our config dir
	@echo help - prints this help message


checksyslinks:
	find / -xdev -path /opt/awesome-powers -prune -o -type l -printf "%p -> " -exec readlink -m {} \; |grep "/opt/awesome-powers" 

checklinks:
	find -L . -type l -printf "%p -> " -exec readlink -m {} \;


# FIXME: need targets for installing based on site/hostname, or some script to do it.
