#!/bin/sh
# i found from user Alrescha on macrumors forums here: and modified for high sierra and ease of use
# Check for a backup today, if none then mount the Time Machine volume
# and wait for Time Machine to run.  When the backup is over, unmount
# the Time Machine volume and exit.

# Set these variables or else
# for TMVOLUME ls -l /Volumes/ and paste the entire path including spaces in the quotes replace 'backup drive' below, TMFREQ is how recently you care to look
for a backup

TMVOLUME="backup drive"
TMFREQ="12h"

TMUUID=$(diskutil info "$TMVOLUME" | grep 'Volume UUID' | cut -f 2 -d ':'| awk '{$1=$1};1')

log show --style syslog  --predicate 'senderImagePath contains[cd] "TimeMachine" AND eventMessage contains[cd] "Backup completed successfully"' --info --last $TMFREQ| grep -v 'Filtering\|Timestamp'
if [ $? = 0 ]
        then
                sleep 300
                /usr/sbin/diskutil unmount "$TMUUID"
                test -d /Volumes/"$TMVOLUME"
                 exit 0
fi

# No backup yet today.  See if the Time Machine volume is mounted
# and if it isn't, mount it.
test -d /Volumes/"$TMVOLUME"
if [ $? = 1 ]
        then
                /usr/sbin/diskutil mount "$TMUUID"
fi

# Wait a while for Time Machine to wake up and do a backup
sleep 300
log show --style syslog  --predicate 'senderImagePath contains[cd] "TimeMachine" AND eventMessage contains[cd] "Backup completed successfully"' --info --last $TMFREQ| grep -v 'Filtering\|Timestamp'
while [ $? = 1 ]
        do
                sleep 300
        log show --style syslog  --predicate 'senderImagePath contains[cd] "TimeMachine" AND eventMessage contains[cd] "Backup completed successfully"' --info --last $TMFREQ| grep -v 'Filtering\|Timestamp'
done

# Backup completed, unmount the Time Machine volume and exit
/usr/sbin/diskutil unmount "$TMUUID"

# Make really sure it unmounted?
sleep 300
test -d /Volumes/"$TMVOLUME"
while [ $? = 0 ]
        do
                sleep 300
                /usr/sbin/diskutil unmount "$TMUUID"
                test -d /Volumes/"$TMVOLUME"
done

exit
