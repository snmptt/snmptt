# SNMPTT

SNMPTT (SNMP Trap Translator) is an SNMP trap handler written in Perl for use with the Net-SNMP [snmptrapd](http://www.net-snmp.org/man/snmptrapd.html) program ([www.net-snmp.org](http://www.net-snmp.org)). SNMPTT supports Linux, Unix and Windows.

Many network devices including but not limited to network switches, routers, remote access servers, UPSs, printers and operating systems such as Unix and Windows have the ability to send notifications to an SNMP manager running on a network management station. The notifications can be either SNMP Traps, or SNMP Inform messages.

The notifications can contain a wide array of information such as port failures, link failures, access violations, power outages, paper jams, hard drive failures etc. The MIB (Management Information Base) available from the vendor determines the notifications supported by each device.

The MIB file contains TRAP-TYPE (SMIv1) or NOTIFICATION-TYPE (SMIv2) definitions, which define the variables that are passed to the management station when a particular event occurs.

The Net-SNMP program **snmptrapd** is an application that receives and logs SNMP trap and inform messages via TCP/IP. Following is a sample syslog entry for a Compaq cpqDa3LogDrvStatusChange trap that notifies that the drive array is rebuilding using numeric OIDs:

    Feb 12 13:37:10 server11 snmptrapd[25409]: 192.168.110.192: Enterprise Specific Trap (3008) Uptime: 306 days, 23:13:24.29, .1.3.6.1.2.1.1.5.0 = SERVER08, .1.3.6.1.4.1.232.11.2.11.1.0 = 0, .1.3.6.1.4.1.232.3.2.3.1.1.4.8.1 = rebuilding(7)

Here is the same trap using symbolic OIDs.

    Feb 12 13:37:10 server11 snmptrapd[25409]: 192.168.110.192: Enterprise Specific Trap (3008) Uptime: 306 days, 23:13:24.29, sysName.0 = SERVER08, cpqHoTrapFlags.0 = 0, cpqDaLogDrvStatus.8.1 = rebuilding(7)


The output from snmptrapd can be changed via the -O option to display numeric or symbolic OIDs and other display options, but it generally follows the format of variable name = value, variable name = value etc.

A more descriptive / friendly trap message can be created using SNMPTT's variable substitution. Following is the same trap, logged with SNMPTT:

```
Feb 12 13:37:13 server11 TRAPD: .1.3.6.1.4.1.232.0.3008 Normal "LOGONLY" server08 - Logical Drive Status Change: Status is now rebuilding
```

The definition for the cpqDa3LogDrvStatusChange trap in the SNMPTT configuration file would be defined as follows:

```
FORMAT Logical Drive Status Change: Status is now $3.
```

The $3 represents the third variable as defined in the MIB file, which for this particular trap, is the cpqDaLogDrvStatus variable.

Another example of an SNMPTT configuration entry is:

```
FORMAT Compaq Drive Array Spare Drive on controller $4, bus $5, bay $6 status is $3.
```

Which could result in the following output:

```
"Compaq Drive Array Spare Drive on controller 3, bus 0, bay 3 status is Failed."
```

SNMPTT can log to any of the following destinations: text log, syslog, Windows Event log or a SQL database such as MySQL, PostreSQL or an ODBC accessible database such as Microsoft SQL. External programs can also be run to pass th  e translated trap to an email client, paging software, Nagios, Icinga etc.

In addition to variable substitution, SNMPTT allows complex configurations allowing:

*   the ability to accept or reject a trap based on the host name, ip address, network range, or variable values inside of the trap enterprise variables
*   execute external programs to send pages, emails etc
*   perform regular expression search and replace on the translated message such as translating the variable value "Building alarm 4" to "Moisture detection alarm"

See snmptt/docs/snmptt.MD for more information.
