#!/bin/bash

## my own rsync-based snapshot-style backup procedure
## (cc) marcio rps AT gmail.com

## Modified by Laurent Modolo to work on ssh

# config vars

SRC="/home/laurent/" #dont forget trailing slash!
SNAP="/backup/geno_pop/modolo/home"
OPTS="-e ssh -rlti --delay-updates --delete --chmod=a-w"
MINCHANGES=20

# run this process with real low priority

ionice -c 3 -p $$
renice +12  -p $$

# sync

rsync $OPTS $SRC sav:$SNAP/latest >> $SRC"rsync.log" # sav contain all the necessary information (.ssh/config) for the ssh connection

# check if enough has changed and if so
# make a hardlinked copy named as the date

COUNT=$( wc -l $SRC"rsync.log"|cut -d" " -f1 )
if [ $COUNT -gt $MINCHANGES ] ; then
	DATETAG=$(date +%Y-%m-%d)
	if [ ! -e $SNAP/$DATETAG ] ; then
		scp $SRC"rsync.log" sav:$SNAP/
		ssh sav 'bash -c "cp -lRf '$SNAP'/latest '$SNAP'/'$DATETAG'"'
		ssh sav 'bash -c "mv '$SNAP'/rsync.log '$SNAP'/'$DATETAG'/rsync.log"'
	fi
fi
