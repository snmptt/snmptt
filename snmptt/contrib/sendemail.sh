#!/bin/sh
#
# Author:         Jon Nistor (nistor@snickers.org)
# Date:           September 9th, 2003
# Purpose:        This script is meant to integrate with snmptt as a method to
#                 send emails via the EXEC statement for received traps
# Usage:          sendemail.sh priority contact@email subjectLine textArea
# Requirements:   sendmail
# SNMPTT example: EXEC sendemail.sh high admin@company.com "SNMPTT Alert"
#                  "FORMAT NIC switchover to slot $3 from slot $5" 

FROM="SNMP contact <snmp@domain.com>"
PRINTF=/usr/bin/printf

if [ ! "$4" ]; then
	echo "Insufficient number of arguments"
	echo "usage: $0 priority contact@email subjectLine textArea"
	echo "  priority: 1=low, 2=med, 3=high"
	echo "  you can use \"\"'s around words to make it a section eg: \"text here\""
	exit 1
fi

PRIORITY="$1"
TO="$2"
SUBJECT="$3"
TEXT="$4"
#echo "VARS: P: $1  To: $2  Sub: $3  Text: $4"

send_email() {
	$PRINTF "From: $FROM\nTo: $TO\nSubject: $SUBJECT\nImportance: $1\nX-Priority: $PRIORITY\n\n$TEXT\n.\n" | sendmail $TO
}

# Now to send page
if [ "x$PRIORITY" = "x3" ]; then
	send_email High
elif [ "x$PRIORITY" = "x2" ]; then
	send_email Medium
else
	send_email Low
fi

# EOF
#
