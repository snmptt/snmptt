<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="utf-8" />
<meta name="generator" content=
"HTML Tidy for HTML5 for Linux version 5.6.0" />
<meta content="Alex Burger" name="Author" />
<meta content="Mozilla/4.78 [en] (Windows NT 5.0; U) [Netscape]"
name="GENERATOR" />
<link rel="StyleSheet" type="text/css" href="layout1.css" />
<title>SNMP Trap Translator</title>
</head>

# SNMP Trap Translator v1.5
**([SNMPTT](http://www.snmptt.org))**

This file was last updated on: August 17th, 2022

[License](#License)

[SNMPTT](#What-is-it)

* [What is it?](#What-is-it)
* [Downloading](#Downloading)  
* [Requirements](#Requirements)  
* [What's New](#Whats-New)  
* [Upgrading](#Upgrading)  
* [Installation](#Installation)  
    * [Overview](#Installation-Overview)  
    * [Unix](#Installation-Unix)  
        * [Package Manager](#Installation-Unix-Package)  
        * [Manual installation](#Installation-Unix-Manual)  
        * [Net-SNMP handlers](#Installation-Unix-Handlers)
            * [Net-SNMP Standard handler](#Installation-Unix-Standard)
            * [Net-SNMP Embedded handler](#Installation-Unix-Embedded)
        * [Testing](#Installation-Unix-Testing)
    * [Windows](#Installation-Windows)  
    * [Securing SNMPTT](#SecuringSNMPTT)  
* [Configuration Options - snmptt.ini](#Configuration-Options)  
* [Modes of Operation](#Modes-of-Operation)  
    * [Daemon Mode](#Modes-of-Operation-Daemon)
    * [Standalone Mode](#Modes-of-Operation-Standalone)
* [Command line arguments](#Command-line-arguments)  
* [Logging](#Logging)  
    * [Standard](#LoggingStandard)  
    * [Unknown Traps](#LoggingUnknown)  
    * [Syslog](#LoggingSyslog)  
    * [Windows EventLog](#LoggingEventLog)  
    * [Database](#LoggingDatabase)  
        * [MySQL](#LoggingDatabase-MySQL)  
        * [PostgreSQL](#LoggingDatabase-PostgreSQL)  
        * [ODBC](#LoggingDatabase-ODBC)  
        * [Windows ODBC](#LoggingDatabase-Windows_ODBC)  
* [Executing an external program](#Executing-an-external-program)  
* [SNMPTT.CONF Configuration file format](#SNMPTT.CONF-Configuration-file-format)  
    * [EVENT](#SNMPTT.CONF-EVENT)  
    * [FORMAT](#SNMPTT.CONF-FORMAT)  
        * [Variable-substitutions](#Variable-substitutions)  
    * [EXEC](#SNMPTT.CONF-EXEC)  
    * [PREEXEC](#SNMPTT.CONF-PREEXEC)  
    * [NODES](#SNMPTT.CONF-NODES)  
    * [MATCH](#SNMPTT.CONF-MATCH)  
    * [REGEX](#SNMPTT.CONF-REGEX)  
    * [SDESC](#SNMPTT.CONF-SDESC)  
    * [EDESC](#SNMPTT.CONF-EDESC)  
* [SNMPTT.CONF Configuration file Notes](#SNMPTT.CONF-Configuration-file-Notes)  
* [Name resolution / DNS](#DNS)  
* [Sample SNMPTT.CONF files](#Sample-SNMPTT.CONF-file)  
    * [Sample1 SNMPTT.CONF file](#Sample1-SNMPTT.CONF-file)  
    * [Sample2 SNMPTT.CONF file](#Sample2-SNMPTT.CONF-file)  
* [Notes](#Notes)  
    * [trapd.conf & MIB files](#Notes-trapd.conf)  
    * [IPv6](#Notes-ipv6)  
* [Limitations](#Limitations)  
* [Feedback & Bugs](#Feedback)  
* [Integration with other software](#Integration-with-other-software)  
    * [Nagios](#Nagios-Netsaint)  
    * [Icinga](#Icinga)  
    * [Zabbix](#Zabbix)
    * [Simple Event Correlator (SEC)](#SEC)  
    * [Windows Event Log forwarding](#EventWin)  
    * [Xymon / Hobbit](#Hobbit)


# <a name="License"></a>License

Copyright 2002-2022 Alex Burger  
alex\_b@users.sourceforge.net  
4/3/2002

This program is free software; you can redistribute it and/or modify  
it under the terms of the GNU General Public License as published by  
the Free Software Foundation; either version 2 of the License, or  
(at your option) any later version.

This program is distributed in the hope that it will be useful,  
but WITHOUT ANY WARRANTY; without even the implied warranty of  
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
GNU General Public License for more details.

You should have received a copy of the GNU General Public License  
along with this program; if not, write to the Free Software  
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA  
 


# <a name="What-is-it"></a>What is it?

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

As of SNMPTT 1.5, both IPv4 and IPv6 are supported.


# <a name="Downloading"></a>Downloading

SNMPTT can be downloaded from the [Sourceforge files page](https://sourceforge.net/projects/snmptt/files/snmptt/).  The primary git source code repository is avaialble at [Sourceforge](https://sourceforge.net/p/snmptt/git/ci/master/tree/) and a mirror is available at [GitHub](https://github.com/AlexB7/snmptt).

# <a name="Requirements"></a>Requirements

* Perl 5.6.1 or higher.  SNMPTT began development using 5.6.1 and although it is now developed with 5.30, it should still be backwards compatible 5.6.1.
* To use snmptthandler-embedded, Net-SNMP's snmptrapd must be compiled with embedded Perl enabled (**--enable-embedded-perl** configuration option)

## Perl Modules

<style type="text/css" rel="stylesheet">
table {
    /* Moved from layout1.css so that it doesn't conflict with snmptt.org web page */
	border-collapse: collapse;
	width: 70%;
  }

  td, th {
	border: 1px solid #aaaaaa;
	text-align: left;
	padding: 2px;
	max-width: 50em;
  }

  tr:nth-child(even) {
	background-color: #dddddd;
  }
</style>

| R/O | Program / Module | rpm | deb
| :--- | :--- | :--- | :--- |
| Required | [Net-SNMP](http://www.net-snmp.org) (formerly known as UCD-SNMP).  Specifically **snmptrapd.** | net-snmp, net-snmp-utils | snmp, snmptrapd |
| Optional | [Net-SNMP Perl module](http://www.net-snmp.org/FAQ.html#How_do_I_install_the_Perl_SNMP_modules_).  Only required for features that perform conversions between symbolic and numeric OIDs.  This is NOT the same as the Net::SNMP module availabe from CPAN. | net-snmp-perl | libsnmp-perl |
| Required | [Text::ParseWords](https://metacpan.org/pod/Text::ParseWords) module (included with most distributions) | perl-Text-ParseWords |  |
| Required | [Getopt::Long](https://metacpan.org/pod/Getopt::Long) module (included with most distributions) |  |  |
| Required | [Posix](http://search.cpan.org/search?module=POSIX) module (included with most if not all distributions) |  |  |
| Required | [Config::IniFiles](https://metacpan.org/pod/Config::IniFiles) module | perl-Config-IniFiles (EPEL, PowerTools repos)| libconfig-inifiles-perl |
| Required | [Time::HiRes](https://metacpan.org/pod/Time::HiRes) module (only required when using SNMPTT in daemon mode - required by **snmptthandler**) | perl-Time-HiRes | libtime-hires-perl |
| Required | [Sys::Hostname](https://metacpan.org/pod/Sys::Hostname) module (included with most if not all distributions). |  |  |
| Required | [File::Basename](https://metacpan.org/pod/File::Basename) module (included with most if not all distributions). |  |  |
| Required | [Text::Balanced](https://metacpan.org/pod/Text::Balanced) module (included with most if not all distributions). |perl-Text-Balanced|  |
| Optional | [Net::IP](https://metacpan.org/pod/Net::IP) module. Required for IPv6 support. | perl-Net-IP (EPEL repo)| libnet-ip-perl |
| Optional | [IO::Socket::IP](https://metacpan.org/pod/IO::Socket::IP) module (included with most if not all distributions). Required for DNS translations. |  |  |
| Optional | [Sys::Syslog](https://metacpan.org/pod/Sys::Syslog) module (included with most Unix distributions). Required for Syslog support using Unix sockets (local syslog). | perl-Sys-Syslog |  |
| Optional | [Log::Syslog::Fast](https://metacpan.org/pod/Log::Syslog::Fast) and [Log::Syslog::Constants](https://metacpan.org/pod/Log::Syslog::Constants) modules. Required for remote syslog and RFC5424 support. |  |  |
| Optional | [DBI](https://metacpan.org/pod/DBI) module.  Required for DBD::MySQL, DBD::PgPP and DBD::ODBC support. | perl-DBI | libclass-dbi-perl |
| Optional | [DBD::mysql](https://metacpan.org/pod/DBD::mysql) module.  Required for MySQL support. | perl-DBD-MySQL | libdbd-mysql-perl |
| Optional | [DBD::PgPP](https://metacpan.org/pod/DBD::PgPP) or [DBD:Pg](https://metacpan.org/pod/DBD::Pg) module.  Required for PostgreSQL support. | perl-DBD-Pg | libdbd-pg-perl |
| Optional | [DBD::ODBC](https://metacpan.org/pod/DBD::ODBC) module.  Required for ODBC (SQL etc) access on Linux / Windows (Win32::ODBC not required if using DBD::ODBC) | perl-DBD-ODBC | libdbd-odbc-perl |
| Optional | [Win32::ODBC](https://metacpan.org/pod/Win32::ODBC) module.  Required for ODBC (SQL etc) access on Windows (DBD::ODBC not required if using Win32::ODBC) |  |  |
| Optional | [threads](https://metacpan.org/pod/threads) and [Thread::Semaphore](https://metacpan.org/pod/Thread::Semaphore) modules (included with most if not all distributions).  Required when enabling threads for EXEC statements. | perl-threads | libthreads-perl |
| Optional | [Digest::MD5](https://metacpan.org/pod/Digest::MD5) module (included with most if not all distributions).  Required when enabling duplicate trap detection. | perl-Digest-MD5 | libdigest-md5-perl |

<br />   

All development and testing was done with Linux, Windows 2000 or higher and various versions of Net-SNMP from UCD SNMP v4.2.1 to the current Net-SNMP 5.7.x release. The Windows version has been tested with both native mode and under Cygwin.

SNMP V1, V2 and V3 traps have been tested.

The latest version of Net-SNMP is recommended.

Note:

* SNMPTT only requires the Net-SNMP Perl module if you want to have variable names translated into symbolic form, you want to be able to have **snmptrapd** pass traps using symbolic form, or you enable the options **translate\_integers**, **translate\_trap\_oid** or **translate\_oids**. Although not required, using the Perl module is recommended.  It is also required if you want to use the **snmptthandler-embedded** trap handler with snmptrapd.

# <a name="Whats-New"></a>What's New

## **v1.5** **\- August 17th, 2022**

* Added PREEXEC support for unknown traps.  Results are stored in the variable **$pu*n***.  See the **unknown_trap_preexec** setting in **snmptt.ini**.
* Added **unknown_trap_nodes_match_mode** setting to allow you to change how traps are handled when they do not match due to **MATCH** and **NODES**.  If set to 1, traps are considered skipped instead of unknown.  Statistics now include the number of skipped traps when enabled.
* Added support for wildcards for the **snmptt_conf_files** setting in **snmptt.ini**.  Example: **/etc/snmptt/snmptt.*.conf**
* Added **log_format** **snmptt.ini** setting to allow you to define the STDOUT, text log and eventlog text format.
* Added **syslog_format** **snmptt.ini** setting to allow you to define the syslog text format.  This will allow you to add a structured data section for RFC5424 syslog.
* Added variable substitution **$j** to pull out the enterprise number from the full enterprise OID.  For example, for enterprise OID .1.3.6.1.4.1.232, **$j** would
  contain 232.
* Added remote syslog support using the Perl module Log::Syslog::Fast which also allows you to specify the APP-NAME for RFC5424 syslog.
  Added the following **snmptt.ini** settings: **syslog_module**, **syslog_remote_dest**, **syslog_remote_port**, **syslog_remote_proto**, **syslog_rfc_format**, **syslog_app** and **syslog_system_app**.
* Added reload support to the **snmptt.service** systemd file.  This will allow you to use the **'systemctl reload snmptt'** command to reload the configuration.
* Added support for IPv6.  To enable, set **ipv6_enable = 1** in **snmptt.ini**.
* Added support for sub-second sleep for spool folder processing.
* **snmptt.ini** can now be located in **/etc/snmptt** and is searched for at this
  location first.
* Updated documentation on securing SNMPTT to ensure the snmptt user has read access to the configuration files.  This is required when issuing a reload.
* Fixed a bug with **daemon_uid** that prevented SNMPTT from starting on FreeBSD
  (bug 47).
* Fixed a bug where traps arriving with the hostname set to UNKNOWN were
  not being handled properly (bug 46).
* Fixed a bug with **MATCH** which was preventing it from matching integers properly (bug 41).
* Fixed a bug where the agent IP address was not handled correctly when
  it was received from Net-SNMP as **IpAddress:x.x.x.x** (bug 27).
* Fixed a race condition bug with **snmptthander** and **snmptthandler-embedded**
  which could cause traps to be missed.  Spool files are now immediately locked
  after creation using flock().  If flock() is not supported, the spool file will be created
  with a temporary filename and then renamed after closing.
* Fixed a bug with **wildcard_expansion_separator** which caused an issue when
  using wildcard separators that were longer than one character (bug 38).
* Fixed a bug where quotes were not properly removed from some incoming traps.
* Fixed bug with debug mode that was causing some debug mode output even when
  debug mode was off.
* Fixed a bug where DNS resolution was not working for enterprise variables 
  when **net_snmp_perl_enable** was disabled.
* Fixed a bug that prevented snmptt from starting when debug mode was disabled (bug 48).
* Fixed debug output bug with snmptthandler-embedded (PR 1).
* Fixed a bug with IPv6 address handling for NODES in snmptt.conf.
* Fixed a bug that prevented the hostname from being extraced when IPv6 is disabled and the hostname is passed from Net-SNMP as UDP: [x.x.x.x]:xxxx->[x.x.x.x]:xxxx.
* Changed **net_snmp_perl_best_guess** default from 0 to 2 as any modern system
  should support this.  See FAQ and **snmptt.ini** for details on this variable.
* Enabled Perl warnings to help ensure code is following best practices.
* Ran code against Perl::Critic to find non-optimal code.  Made various adjustments such as relacing bare words with variables and changing open() calls from two arguments to three.
* Documentation was converted from html to markdown to make it easier to maintain and a full review was completed.  Many improvments have been made including a new section on integrating with Icinga.  The docs folder now contains **.md**, **.html** and **.epub** versions of the documentation.
* **snmptthandler-embedded**:
    * Varbind types **Gauge32** and **Hex-STRING** now have the Gauge32: and Hex-STRING: text removed for incoming traps.  Unicode line endings are also removed (Perl 5.10 and higher).
* **snmpttconvertmib**:
    * Added **--exec_file** option to allow you to provide an EXEC command
    inside of a file instead of specifying on the command line.  Useful for
    commands that include quotes so that you don't have to worry about escaping on
    the command line.  Also allows you to define multiple EXEC lines instead of 
    just one.
    * Added **--exec_mode** option to allow you change how the EXEC line
    is built.  Setting to **0** will append the format line to the end of the line
    (default).  Setting to **1** does not append the format line to the end of the
    line.  This is useful if you have added **$Fz** to the **--exec** line so that
    SNMPTT can replace it with the FORMAT line.  Setting to **2** is similar to **1**,
    but instead of SNMPTT having to replace **$Fz** with the FORMAT line, 
    **snmpttconvertmib** will do the substitution.
    * Added **--preexec** and **-preexec_file** options.


## **v1.4.2** **\- July 23rd, 2020**

*   Fixed a security issue with EXEC / PREXEC / unknown\_trap\_exec that could allow malicious shell code to be executed.
*   Fixed a bug with EXEC / PREXEC / unknown\_trap\_exec that caused commands to be run as root instead of the user defined in daemon\_uid.

## **v1.4** **\- November 6th, 2013**

*   Added **snmptt.ini** option net\_snmp\_perl\_cache\_enable to enable caching of Net-SNMP Perl module OID and ENUM translations.  This may speed up translations and reduce CPU load when net\_snmp\_perl\_enable and translate\_\* options are enabled.
*   Fixed bug with snmptthandler-embedded where IP addresses and OIDs were not being detected properly because they contained 'OID:', 'IpAddress:' etc.
*   Fixed bug with MATCH.  The PREEXEC $p variable could not be used with MATCH.  PREEXEC is now executed first if MATCH contains $p.
*   Fixed bug with syslog.  Log entries were supposed to be logged with snmptt\[pid\] but instad of the pid it was actually the effective user ID (2980512).
*   Fixed bug where the hostname is not detected properly when snmptrapd is configured to not use DNS.
*   Fixed bug where if the spool directory is not defined, files may be deleted from the wrong folder (3020696).
*   Fixed bug with syslog logging.  Function was not being called properly (3166749).
*   Fixed bug with MATCH where number ranges were not working (3397982).
*   Fixed bug with multi-line traps (2915658).
*   Fixed bug with LOGONLY severity.  EXEC was being executed even if the trap had a severity of LOGONLY (3567744).
*   Fixed bug with snmptt hanging if the log message sent to syslog contained a % symbol.  All %'s are now escaped before sending to syslog (3567748).
*   Fixed possible bug with MySQL.  Put CONNECT string on one line.
*   Fixed bug with not being able to write to the debug log file when running snmptt as non-root if the debug file didn't already exist with the correct permissions at startup.  The ownership of snmptt.debug is now set to daemon\_uid before switching to the new uid.  Patch 3423525.
*   Installation documentation updates (bug 3425999).

## **v1.3** **\- November 15th, 2009**

*   Added snmptthandler-embedded - a Net-SNMP snmptrapd embedded Perl version of snmptthandler.
*   Added variable substitutions $Be, $Bu, $BE and $Bn for SNMPv3 securityEngineID, securityName, contextEngineID and contextName (requires snmptthandler-embedded handler).
*   Added **snmptt.ini** option **duplicate\_trap\_window variable** for duplicate trap detection.
*   Added LSB init keywords and actions to snmptt-init.d and changed the priority for start / stop so that it starts after snmptrapd and stops before snmptrapd.
*   Changed the default log path to /var/log/snmptt for Unix and c:\\snmpt\\log for Windows to make it easier to grant write permission to the snmptt process.
*   Changed umask for log files to 002 to ensure they are not created as world writable.
*   Fixed a bug where the the PID file was being created using the parent (root) PID instead of the child (daemon\_uid) when daemon\_uid is used.
*   The DEBUG log file will now be re-opened when a HUP signal is sent.
*   When debugging is enabled, flush buffers every sleep cycle so we can tail the debug log file.
*   Don't print messages to the console when starting in daemon mode unless debugging is enabled or an error occurs.
*   'Could not open debug output file!' is no longer reported when debugging is disabled.
*   Added snmptt.logrotate file from Ville Skytta.
*   Fixed a bug (1748512) with handling escaped quotes in a trap message.
*   Updated snmptt-net-snmp-test to test MIB descriptions.
*   SNMPTTConvertMIB:
    *   Fixed a bug (1678270) where a TRAP-TYPE / NOTIFICATION-TYPE line would not translate if it was split across two lines.

## **v1.2** **\- June 16th, 2007**

*   When **daemon\_uid** is used, two processes will now be spawned. The first process will be run as the same user that started SNMPTT (which should be root). The second will run as the **daemon\_uid** user. This was changed so that SNMPTT could properly clean up the pid file on exit.
*   Added snmptt.ini option **pid\_file** to allow for custom pid file locations when running in daemon mode.
*   Fixed bug where pid file did not contain the current pid of snmptt.
*   Added **snmptt.ini** options **date\_format**, **time\_format**, **date\_time\_format**, **date\_time\_format\_sql** and **stat\_time\_format\_sql** to allow the output format for **$x** and **$X** substitution variables, and the format of the date/time for text logs and SQL to be changed using **strftime()** variables. This allows for proper date/time data types to be used in SQL databases.
*   Added logging of trap statistics to a SQL table. Added **\*table\_statistics** **snmptt.ini** variable to define the table to be used.
*   Added ability to add custom columns to **\*\_table** and **\*\_table\_unknown** tables. Added **sql\_custom\_columns** and **sql\_custom\_columns\_unknown** **snmptt.ini** options.
*   Added **snmptt.ini** option **unknown\_trap\_exec\_format** to allow custom output with substitutions.
*   Added the ability to log system messages to a text file in addtion to the existing syslog and Event Log.  Added **snmptt.ini** options **log\_system** and log\_system\_file.
*   Added a work-around to the [Net-SNMP v5.4 traphandle bug (1638225)](http://sourceforge.net/tracker/index.php?func=detail&aid=1638225&group_id=12694&atid=112694) where the host name was set to <UNKNOWN>. When detected, SNMPTT will use the host IP address instead.
*   Added a **$H** variable substitution to give the host name of the computer that is running SNMPTT, or a user defined value specified in the new **snmptt\_system\_name** **snmptt.ini** option.
*   Added MATCH support for bitwise AND
*   Added **snmptt.ini** option **exec\_escape** to escape wildards (\* and ?) in EXEC, PREEXEC and the unknown\_trap\_exec commands. This is enabled by default for Linux and Unix (or anything non-Windows) to prevent the wildcards from being expanded by the shell.
*   Moved **unknown\_trap\_exec** to Exec section in **snmptt.ini**.
*   Added 'use strict' pragma in source code.
*   Experimental:  Added threads (Perl ithreads) support for EXEC. When enabled, EXEC commands will launch in a thread to allow SNMPTT to continue processing other traps. Added **snmptt.ini** options **threads\_enable** and **threads\_max**.
*   Fixed bug where snmptt tried to log to syslog when changing UIDs even if syslog\_system\_enable was set to 0.
*   Fixed a bug in REGEX with handling of captures.  Text::Balanced module is now required.
*   Fixed a bug under Windows where SNMPTT was trying to log to syslog instead of the event log.
*   Fixed a bug where SNMPTT was attempting to log to syslog / eventlog when using the --time option.
*   Fixed a bug in MATCH where the i modifier was not handled correctly.
*   Added information to Nagios section of documentation for using SNMP traps as heartbeats by using freshness checks.
*   Added information to Nagios section of documentation for using freshness checks to automatically clear trap alerts.
*   SNMPTTConvertMIB:
    *   Fixed a bug (1438394) where ARGUMENTS lines that have $1, $2 etc instead of %0, %1 would not translate.
    *   Fixed a bug where a --#SEVERITYMAP line would be used instead of --#SEVERITY.

## **v1.1** **\- January 17th, 2006**

*   Added **PREEXEC** **snmptt.conf** file option to allow an external program to be run before processing the FORMAT and EXEC lines. The output of the external program is stored in the **$p_n_** variable where **_n_** is a number starting from 1. Multiple **PREEXEC** lines are permitted. The first **PREEXEC** stores the result of the command in **$p1**, the second in **$p2** etc. Any ending newlines are removed. The **snmptt.ini** parameter **pre\_exec\_enable** can be used to enable / disable it.
*   **MATCH** statement now accepts any variable name instead of only enterprise variables. Example: MATCH $s:(Normal)
*   Added **NODES MODE=** snmptt.conf file option to allow you to select either **POS** (positive - the default) or **NEG** (negative) for **NODES** matches. If set to **NEG**, then **NODES** is a 'match' only if _none_ of the **NODES** entries match.
*   Added **unknown\_trap\_exec** **snmptt.ini** option. If defined, the command will be executed for ALL unknown traps. Passed to the command will be all standard and enterprise variables, similar to **unknown\_trap\_log\_file** but without the newlines.
*   **snmptt --dump** which dumps all the configured EVENTs, now displays duplicate EVENT entries to assist with troubleshooting duplicate entries trap logs.
*   If the debug log file can not be opened, a message is now logged to syslog if **syslog\_system\_enable** is enabled, and to the Event Log if **eventlog\_system\_enable** is enabled
*   Fixed bug with PostgreSQL where some trap data was interpreted as 'placeholders' in the INSERT statement which caused logging errors. PostgreSQL now uses PREPARE / EXECUTE statements instead.
*   MySQL now uses PREPARE / EXECUTE statements instead of a single INSERT statement.
*   Fixed bug in **NODES** where **NODES** entries from previous EVENTs were not being purged correctly.
*   Fixed bug where **snmptt --dump** would attempt to log to syslog or the Event Log.
*   Fixed bug that prevented the wildcard **.\*** from being accepted on the EVENT line.
*   Added Windows Event Log forwarding documentation to integration section.
*   SNMPTTConvertMIB:
    *   Fixed a bug when **\--format\_desc=n** was used that caused extra trailing whitespaces to be added for every non existent line in the description.
    *   Fixed bug that prevented some MIBs from being accepted due to spacing in the **DEFINITIONS::= line**.
    *   Fixed bug in that prevented **\--ARGUMENTS {}** from being parsed due to spacing.

## **1.0** **\- August 30, 2004**

*   SQL database connections are now opened after forking to the background when running in daemon mode, and after changing users when running SNMPTT as a non-root user. This should prevent 'gone away' and other connection problems with SQL databases due to lost handles.
*   Added **mysql\_ping\_on\_insert**, **postgresql\_ping\_on\_insert** and **dbd\_odbc\_ping\_on\_insert** options to 'ping' the database before doing an INSERT. Also added the options **mysql\_ping\_interval**, **postgresql\_ping\_interval** and **dbd\_odbc\_ping\_interval** to periodically ping the database. These options will help ensure the connection to the database remains available. If an error is returned, it will attempt to reconnect to the database. This should prevent SNMPTT from having to be restarted if the SQL server is not available due to an outage or a connection timeout due to no activity.
*   Added variable substitution **$Fz** which when used on an EXEC line will dump the translated FORMAT line. This will allow for simplified EXEC lines when they are the same as the FORMAT line (minus the command to execute of course).
*   Added variable substitutions **$Fa**, **$Ff**, **$Fn**, **$Fr**, **$Ft**, for alarm (bell), form feed (FF), newline (LF, NL), return (CR) and tab (HT, TAB)
*   Added variable substitution **$D** to dump the description text for FORMAT and EXEC lines. The descriptions can be pulled from either the SNMPTT.CONF or MIB files. This is controlled by the **description\_mode** and **description\_clean** **snmptt.ini** options.
*   Added support for logging unknown traps to a SQL table
*   Added logging of statistical information for **total traps received**, **total traps translated**, **total traps ignored** and **total unknown traps**. Statistics are logged at shut down, and optionally at a defined interval defined by the new **snmptt.ini** variable **statistics\_interval**. Logging can also be forced by sending the SIGUSR1 signal, or by creating a file called !statistics in the spool folder.
*   Added the error number reported by MySQL to MySQL errors (system syslog, eventlog etc)
*   Added **/usr/local/etc/snmp** and **/usr/local/etc** paths to the list of default directories searched for **snmptt.ini**.
*   Added some friendly error messages when required Perl modules are not available
*   Fixed bug with with handling traps in symbolic format (snmptrapd without -On)
*   Fixed bug with with using printing $ symbols in FORMAT and EXEC lines
*   Added [Simple Event Correlator (SEC)](http://kodu.neti.ee/%7Eristo/sec/) integration documentation
*   SNMPTTConvertMIB:
    *   Fixed bug that prevented the variable list (OBJECTS) of V2 MIB files from being converted
    *   Fixed bug that caused an infinite loop processing the VARIABLES/OBJECTS section if the line in the MIB file contained spaces after the closing bracket

## **0.9** **\- November 3rd, 2003**

*   Syslog messages are now logged with snmptt\[pid\] instead of TRAPD for traps, and snmptt-sys\[pid\] instead of SNMPTT for system messages
*   Added the option daemon\_uid which causes snmptt to change to a different user (uid) after launching on Unix systems running in daemon mode
*   Fixed bug that prevented ip addresses from being detected correctly with translate\_value\_oids
*   Fixed bug with MATCH that caused integer ranges from not being handled correctly
*   Separated SNMPTT, SNMPTTCONVERT, SNMPTTCONVERTMIB and FAQ / Troubleshooting documentation into separate documents

## **0.8** **\-** **September 16th****, 2003**

*   Added MATCH keyword support to allow trap matching based on values contained inside the trap enterprise variables
*   REGEX now supports substitution with captures and the modifiers i, g and e.  The e modifier allows for complex REGEX expressions.
*   Added support for remote MySQL and PostgreSQL databases
*   Added PostgreSQL support for [DBD:Pg](http://search.cpan.org/search?dist=DBD-Pg)
*   An EVENT can now contain mulitple EXEC lines
*   An EVENT can now contain mulitple NODES lines
*   Added the option dynamic\_nodes to allow NODES files to be either loaded at startup or loaded each time an EVENT is processed
*   Added trapoid column for database logging to contain the actual trap received.  The eventid column will contain the actual matched entry from the .conf file (which could be a wildcard OID)
*   Fixed bug that prevented some variables from displaying the correct values because the received trap OID was replaced with the actual EVENT entry
*   Fixed bug that caused OIDs not to be translated correctly with translate\_value\_oids enabled
*   Agent IP address is now used instead of 'host' IP address for NODES matches, the 'hostname' column in database logs and the $A variable
*   Variable $A now prints the agent host name.  $aA prints the agent IP address.
*   Variable $E now prints the enterprise in symbolic form.  $e prints the numeric OID
*   Variable $O now prints the trap in symbolic form.  $o prints the numeric OID
*   Added new variable substitution **$i** to print the actual matched entry from the .conf file (which could be a wildcard OID)
*   Added the configuration option dns\_enable to enable DNS lookups on host and agent IP addresses
*   If DNS is enabled, NODES entries are resolved to IP addresses and the IP address is used to perform the match.  This will allow for aliases to be used.
*   Added the option resolve\_value\_ip\_addresses to resolve ip addresses contained inside enterprise variable values
*   Changed snmptt.ini setting translate\_trap\_oid to translate\_log\_trap\_oid
*   Changed snmptt.ini setting translate\_oids to translate\_value\_oids
*   Added configuraiton settings: translate\_enterprise\_oid\_format, translate\_trap\_oid\_format, translate\_varname\_oid\_format and db\_translate\_enterprise
*   $O follows translate\_trap\_oid\_format, and $o is always the numerical trap OID
*   $E follows translate\_enterprise\_oid\_format, and $e is always the numerical enterprise OID
*   The enterprise column when logging to a database now follows the db\_translate\_enterprise setting
*   Fixed bug with $# to report the correct number of enterprise variables (was 1 lower than it should have been)
*   Fixed bug with handling traps that contain quoted values that span multiple lines
*   PID file now created (/var/run/snmptt.pid or ./snmptt.pid) when running in daemon mode on Linux / Unix.  snmptt-init.d script updated to remove the pid file when shutting down snmptt.
*   Added [Nagios](http://www.nagios.org) / Netsaint integration documentation
*   Added contrib folder
*   SNMPTTConvertMIB
    *   Now prints the variables contained in each trap definition unless \--no\_variables is set.  When using \--net\_snmp\_perl it will also resolve the Syntax (INTEGER, OCTETSTR etc) and Description.  If it's an INTEGER, will also print out the enumeration tags if any exist.
    *   Improved compatability with MIB files

## **0.7** **\- April 17th****, 2003**

*   Fixes a vulnerability that prevents the possibility of injected commands contained in traps from being executed when using the EXEC feature
*   Added the ability for traps passed from snmptrapd or loaded from the snmptt.conf files to contain symbolic OIDs such as linkDown and IF-MIB::linkUp.  This feature requires the UCD-SNMP / Net-SNMP Perl module
*   Added the configuration options **translate\_trap\_oid** and translate\_oids to have the trap OID and OID values contained in the trap variables converted from numerical OID to symbolic form before logging.  This feature requires the UCD-SNMP / Net-SNMP Perl module
*   Added support for logging of traps using PostgreSQL via DBI / DBD::PgPP
*   Added REGEX keyword support to allow user definable search and replace on FORMAT / EXEC lines
*   NODES entry can now contain a CIDR address (eg: 192.168.10.0/23), or a network range (192.168.10.0-192.168.11.255)
*   NODES entry can now contain a mix of host names, IP addresses, CIDR addresses, network ranges and filenames
*   Added the ability to force a reload of the configuration files while running in daemon mode by placing a file called !reload in the spool directory
*   Added snmptt-net-snmp-test program to perform various translations of numeric and symbolic OIDS to assist with determining if the installed Perl module  
    will function as expected with SNMPTT
*   Fixed bug that prevented quoted text from being logged correctly to SQL databases
*   Fixed bug that would prevent the translation of integer values to enumeration tags and variable name substitutions when using Net-SNMP 5.0.x
*   SNMPTTConvertMIB
    *   FORMAT / EXEC line can now contain any of the following:
        *   \--#SUMMARY or DESCRIPTION (use DESCRIPTION only if --#SUMMARY does not exist)
        *   description or --#SUMMARY (use --#SUMMARY only if DESCRIPTION does not exist)
        *   \--#SUMMARY and DESCRIPTION
        *   DESCRIPTION and --#SUMMARY
    *   When using the DESCRIPTION to build the FORMAT / EXEC line, can now choose between using the first line of the DESCRIPTION field, or the first x number of sentences
    *   The use of the --#SUMMARY and DESCRIPTION line for the FORMAT / EXEC line can be disabled
    *   Support for multiple --#SUMMARY lines
    *   Support for --#SEVERITY lines
    *   The default of using the $\* wildcard can be disabled
    *   Conversion of the DESCRIPTION section to SDESC / EDESC can be disabled
    *   EXEC line can be specified on the command line
    *   NODES line can be specified on the command line

## **0.6 - March** **25th, 2003**

*   Logging:
*   *   Added support for logging of traps using DBD::ODBC
    *   Fixed bug with Win32::ODBC connection not being closed on exit of SNMPTT
    *   MySQL code cleanup
    *   Added support for logging traps to the NT Event Log including the ability to select the Event Log level based on the severity level defined in the snmptt.conf file
    *   Improved syslog support by adding the ability to select the syslog level based on the severity level defined in the snmptt.conf file
    *   Added syslog and NT Event Log support for SNMPTT 'system' events such as startup, shutdown, errors handling spool directory / files, database connectivity errors etc
    *   Added the option **keep\_unlogged\_traps** to have SNMPTT erase the spooled trap file only after it successfully logs to at least one or all log systems.  This will help prevent traps from being lost due to logging problems.
*   Added ability to translate integer values to enumeration tags defined in MIB files.  This feature requires the UCD-SNMP / Net-SNMP Perl module
*   Added new variable substitutions: **$v_n_** (variable name), **$+_n_**(variable name:value), **$-_n_** (variable name (type):value), **$+\*** (same as $+_n_ but wildcard), and **$-\*** (same as $-_n_ but wildcard).  Translation of the variable name using the MIB requires the UCD-SNMP / Net-SNMP Perl module.
*   If a variable is passed from snmptrapd that is blank, snmptt will replace it with (null)
*   Fixed bug that would prevent variables numbered 10 or higher from being translated correctly
*   Fixed bug with handling trap data that contains spaces but is not inside of quotes
*   Code cleanup to remove Perl warnings (-w)
*   Added separate debug file for snmptthandler
*   Cleaned up defaults code for snmptthandler
*   Added examples folder containg a sample snmptt.conf file and sample trap file
*   Added FAQ section to this document
*   Snmpttconvertmib
    *   Code cleanup
    *   Now uses new command line arguments (snmpttconvertmib -h for help).
    *   Can now use either snmptranslate or the SNMP Perl module (Net-SNMP) to process MIB files
    *   Can now add a NODES line when converting MIB files
    *   Now checks the version of snmptranslate before converting the mib to ensure snmptranslate is called correctly
    *   Fixed bug which would cause the last notification of a v2 MIB file not to be converted correctly

## **0.5 - February 12th, 2003**

*   Spool file list sorted before processing to ensure traps are processed in the order they are received when in daemon mode
*   Added **use\_trap\_time** variable to config file for daemon mode to have SNMPTT use either the time from the spool file, or the current time.  Changed SNMPTTHANDLER to output the current date and time on the first line of the spool file
*   Fixed bug with default variable settings being ignored.  Defaults were not being set correctly if variable was not defined in the .ini file.
*   Fixed bug with SNMPTT ignoring the daemon mode parameter in the .ini file
*   Fixed bug with Nodes list not being flushed out for each processed trap when running in daemon mode
*   Added **strip\_domain** and **strip\_domain\_list** configuration options to enable / disable the removal of the domain name from the host name passed to SNMPTT.  Defaults to disabled (do not  strip domain name)
*   SNMPTTCONVERTMIB now prepends the contents of the --#TYPE line (if present) to the --#SUMMARY line to provide a more descriptive FORMAT / EXEC line

## **0.4 - November 18th, 2002**

*   Variable substitution changes:
*   *   $X = Date, $x = Time instead of $x being both date and time
    *   $N = Event name instead of $S
    *   Added $c, $@, $O, $o, $ar, $R, $aR, $G, $S
*   Configuration moved to a .ini file
*   MySQL support via DBI under Linux and Windows
*   ODBC support via Win32::ODBC under Windows

## **0.3 - September 11th, 2002**

*   Daemon mode support for SNMPTT.  When running as a daemon, SNMPTTHANDLER script is used to spool traps from SNMPTRAPD.
*   SNMPTTCONVERTMIB utility to convert trap / notify definitions from MIB files
*   Sample trap file (sample-trap) for testing
*   Command line options to SNMPTT
*   SNMPTT now strips UDP: and :_port_ from IP addresses when using Net-SNMP 5.0+
*   NODES files can now contain comments
*   NODES files can now contain either host names or IP addresses
*   You can now have multiple definitions of the same trap so that different hosts / nodes can have different actions or one host have multiple actions
*   Configuration file can now contain a list of other configuration files to load

## **0.2 - July 10th, 2002**

*   Improved debugging output
*   Severity substitution bug fix
*   SNMP V2 trap bug fix
*   UCD-SNMP v4.2.3 problem workaround

## **0.1 - April 18th, 2002**

*   Initial release

# <a name="Upgrading"></a>Upgrading

## **v1.4.2 to v1.5beta1**

To upgrade from v1.4.2 to v1.5 you should:

1.  Replace **snmptt** with the new version.  Make sure the file is executable (**chmod +x _filename_**).
1.  Replace **snmptthandler-embedded** with the new version.  Make sure the file is executable (**chmod +x _filename_**).
1.  Replace **snmpttconvertmib** with the new version.  Make sure the file is executable (**chmod +x _filename_**).
1.  For systemd systems, replace the **snmptt.service** service file with the new version.
1.  Backup your **snmptt.ini** file, replace it with the new version, and make any necessary configuration changes to it.
1.  Secure your **/etc/snmp** or **/etc/snmptt** folder as described in the **Securing SNMPTT** section of the documentation.
1.  To enable IPv6 support, set **ipv6_enable = 1** in **snmptt.ini**. 
   
Notes:  

1.  Starting with v1.5, you can use **/etc/snmptt/** instead of **/etc/snmp/** for your **snmptt.ini** file.  
2.  DNS now requires the Perl module **IO::Socket::IP**.  
3.  IPv6 requires the Perl module **Net::IP**.  

## **v1.4 to v1.4.2**

To upgrade from v1.4 to v1.4,1, you should:

1.  Replace **snmptt** with the new version.  Make sure the file is executable (**chmod +x _filename_**).
2.  Confirm that the **snmptt** user account is a member of the appropriate groups such as **nagios** for Nagios and **icingacmd** for Icinga2.
3.  Backup your **snmptt.ini** file and then add the new option **daemon\_gid = snmptt** below **daemon\_uid**.
4.  To increase security:
    *   If you are not currently using daemon mode and are running as root, please switch to daemon mode or run as different user such as **snmptt**.
    *   Secure the spool folder with:
    
    *   **chown -R snmptt.snmptt /var/spool/snmptt**
    *   **chmod -R 750 /var/spool/snmptt**
    
    *   Secure the /etc/snmp folder with
    
    *   **chown -R root.root /etc/snmp**
    *   **chmod 755 /etc/snmp**
    *   **chown snmptt.snmptt /etc/snmp/snmptt\***
    *   **chmod 660 /etc/snmp/snmptt\***

## **v1.3 to v1.4**

To upgrade from v1.3 to v1.4, you should:

1.  Replace **snmptt** and **snmptthandler-embedded** with the new versions.  Make sure the files are executable (**chmod +x _filename_**).
2.  Backup your **snmptt.ini** file, replace it with the new version, and make any necessary configuration changes to it.  The only change is the addition of the net\_snmp\_perl\_cache\_enable option.
3.  Check your snmptt.conf files for any traps defined with LOGONLY.  These entries will no longer have EXEC lines executed.  In previous versions EXEC was exectued when it should not have been.
4.  The new **snmptt.ini** option net\_snmp\_perl\_cache\_enable defaults to on, so disable if required.

## **v1.2 to v1.3**

To upgrade from v1.2 to v1.3, you should:

1.  Replace **snmptt** and **snmpttconvertmib** with the new versions.  Make sure the files are executable (**chmod +x _filename_**).
2.  Copy snmptt-init.d to /etc/init.d/snmptt.  Make sure the file is executable (**chmod +x _filename_**).
3.  Optional:  Install and configure the snmptthandler-embedded trap handler.  See [Embedded handler](snmptt.html#Installation-Unix-Embedded) for details.
4.  Backup your **snmptt.ini** file, replace it with the new version, and make any necessary configuration changes to it.  The default log paths have changed so modify as needed.
5.  Setup log rotation by copying snmptt.logrotate to /etc/logrotate.d/snmptt and modifying as needed for the correct paths, rotate frequency etc.
6.  Enable any new features in **snmptt.ini** as required.

## **v1.1 to v1.2**

To upgrade from v1.1 to v1.2, you should:

1.  Replace **snmptt** and **snmpttconvertmib** with the new versions contained in the v1.2 package.  Make sure the files are executable (**chmod +x _filename_**).
2.  Backup your **snmptt.ini** file, replace it with the new version, and make any necessary configuration changes to it.
3.  Enable any new features in **snmptt.ini** as required.
4.  For Linux and Unix (or anything non-Windows), if you are using the **daemon\_uid** option in **snmptt.ini**, and are monitoring the availability of snmptt by checking for the snmptt process, be aware that there will now be two snmptt processes running instead of one.
5.  For Linux and Unix (or anything non-Windows), the **snmptt.ini** **exec\_escape** option is enabled by default which will escape wildcard characters (\* and ?) for EXEC, PREEXEC and the unknown\_trap\_exec commands. Disable if required.

## **v1.0 to v1.1**

To upgrade from v1.0 to v1.1, you should:

1.  Replace **snmptt** and **snmpttconvertmib** with the new versions contained in the v1.1 package.  Make sure the files are executable (**chmod +x _filename_**).
2.  Backup your **snmptt.ini** file, replace it with the new version, and make any necessary configuration changes to it.
3.  Enable any new features in **snmptt.ini** as required.

## **v0.9 to v1.0**

To upgrade from v0.9 to v1.0, you should:

1.  Replace **snmptt**, **snmpttconvert**, **snmpttconvertmib**, and **snmptthandler** with the new versions contained in the v1.0 package.  Make sure the files are executable (**chmod +x _filename_**).
2.  Backup your **snmptt.ini** file, replace it with the new version, and make any necessary configuration changes to it
3.  If you are using a MySQL, PostgreSQL or ODBC (via DBD::ODBC) and do not want the database to be pinged before each INSERT, set **mysql\_ping\_on\_insert**, **postgresql\_ping\_on\_insert** or **dbd\_odbc\_ping\_on\_insert** to 0 in **snmptt.ini**. If you do not want the database to be pinged periodically, set **mysql\_ping\_interval**, **postgresql\_ping\_interval** or **dbd\_odbc\_ping\_interval** to 0 in **snmptt.ini**.
4.  Enable any new features in snmptt.ini as required
5.  Test and report any issues to alex\_b@users.sourceforge.net, or open a bug report at [Sourceforge](http://sourceforge.net/tracker/?group_id=51473&atid=463393).

## **v0.8 to v0.9**

To upgrade from v0.8 to v0.9, you should:

1.  Replace snmptt with the new version contained in the v0.9 package.  Make sure the file is executable (chmod +x filename)
2.  Backup your **snmptt.ini** file, replace it with the new version, and make any necessary configuration changes to it
3.  If you have any external applications that monitor the syslog for SNMPTT or TRAPD messages, modify them to look for snmptt\[pid\] and snmptt-sys\[pid\] instead
4.  Enable any new features in snmptt.ini as required
5.  Test and report any issues to alex\_b@users.sourceforge.net, or open a bug report at [Sourceforge](http://sourceforge.net/tracker/?group_id=51473&atid=463393).

## **v0.7 to v0.8**

To upgrade from v0.7 to v0.8, you should:

1.  Replace snmptt and snmpttconvertmib with the new versions contained in the v0.8 package.  Make sure the files are executable (chmod +x filename)
2.  Replace your /etc/rc.d/init.d/snmptt file (cp snmptt-init.d /etc/rc.d/init.d/snmptt).  Make sure the file is executable (chmod +x filename)
3.  Backup your **snmptt.ini** file, replace it with the new version, and make any necessary configuration changes to it
4.  In your snmptt.ini file, configure translate\_log\_trap\_oid with translate\_trap\_oid value from old snmptt.ini
5.  In your snmptt.ini file, configure translate\_value\_oids with translate\_oids value from old snmptt.ini
6.  In your snmptt.ini file, set dynamic\_nodes to 1 if you want the NODES files to be loaded each time an event is processed which is how previous versions of snmptt worked
7.  In your snmptt.conf files, replace any $A with $aA unless you want agent host names to be used instead of IP addresses
8.  In your snmptt.conf files, replace any $E with $e unless you want Enterprise trap OID in symbolic format
9.  In your snmptt.conf files, replace any $O with $o unless you want Trap OID in symbolic format
10.  In your snmptt.conf files, append a g to the end of all REGEX lines to enable global search and replace
11.  Review other translate settings in snmptt.ini
12.  Enable any new features in snmptt.ini as required
13.  If you are using database logging, add a new column called trapoid
14.  If you are using database logging and you enable conversions of OIDs to long names, make sure the table columns are wide enough to hold them
15.  Test and report any issues to alex\_b@users.sourceforge.net, or open a bug report at [Sourceforge](http://sourceforge.net/tracker/?group_id=51473&atid=463393).

## **v0.6 to v0.7**

To upgrade from v0.6 to v0.7, you should:

1.  Replace **SNMPTT** and **SNMPTTCONVERTMIB** with the new versions contained in the v0.7 package
2.  Backup your **snmptt.ini** file, replace it with the new version, and make any necessary configuration changes to it
3.  Enable any new features in snmptt.ini as required
4.  Test and report any issues to alex\_b@users.sourceforge.net, or open a bug report at [Sourceforge](http://sourceforge.net/tracker/?group_id=51473&atid=463393).

## **v0.5 to v0.6**

To upgrade from v0.5 to v0.6, you should:

1.  Replace **SNMPTTHANDLER, SNMPTT** and **SNMPTTCONVERTMIB** with the new versions contained in the v0.6 package
2.  Backup your **snmptt.ini** file, replace it with the new version, and make any necessary configuration changes to it
3.  Enable any new features in snmptt.ini as required
4.  Test and report any issues to alex\_b@users.sourceforge.net, or open a bug report at [Sourceforge](http://sourceforge.net/tracker/?group_id=51473&atid=463393).  
    

## **v0.4 to v0.5**

To upgrade from v0.1, v0.2 to v0.3 to v0.4, you should:

1.  Set **use\_trap\_time** to **0** to have SNMPTT operate the same as v0.4, or leave as 1 (recommended default) and test
2.  Replace **both** **SNMPTTHANDLER** and **SNMPTT** with the new versions contained in the v0.5 package
3.  Backup your **snmptt.ini** file, replace it with the new version, and make any necessary configuration changes to it

## **v0.1, v0.2 or v0.3 to v0.4**

To upgrade from v0.1, v0.2 to v0.3 to v0.4, you should:

1.  In your snmptt.conf file, replace all **$x** with **$x $X** (see What's New section)
2.  In your snmptt.conf file, replace all **$S** with **$N (**see What's New section)
3.  Configure the snmptt.ini as described in this file - configuration options are no longer stored in the snmptt and snmptthandler scripts
4.  If your snmptt.conf file contained a list of other snmptt.conf files instead of trap definitions, move that list to the snmptt.ini file

# <a name="Installation"></a>Installation

## <a name="Installation-Overview"></a>Overview
  
SNMPTT can be run in either daemon mode or standalone mode.  Daemon mode is recommended.  See [Modes of Operation](#Modes-of-Operation "Modes of Operation") for more details.  
  
The following outlines the general steps required to install and configure SNMPTT:  
  

1.  Install Net-SNMP and SNMPTT as described below.
2.  Copy the sample snmptt.conf to your configuration folder.
3.  [Modify snmptt.ini](#Configuration-Options) to include the **snmptt.conf** file and set any desired options.
4.  Start SNMPTT.
5.  Test using the sample trap file.
6.  Create an **snmptt.conf** file [by hand](#SNMPTT.CONF-Configuration-file-format), or using [snmpttconvertmib](#SNMP-Trap-Translator-Convert-MIB).
7.  Configure your network devices to send traps to the Net-SNMP / SNMPTT machine.
8.  Initiate a trap on your network device and check the SNMPTT log files for the result.
9.  Secure the SNMPTT installation.

## <a name="Installation-Unix"></a>Installation - Unix

### <a name="Installation-Unix-Package"></a>Package Manager

Packages are available for most Linux distributions and FreeBSD.  Check your package manager to see if they have the latest version.  If not, you can manually install using the steps below.

### <a name="Installation-Unix-Manual"></a>Manual installation

 Steps:

1. Install Net-SNMP and the Perl modules as listed int the [Requirements](#Requirements) section.

1. Copy **snmptt** to /usr/sbin/ and ensure it is executable (**chmod +x snmptt**):

        cp snmptt /usr/sbin/
        chmod +x /usr/sbin/snmptt

1. Create snmptt user:

    1.  RedHat based systems:

            adduser -r snmptt

    2.  Debian based systems:

            adduser --system --group snmptt

1. Create /etc/snmptt and set permissions.  Note: Starting with v1.5, you can use /etc/snmptt/ instead of /etc/snmp/ for your snmptt.ini file.m

        mkdir /etc/snmptt
        chown -R snmptt.snmptt /etc/snmptt
        chmod 750 /etc/snmptt

3. Copy **snmptt.ini** to **/etc/snmptt** and edit the options inside the file:

        cp snmptt.ini /etc/snmptt/

    and

        vi /etc/snmptt/snmptt.ini

4. Either copy **examples/snmptt.conf.generic** to **/etc/snmptt/snmptt.conf** (renaming the file during the copy) or use the touch command to create the file (**touch /etc/snmptt/snmptt.conf**).

        cp examples/snmptt.conf.generic /etc/snmptt/snmptt.conf

    or

        touch /etc/snmptt/snmptt.conf

5. Create the log folder **/var/log/snmptt/**:

        mkdir /var/log/snmptt
        chown -R snmptt.snmptt /var/log/snmptt
        chmod -R 750 /var/log/snmptt

2. Create the spool folder **/var/spool/snmptt/**:

        mkdir /var/spool/snmptt/
        chown -R snmptt.snmptt /var/spool/snmptt
        chmod -R 750 /var/spool/snmptt

3. Startup scripts are included for SystemD (uses **systemctl** to control services) and SysVinit systems.  Select one depending on your distribution.

    2. Systemd:

        1. Copy the script and remove executable flag if set.

                cp snmptt.service /usr/lib/systemd/system/snmptt.service
                chmod -x /usr/lib/systemd/system/snmptt.service

        2. Enable the service:

                systemctl enable snmptt.service

        3. Start the service:

                systemctl start snmptt.service

     1. SysVinit:

        1. Copy the script:

                cp snmptt-init.d /etc/rc.d/init.d/snmptt

        4. Add the service using chkconfig:

                chkconfig --add snmptt

        5. Configure the service to start at runlevel 2345:

                chkconfig --level 2345 snmptt on
 
        6. Start the service:

                service snmptt start

    3.  Manually starting without SystemD or SysVinit:

            snmptt --daemon

8. Check syslog to ensure SNMPTT started properly:

        grep snmptt /var/log/messages
        grep snmptt /var/log/syslog

    Example log messages:

        snmptt-sys[31442]: SNMPTT 1.5.2 started
        snmptt-sys[31442]: Loading /etc/snmptt/snmptt.conf
        snmptt-sys[31442]: Finished loading 64 lines from /etc/snmptt/snmptt.conf
        snmptt: PID file: /var/run/snmptt.pid
        snmptt-sys[31446]: Configured daemon_uid: snmptt
        snmptt-sys[31446]: Changing to UID: snmptt (1002), GID: snmptt (1002)

    Note: If SNMPTT doesn't start, try running it manually from the shell prompt to see if there are any missing Perl modules.

8. A log rotation script is included which can be used to rotate the log files on Red Hat and other systems.  Copy the file to the logrotate.d directory (renaming the file during the copy):

        cp snmptt.logrotate /etc/logrotate.d/snmptt

    Edit the **/etc/logrotate.d/snmptt** and update the paths and rotate frequency as needed.

        vi /etc/logrotate.d/snmptt

### <a name="Installation-Unix-Handlers"></a>Net-SNMP handlers

Next we will install the Net-SNMP handler.  There are two options:  The standard handler and the embedded handler.  The embedded handler is recommended.

#### <a name="Installation-Unix-Standard"></a>Net-SNMP Standard handler

The standard handler is a small Perl program that is called by snmptrapd each time a trap is received when using daemon mode.  The limitations of this handler are:  

*   Each time a trap is received, a process must be created to run the snmptthandler program and snmptt.ini is read each time
*   SNMPv3 EngineID and names are not passed by snmptrapd to snmptthandler

The benefits of using this handler are:  

* Does not require Net-SNMP embedded Perl for snmptrapd
* Has been around since v0.1 of SNMPTT
* Sufficient for most installations

Steps:

2. Copy **snmptthandler** to /usr/sbin/ and ensure it is executable (**chmod +x snmptthandler**).

        cp snmptthandler /usr/sbin/
        chmod +x /usr/sbin/snmptthandler

4.  Manually start **snmptthandler** to make sure there are no missing Perl modules:

        /usr/sbin/snmptthandler

    Missing Perl module example:

        Can't locate Time/HiRes.pm in @INC (you may need to install the Time::HiRes module) (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5) at /usr/sbin/snmptthandler-embedded line 42.
        BEGIN failed--compilation aborted at /usr/sbin/snmptthandler-embedded line 42.

    No missing Perl modules example.  Errors below can be ignored:

        SNMPTTHANDLER started: Sun Feb 27 10:39:39 2022

        s = 1645976379, usec = 360145
        s_pad = 1645976379, usec_pad = 360145

        Data received:

    Press control-c to exit the handler.

7. For **SNMPTT daemon mode**:
    1. Modify (or create) the Net-SNMP **snmptrapd.conf** file by adding the following lines:

            disableAuthorization yes
            traphandle default /usr/sbin/snmptthandler

        Note:  You can locate the **snmptrapd.conf** file by running:
        
            snmpconf -i

6. For **SNMPTT standlone mode**: 
    1. Modify (or create) the Net-SNMP snmptrapd.conf file by adding the following lines:

            disableAuthorization yes
            traphandle default /usr/sbin/snmptt

        Note:  You can locate the **snmptrapd.conf** file by running:
        
            snmpconf -i  

        Note:   It is possible to configure snmptrapd to execute snmptt based on the specific trap received, but using the default option is preferred

10. Permanently change snmptrapd to use the **-On** option by modifying the startup script:
  
    1. Systemd:  
  
        Edit the unit file and add the **-On** option:
  
            systemctl edit --full snmptrapd.service
  
        Change:

            Environment=OPTIONS="-Lsd"
  
        to:
        
            Environment="OPTIONS=-Lsd -On"

        Note:  Move the first quote to before OPTIONS.
  
  
    2. SysVinit:  
  
        Edit the **/etc/rc.d/init.d/snmptrapd** file and add **"-On"** to **OPTIONS**:

            vi /etc/rc.d/init.d/snmptrapd

        Change:

            OPTIONS="-Lsd"

        to:
                
            OPTIONS="-Lsd -On"

    Note:  **The -On option is recommended**.  This will make snmptrapd pass OIDs in numeric form and prevent SNMPTT from having to translate the symbolic name to numerical form.  If the **Net-SNMP Perl module** is not installed, then you MUST use the **-On** switch.  Depending on the version of Net-SNMP, some symbolic names may not translate correctly.  See the FAQ for more info.

    As an alternative, you can edit the Net-SNMP configuration file **/etc/snmp/snmp.conf** to include the line: **printNumericOids 1. ** This setting will take effect no matter what is used on the command line.

10.  Start / restart snmptrapd using systemctl or service:

        systemctl restart snmptrapd
        service snmptrapd restart

8. Check syslog to ensure SNMPTT started properly:

        grep snmptrapd /var/log/messages
        grep snmptrapd /var/log/syslog

10. Follow the steps in the section [Securing SNMPTT](#SecuringSNMPTT) to ensure SNMPTT has been configured securely.

 
#### <a name="Installation-Unix-Embedded"></a>Net-SNMP Embedded handler

  
The embedded handler is a small Perl program that is loaded directly into snmptrapd when snmptrapd is started.  The limitations of this handler are:  

*   Requires embedded Perl for snmptrapd
*   Only works with daemon mode

The benefits of using this handler are:  

*   The handler is loaded and initialized when snmptrapd is started, so there is less overhead as a new process does not need to be created and initialization is done only once (loading of snmptt.ini).
*   SNMPv3 EngineID and names variables are available in SNMPTT (B\* variables)

Steps:

1. Make sure **snmptrapd** has embedded Perl support enabled.  To see if it's enabled in your installation, type:

        snmptrapd -H 2>&1 | grep perl
    
    If it returns **perl   PERLCODE** then embedded Perl is enabled.  If it's not enabled, you will need to find another Net-SNMP package with it enabled, or compile Net-SNMP using the **--enable-embedded-perl** configure option.

3. Copy **snmptthandler-embedded** to /usr/sbin/.  It does not need to be executable as it is called directly by snmptrapd.

        cp snmptthandler-embedded /usr/sbin/
        chmod +x /usr/sbin/snmptthandler-embedded

4.  Manually start **snmptthandler-embedded** to make sure there are no missing Perl modules:

        /usr/sbin/snmptthandler-embedded

    Missing Perl module example:

        Can't locate Time/HiRes.pm in @INC (you may need to install the Time::HiRes module) (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5) at /usr/sbin/snmptthandler-embedded line 42.
        BEGIN failed--compilation aborted at /usr/sbin/snmptthandler-embedded line 42.

    No missing Perl modules example.  Errors below can be ignored:

        Bareword "NETSNMPTRAPD_HANDLER_OK" not allowed while "strict subs" in use at /usr/sbin/snmptthandler-embedded line 264.
        Execution of /usr/sbin/snmptthandler-embedded aborted due to compilation errors.

7. Configure snmptrapd and install the service:  
  
    Modify (or create) the Net-SNMP snmptrapd.conf file by adding the lines below.  Note: You can locate the **snmptrapd.conf** file by running **snmpconf -i**.

        disableAuthorization yes
        perl do "/usr/sbin/snmptthandler-embedded"

10. Permanently change snmptrapd to use the **-On** option by modifying the startup script:
  
    1. Systemd:  
  
        Edit the unit file and add the **-On** option:
  
            systemctl edit --full snmptrapd.service
  
        Change:

            Environment=OPTIONS="-Lsd"

        to:
        
            Environment="OPTIONS=-Lsd -On"

        Note:  Move the first quote to before OPTIONS.
  
  
    2. SysVinit:  
  
        Edit the **/etc/rc.d/init.d/snmptrapd** file and add **"-On"** to **OPTIONS**:

            vi /etc/rc.d/init.d/snmptrapd

        Change:

            OPTIONS="-Lsd"

        to:
                
            OPTIONS="-LsdOn"
  
    Note:  **The -On option is recommended**.  This will make snmptrapd pass OIDs in numeric form and prevent SNMPTT from having to translate the symbolic name to numerical form.  If the **Net-SNMP Perl module** is not installed, then you MUST use the **-On** switch.  Depending on the version of Net-SNMP, some symbolic names may not translate correctly.  See the FAQ for more info.

    As an alternative, you can edit the Net-SNMP configuration file **/etc/snmp/snmp.conf** to include the line: **printNumericOids 1. ** This setting will take effect no matter what is used on the command line.

10.  Start / restart snmptrapd using systemctl or service:

        systemctl restart snmptrapd
        service snmptrapd restart

8. Check syslog to ensure SNMPTT started properly:

        grep snmptrapd /var/log/messages
        grep snmptrapd /var/log/syslog

10. Follow the steps in the section [Securing SNMPTT](#SecuringSNMPTT) to ensure SNMPTT has been configured securely.

Note:  The default snmptt.ini enables logging to snmptt.log and also syslog for both trap messages and snmptt system messages.  Change the following settings if required:  **log\_enable**, **syslog\_enable** and **syslog\_system\_enable**. 


### <a name="Installation-Unix-Testing"></a>Testing

1. Copy a sample trap file to the spool folder:

        cp examples/'#sample-trap.generic.daemon' /var/spool/snmptt/

2.  Check the snmptt.log file for the trap.  Note:  The date is from the sample trap file.

        tail /var/log/snmptt/snmptt.log

        Mon Aug 16 10:06:35 2004 .1.3.6.1.6.3.1.1.5.3 Normal "Status Events" router01 - Link down on interface 3.  Admin state: 2.  Operational state: 3

2.  Check syslog for the trap from **snmptt**.  Note:  The date is from the sample trap file.

        grep 'snmptt\[' /var/log/messages
        grep 'snmptt\[' /var/log/syslog

        Feb 27 10:29:52 server1 snmptt[83096]: .1.3.6.1.6.3.1.1.5.3 Normal "Status Events" router01 - Link down on interface 3.  Admin state: 2.  Operational state: 3

3.  Generate a **linkDown** trap using **snmptrap**:

        snmptrap -v 2c -c public 127.0.0.1 .1.3.6.1.6.3.1.1.5.3 .1.3.6.1.6.3.1.1.5.3 ifIndex i 2 ifAdminStatus i 1 ifOperStatus i 2

2.  Check the syslog file for the trap from **snmptrapd**:

        grep snmptrapd /var/log/messages
        grep snmptrapd /var/log/syslog

        Feb 27 11:04:03 bink snmptrapd[84697]: 2022-02-27 11:04:03 localhost [UDP: [127.0.0.1]:40290->[127.0.0.1]:162]:#012.1.3.6.1.6.3.1.1.4.1.0 = OID: .1.3.6.1.6.3.1.1.5.3#011.1.3.6.1.2.1.2.2.1.1 = INTEGER: 2#011.1.3.6.1.2.1.2.2.1.7 = INTEGER: up(1)#011.1.3.6.1.2.1.2.2.1.8 = INTEGER: down(2)

    Note:  If you see the error 'SELinux is preventing /usr/sbin/snmptrapd from write access on the directory snmptt', then SELinux needs to be configured to allow snmptrapd to write to the spool folder.

2.  Check the snmptt.log file for the trap:

        tail /var/log/snmptt/snmptt.log

        Sun Feb 27 11:04:03 2022 .1.3.6.1.6.3.1.1.5.3 Normal "Status Events" 127.0.0.1 - Link down on interface 2.  Admin state: 1.  Operational state: 2

2.  Check syslog for the trap from **snmptt**.

        grep 'snmptt\[' /var/log/messages
        grep 'snmptt\[' /var/log/syslog

        Feb 27 11:04:07 server1 snmptt[83096]: .1.3.6.1.6.3.1.1.5.3 Normal "Status Events" 127.0.0.1 - Link down on interface 2.  Admin state: 1.  Operational state: 2


**Troubleshooting:**

1.  Enable debug mode by defining both **DEBUGGING = 0** and **DEBUGGING_FILE = /var/log/snmptt/snmptt.debug** in **/etc/snmptt/snmptt.ini** and restart **snmptt**.  If the file is not created, check syslog for errors.  Either the DEBUGGING_FILE path is incorrect or there is a permissions error creating the debug log file.
2.  Make sure permissions have been set for the various folders and files.
3.  SELinux may interfere with **snmptrapd** and **snmptt**.  Disable or reconfigure at your own discretion.
4.  Test running **snmptt** and the handlers as explained above to make sure there are no missing Perl modules.




## <a name="Installation-Windows"></a>Installation - Windows

The Net-SNMP trap receiver does not currently support embedded Perl, so only the standard trap handler can be used with Windows.

1. Create the directory c:\\snmp and copy **snmptt** and **snmptthandler** to it.

        md c:\snmp
        copy snmptt c:\snmpt\
        copy snmptthandler c:\snmp\

2. Copy **snmptt.ini-nt** to **%SystemRoot%\\snmptt.ini** (c:\\windows\\snmptt.ini) and edit the options inside the file.

        cp snmptt.ini-nt %SystemRoot%\snmptt.ini

3. Either copy examples\\snmptt.conf.generic to c:\\snmp\\snmptt.conf (renaming the file during the copy) or create the file using notepad.

        copy examples\snmptt.conf.generic c:\snmp\snmptt.conf  
        notepad c:\snmp\snmptt.conf  

4. Create the log folder **c:\\snmp\\log\\**.

        md c:\snmp\log

5. For **SNMPTT standlone mode**:

    1. Modify (or create) the Net-SNMP snmptrapd.conf file by adding the following line:

            traphandle default perl c:\snmp\snmptt

        Note:   It is possible to configure snmptrapd to execute snmptt based on the specific trap received, but using the default option is preferred

6. For **SNMPTT daemon mode**:

    1. Modify (or create) the Net-SNMP snmptrapd.conf file by adding the following line:

            traphandle default perl c:\snmp\snmptthandler

7. Create the spool folder **c:\\snmptt\\spool\\**.

        md c:\snmptt\spool

8. Launch snmptt using:

        snmptt --daemon

6. Start SNMPTRAPD using the command line:  SNMPTRAPD -On:

        snmptrapd -On

    Note:  **The -On option is recommended**.  This will make snmptrapd pass OIDs in numeric form and prevent SNMPTT from having to translate the symbolic name to numerical form.  If the **Net-SNMP Perl module** is not installed, then you MUST use the **-On** switch.  Depending on the version of Net-SNMP, some symbolic names may not translate correctly.  See the FAQ for more info.

    As an alternative, you can edit the Net-SNMP configuration file **/etc/snmp/snmp.conf** to include the line: **printNumericOids 1. ** This setting will take effect no matter what is used on the command line.

10. Follow the steps in the section [Securing SNMPTT](#SecuringSNMPTT) to ensure SNMPTT has been configured securely.
  

**Windows EventLog:**

If you have enabled Windows Event Log support, then you must install an Event Message File to prevent "Event Message Not Found" messages from appearing in the Event Log.  Microsoft Knowledge Base article KB166902 contains information on this error.

The Event Message File is aincluded with SNMPTT is a pre-compiled binary DLL.  To compile the DLL yourself, see 'Compiling' below.

To install the DLL:

1.  Backup your system

2.  Make sure Event Viewer is not open

3.  Copy **bin\\snmptt-eventlog.dll** to **%windir%\\system32**
    
        copy bin\snmptt-eventlog.dll %windir%\system32\

4.  Launch the Registry Editor

5.  Go to '**HKEY\_LOCAL\_MACHINE\\System\\CurrentControlSet\\Services\\Eventlog\\Application**'

6.  Create a new subkey (under Application) called **SNMPTT**

7.  Inside of the **SNMPTT** key, create a new String Value called **EventMessageFile**.  Give it a value of **%windir%\\system32\\snmptt-eventlog.dll.**

8.  Inside of the **SNMPTT** key, create a new DWORD Value called **TypesSupported**.  Give it a value of **7**.

To un-install the DLL:

1.  Backup your system

2.  Make sure Event Viewer is not open

3.  Launch the Registry Editor

4.  Go to '**HKEY\_LOCAL\_MACHINE\\System\\CurrentControlSet\\Services\\Eventlog\\Application**'

5.  Delete the key **SNMPTT**

6.  Delete the file **%windir%\\system32\\snmptt-eventlog.dll**

        del %windir%\system32\snmptt-eventlog.dll

Compiling snmptt-eventlog.dll (MS Visual C++ required)

1.  If your environment is not already set up for command line compilation, locate **vcvars32.bat**, start a command prompt, and execute it (vcvars32.bat).

2.  cd into the directory where snmptt-eventlog.mc is located (included with SNMPTT) and execute the following commands:

        mc snmptt-eventlog.mc

        rc /r snmptt-eventlog.rc

        link /nodefaultlib /INCREMENTAL:NO /release /nologo -base:0x60000000 -machine:i386 -dll -noentry -out:snmptt-eventlog.dll snmptt-eventlog.res

6.  Install the DLL as described above

**Windows Service:**

To configure SNMPTT as a service under Windows, follow these steps.  More information can be obtained from the Windows Resource Kit.

1.  Install the Windows resource kit

2. Copy the **srvany.exe** program to **c:\\windows\\system32** from **c:\\Program Files\\Resource Kit \***

        copy srvany.exe c:\%windir%\system32\

3. Install the SNMPTT service using:

        instsrv SNMPTT c:\windows\\system32\srvany.exe

4. Configure the service:

    1. Launch **REGEDIT**

    2. Go to **HKLM\\SYSTEM\\CurrentControlSet\\SNMPTT**

    3. Create a key called: **Parameters**

    4. Inside of Parameters, create a Sting Value (REG\_SZ) called **Application** with the value of: **c:\\perl\\bin\\perl.exe**

    5. Inside of Parameters, create a Sting Value (REG\_SZ) called **AppParameters** with the value of: **c:\\snmp\\snmptt --daemon**

5. Start the service from the control panel, or from a command prompt, type:

        net start snmptt

6. Note:  To remove the service, type:

        instsrv SNMPTT remove

# <a name="SecuringSNMPTT"></a>Securing SNMPTT

As with most software, SNMPTT should be run without root or administrator privileges.  Running with a non privileged account can help restrict what actions can occur when using features such as EXEC and REGEX.  
  
For Linux and Unix, if you start SNMPTT as root, a user called 'snmptt' should be created and the **snmptt.ini** option **daemon\_uid** should be set to the numerical user id (eg: 500) or textual user id (snmptt). **Only define daemon\_uid if starting snmptt using root.**  
  
If you start SNMPTT as a non-root user, then **daemon\_uid** is not required (and will probably not work).  
  
When using **daemon\_uid** in daemon mode, there will be two SNMPTT processes. The first will run as root and will be responsible for creating the .pid file, and for cleaning up the .pid file on exit. The second process will run as the user defined by **daemon\_uid**. If the system syslog (**syslog\_system\_enable**) is enabled, a message will be logged stating the user id has been changed. All processing from that point on will be as the new user id. This can be verified by looking the snmptt processes using **ps**.
  
For Windows, a local or domain user account called 'snmptt' should be created.  If running as a Windows service, the service should be configured to use the snmptt user account.  Otherwise the system should be logged in locally with the snmptt account before launching SNMPTT in daemon mode.  
  
The script **snmptthandler** which is called from Net-SNMP's snmptrapd will be executed in the same security context as **snmptrapd**.
  
The SNMPTT user should be configured with the following permissions:

*   read / delete access to spool directory to be able to read new traps, and delete processed traps
*   read access to configuration files (snmptt.ini and all snmptt.conf files)
*   write access to log folder /var/log/snmptt/ or c:\\snmp\\log\\.
*   any other permissions required for EXEC statements to execute

If **snmptrapd** is run as a non root / administrator, it should be configured with the following permissions below.  Note:  SELinux may prevent writing to the folder.

*   write access to spool directory

Grant access and secure the spool folder with:

        chown -R snmptt.snmptt /var/spool/snmptt
        chmod -R 750 /var/spool/snmptt

Grant access and secure the log folder with:

        chown -R snmptt.snmptt /var/log/snmptt
        chmod -R 750 /var/log/snmptt

If you are using **/etc/snmp** to store the SNMPTT configuration files, secure the folder with:

        chown -R root.root /etc/snmp
        chmod 755 /etc/snmp
        chown snmptt.snmptt /etc/snmp/snmptt*
        chmod 660 /etc/snmp/snmptt*

If you are using **/etc/snmptt** to store the SNMPTT configuration files, secure folder with:

        chown -R snmptt.snmptt /etc/snmptt
        chmod 750 /etc/snmptt

Note:  Starting with v1.5, you can use **/etc/snmptt/** instead of **/etc/snmp/** for your **snmptt.ini** file:

Note:  It is recommended that only the user running snmptrapd and the snmptt user be given permission to the spool folder.  This will prevent other users from placing files into the spool folder such as non-trap related files, or the !reload file which causes SNMPTT to reload.

# <a name="Configuration-Options"></a>Configuration Options - snmptt.ini

As mentioned throughout this document, configuration options are set by editing the **snmptt.ini** file.

For Linux / Unix, the following directories are searched to locate **snmptt.ini**:

> **/etc/snmptt/**  
> **/etc/snmp/**  
> **/etc/**  
> **/usr/local/etc/snmp/**  
> **/usr/local/etc/**

Note:  **/etc/snmptt/** is new for v1.5.

For Windows, the file should be in **%SystemRoot%\\**.  For example, **c:\\windows**.

If an alternative location is desired, the **snmptt.ini** file path can be set on the command line using the **\-ini=** parameter.  See [Command Line Arguments](#Command-line-arguments).

A sample **snmptt.ini** is provided in this package.  See the [Installation](#Installation) section.

This file does not document all configuration options available in **snmptt.ini**.  Please view the **snmptt.ini** for a complete description of all options. 

Note:  The default snmptt.ini enables logging to snmptt.log and also syslog for both trap messages and SNMPTT system messages.  Change the following settings if required:  **log\_enable**, **syslog\_enable** and **syslog\_system\_enable**.

# <a name="Modes-of-Operation"></a>Modes of Operation

SNMPTT can be run in two modes:  daemon mode and standalone mode.  Daemon mode is recommended.

## <a name="Modes-of-Operation-Daemon"></a>Daemon mode

When SNMPTT is run in daemon mode, the snmptrapd.conf file would contain a traphandle statement such as:

    traphandle default /usr/sbin/snmptthandler

or when using the embedded handler:

    perl do "/usr/sbin/snmptthandler-embedded"

When a trap is received by SNMPTRAPD, the trap is passed to the SNMPTT handler script which performs the following tasks:

*   reads trap passed from snmptrapd
*   writes the trap in a new unique file to a spool directory such as /var/spool/snmptt
*   quits

SNMPTT running in daemon mode performs the following tasks:

*   loads configuration file(s) containing trap definitions at startup
*   reads traps passed from spool directory
*   searches traps for a match
*   logs, executes EXEC statement etc
*   sleeps for 5 seconds (configurable)
*   loops back up to 'reads traps passed from spool directory'

Using SNMPTTHANDLER and SNMPTT in daemon mode, a large number of traps per minute would be handled easily.

Running SNMPTT with the \--daemon command line option or setting the **mode** variable in the **snmptt.ini** file to **daemon** will cause SNMPTT to run in daemon mode.

By setting the snmptt.ini variable **use\_trap\_time** to **1** (default), the date and time used for logging will be the date and time passed inside the trap spool file.  If **use\_trap\_time** is set to **0**, the date and time that the trap was _processed_ by SNMPTT is used.  Setting **use\_trap\_time** to **0** can result in inaccurate time stamps in log files due to the length of time SNMPTT sleeps between spool directory polling.

Note:  When running on a **non** Windows platform, SNMPTT will fork to the background and create a pid file in /var/run/snmptt.pid if **daemon\_fork** is set to 1.  If the user is not able to create the /var/run/snmptt.pid file, it will attempt to create one in the current working directory.

Sending the HUP signal to SNMPTT when running as a daemon will cause it to reload the configuration file including the .ini file, snmptt.conf files listed in the .ini file and any NODES files if dynamic\_nodes is disabled.  A reload can also be forced by adding a file to the spool directory called !reload.  The filename is not case sensitive.  If this file is detected, it will flag a reload to occur and will delete the file.  This would be the only way to cause a reload when using Windows as Windows does not support signals.

Statistical logging of total traps received, total traps translated and total unknown traps can be enabled by setting the **statistics\_interval** snmptt.ini variable to a value greater than 0.  At each interval (defined in seconds), the statistics will be logged to syslog or the event log.

Sending the USR1 signal will also cause the statistical information for total traps received, total traps translated and total unknown traps to be logged.  This could be used for example if you want to log statistics at a set time each day using a task scheduler instead of using the interval time defined in the snmptt.ini variable **statistics\_interval**.  A statistics dump can also be forced by adding a file to the spool directory called !statistics which is processed similar to the !reload file.  

## <a name="Modes-of-Operation-Standalone"></a>Standalone mode

To use SNMPTT in standalone mode, the snmptrapd.conf file would contain a traphandle statement such as:

        traphandle default /usr/sbin/snmptt

When a trap is received by snmptrapd, the trap is passed to the **/usr/sbin/snmptt** script.  SNMPTT performs the following tasks:

*   reads trap passed from snmptrapd
*   loads configuration file(s) containing trap definitions
*   searches traps for a match
*   logs, executes EXEC statements etc
*   snmptt exits

With a 450 Mhz PIII (way back in 1998) and a 9000 line snmptt.conf containing 566 unique traps (EVENTs), it took under a second to process the trap including logging and executing the qpage program.  The larger the snmptt.conf file is, the longer it will take to process.  If there are a large number of traps being received, daemon mode should be used.  If it takes 1 second to process one trap, then obviously you shouldn't try to process more than one trap per second.  Daemon mode should be used instead.

Running SNMPTT without the **\--daemon** command line option will result standalone mode unless the **mode** variable in the **snmptt.ini** file is set to **daemon**.  For standalone mode, the **mode** variable in the **snmptt.ini** file should be set **standalone**.

Note: Enabling the Net-SNMP Perl module will greatly increase the startup time of SNMPTT.  Daemon mode is recommended.


# <a name="Command-line-arguments"></a>Command line arguments

The following command line arguments are supported:

    Usage:  
        snmptt [<options>]  
    Options:  
        --daemon                Start in daemon mode  
        --debug=n               Set debug level (1 or 2)  
        --debugfile=filename    Set debug output file  
        --dump                  Dump (display) defined traps  
        --help                  Display this message  
        --ini=filename          Specify path to snmptt.ini file  
        --version               Display author and version information  
        --time                  Use to see how long it takes to load and  
                                process trap file (eg: time snmptt --time)  

# <a name="Logging"></a>Logging
 
## <a name="LoggingStandard"></a>Logging - Standard

Translated traps can be sent to standard output and to a log file.  The output format is:

> **_date trap-oid severity category hostname_ - _translated-trap_**

To configure standard output or regular logging, edit the **snmptt.ini** file and modify the following variables:

    stdout_enable
    log_enable
    log_file
    log_format

The output format can be changed from the above default by modifying the **log_format** setting.  See snmptt.ini for details.

## <a name="LoggingUnknown"></a>Logging - Unknown traps

Logging of unrecognized traps is possible.  This would be used mainly for troubleshooting purposes.

To configure unknown trap logging, edit the snmptt.ini file and modify the following variables:

    enable_unknown_trap_log
    unknown_trap_log_file  

Unknown traps can be logged to a SQL table as described in the [Database](#LoggingDatabase) section.  

## <a name="LoggingSyslog"></a>Logging - Syslog

Translated traps can be sent to syslog.  The format of the entries will be similar to above without the date (as syslog adds the date):

> **_trap-oid severity category hostname_ - _translated-trap_**

Syslog entries normally start with: **date hostname snmptt\[pid\]:** 
  
To configure syslog, edit the snmptt ini file and modify the following variables:

    syslog_enable
    syslog_facility
    syslog_level
    syslog_module
    syslog_remote_dest *
    syslog_remote_port *
    syslog_remote_proto *
    syslog_rfc_format *
    syslog_app *
    syslog_format

(\*) Only applicable when using **syslog_module** = 1

When using the default **syslog_module** setting of 0, syslog messages are logged to the local system using Unix sockets following the RFC3164 standard.

To enable RFC5424 or remote syslog server support, set **syslog_module** to 1 and define the (*) settings.  Be sure to enable UDP or TCP syslog reception in your syslog server.  See snmptt.ini for details on each setting.

SNMPTT system errors and messages such as startup, shutdown, trap statistics etc can be sent to syslog by editing the snmptt.ini file and modifying the following variables:

    syslog_system_enable
    syslog_system_facility
    syslog_system_level

Syslog system entries normally start with: **date hostname snmptt-sys\[pid\]:**
  
The following errors are logged:

> SNMPTT (version) started **(\*)**  
> Unable to enter spool dir _x_ **(\*)**  
> Unable to open spool dir _x_ **(\*)**  
> Unable to read spool dir _x_ **(\*)**  
> Could not open trap file _x_ **(\*)**  
> Unable to delete trap file _x_ from spool dir **(\*)**  
> Unable to delete !reload file spool dir **(\*)  
> **Unable to delete !statistics file spool dir **(\*)**  
> Reloading configuration file(s) **(\*)**  
> SNMPTT (version) shutdown **(\*)**  
> Loading _snmpttconfigfile_ **(\*)**  
> Could not open configuration file: _snmpttconfigfile_**(\*)**  
> Finished loading _x_ lines from _snmpttconfigfile_ **(\*)**  
> MySQL error: Unable to connect to database  
> SQL error: Unable to connect to DSN  
> Can not open log file _logfile_  
> MySQL error: Unable to perform PREPARE  
> MySQL error: Unable to perform INSERT INTO (EXECUTE)  
> DBI DBD::ODBC error: Unable to perform INSERT INTO  
> Win32::ODBC error: Unable to perform INSERT INTO  
> PostgreSQL error: Unable to connect to database  
> PostgreSQL error: Unable to perform PREPARE  
> PostgreSQL error: Unable to perform INSERT INTO (EXECUTE)  
> 
> **\* (daemon mode only)**

## <a name="LoggingEventLog"></a>Logging - Windows EventLog

When running under Windows, translated traps can be sent to the EventLog.  All traps are logged under EventID 2 under the source SNMPTT.  The format of the entries will be similar to above without the date (as the Event Log logs the date):

> **trap-oid severity category hostname translated-trap**

To configure eventlog support, edit the snmptt ini file and modify the following variables:

    eventlog_enable
    eventlog_type

SNMPTT system errors can be sent to the Event Log by editing the snmptt.ini file and modifying the following variables:

    eventlog_system_enable

The following errors are logged.  Note that each error contains a unique EventID:  

> EventID 0: SNMPTT (version) started **(\*)**  
> EventID 3: Unable to enter spool dir _x_ **(\*)**  
> EventID 4: Unable to open spool dir _x_ **(\*)**  
> EventID 5: Unable to read spool dir _x_ **(\*)**  
> EventID 6: Could not open trap file _x_ **(\*)**  
> EventID 7: Unable to delete trap file _x_ from spool dir **(\*)**  
> EventID 20: Unable to delete !reload file spool dir **(\*)**  
> EventID 21: Unable to delete !statistics file spool dir **(\*)**  
> EventID 8: Reloading configuration file(s) **(\*)**  
> EventID 1: SNMPTT (version) shutdown **(\*)**  
> EventID 9: Loading _snmpttconfigfile_ **(\*)**  
> EventID 10: Could not open configuration file: _snmpttconfigfile_**(\*)**  
> EventID 11: Finished loading _x_ lines from _snmpttconfigfile_**(\*)**
> EventID 12: MySQL error: Unable to connect to database  
> EventID 13: SQL error: Unable to connect to DSN _dsn_  
> EventID 14: Can not open log file _logfile_  
> EventID 23: MySQL error: Unable to perform PREPARE  
> EventID 15: MySQL error: Unable to perform INSERT INTO (EXECUTE)  
> EventID 16: DBI DBD::ODBC error: Unable to perform INSERT INTO  
> EventID 17: Win32::ODBC error: Unable to perform INSERT INTO  
> EventID 18: PostgreSQL error: Unable to connect to database  
> EventID 22: PostgreSQL error: Unable to perform PREPARE  
> EventID 19: PostgreSQL error: Unable to perform INSERT INTO (EXECUTE)  
> 
> **\* (daemon mode only)**

Note:

> To prevent "Event Message Not Found" messages in the Event Viewer, an Event Message File must be used.  For information on installing the message file, see the [Installation section for Windows](#Installation%20-%20Windows).

## <a name="LoggingDatabase"></a>Logging - Database

Translated and unrecognized traps can be sent to a database.  MySQL (tested under Linux), PostgreSQL (tested under Linux) and ODBC (tested under Windows) can be used.

After configuring database logging below, you can also enable unknown trap logging by editing the **snmptt.ini** file and modifying the following variables:

    enable_unknown_trap_log
    db_unknown_trap_format

## <a name="LoggingDatabase-MySQL"></a>DBD::MySQL

To configure SNMPTT for MySQL, modify the following variables in the snmptt.ini file.

    mysql_dbi_enable
    mysql_dbi_host
    mysql_dbi_port
    mysql_dbi_database
    mysql_dbi_table
    mysql_dbi_table_unknown
    mysql_dbi_username
    mysql_dbi_password

Note:  Sample values are defined in the default ini file.  Defining mysql\_dbi\_table\_unknown is optional.

The following MySQL script will create the database and table. Permissions etc should also be defined. Run '**mysql**' as root and enter:

    CREATE DATABASE snmptt;   
    USE snmptt; 
    
    DROP TABLE snmptt;   
    CREATE TABLE snmptt (   
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,   
    eventname VARCHAR(50),   
    eventid VARCHAR(50),   
    trapoid VARCHAR(100),  
    enterprise VARCHAR(100),   
    community VARCHAR(20),   
    hostname VARCHAR(100),   
    agentip  VARCHAR(16),   
    category VARCHAR(20),   
    severity VARCHAR(20),   
    uptime  VARCHAR(20),   
    traptime VARCHAR(30),   
    formatline VARCHAR(255)); 

Note: To store the traptime as a real date/time (**DATETIME** data type), change 'traptime VARCHAR(30),' to 'traptime DATETIME,' and set **date\_time\_format\_sql** in **snmptt.ini** to **%Y-%m-%d %H:%M:%S**.

Note: If you do not want the auto-incrementing id column, remove the 'id INT...' line.

If logging of unknown traps to a SQL table is required, create the **snmptt\_unknown** table using:

    USE snmptt; 
    
    DROP TABLE snmptt_unknown;   
    CREATE TABLE snmptt_unknown (   
    trapoid VARCHAR(100),  
    enterprise VARCHAR(100),   
    community VARCHAR(20),   
    hostname VARCHAR(100),   
    agentip  VARCHAR(16),   
    uptime  VARCHAR(20),   
    traptime VARCHAR(30),   
    formatline VARCHAR(255)); 

Note: To store the traptime as a real date/time (**DATETIME** data type), change 'traptime VARCHAR(30),' to 'traptime DATETIME,' and set **date\_time\_format\_sql** in **snmptt.ini** to **%Y-%m-%d %H:%M:%S**.

If logging of statistics to a SQL table is required, create the **snmptt\_statistics** table using:

    USE snmptt;
    
    DROP TABLE snmptt_statistics;  
    CREATE TABLE snmptt_statistics (  
    stat_time VARCHAR(30),  
    total_received BIGINT,  
    total_translated BIGINT,  
    total_ignored BIGINT,  
    total_skipped BIGINT,  
    total_unknown BIGINT);

Note: Only include **total_skipped** if **unknown_trap_nodes_match_mode** is set to **1**.

Note: To store the stat\_time as a real date/time (**DATETIME** data type), change 'stat\_time VARCHAR(30),' to 'stat\_time DATETIME,' and set **stat\_time\_format\_sql** in **snmptt.ini** to **%Y-%m-%d %H:%M:%S**.

Note: The variable lengths I have chosen above should be sufficient, but they may need to be increased depending on your environment.

To add a user account called '**snmptt**' with a password of '**mytrap**' for use by SNMPTT, use the following SQL statement:

    GRANT ALL PRIVILEGES ON \*.\* TO 'snmptt'@'localhost' IDENTIFIED BY 'mytrap';

## <a name="LoggingDatabase-PostgreSQL"></a>DBD::PgPP (PostgreSQL)

To configure SNMPTT for PostgreSQL, modify the following variables in the snmptt.ini file.

    postgresql_dbi_enable
    postgresql_dbi_module
    postgresql_dbi_hostport_enable
    postgresql_dbi_host
    postgresql_dbi_port
    postgresql_dbi_database
    postgresql_dbi_table
    postgresql_dbi_table_unknown
    postgresql_dbi_username
    postgresql_dbi_password

Note: Sample values are defined in the default ini file. Defining **postgresql\_dbi\_table\_unknown** is optional.

The following shell / PostgreSQL commands will drop the existing database if it exists and then delete the existing snmptt user. It will then create a new snmptt database, a new snmptt user (prompting for a password) and then create the table. Run these commands as root.

    su - postgres
    dropdb snmptt  
    dropuser snmptt  

    createuser -P snmptt  
    createdb -O snmptt snmptt  
    psql snmptt

    DROP TABLE snmptt;  
    CREATE TABLE snmptt (  
    eventname VARCHAR(50),  
    eventid VARCHAR(50),  
    trapoid VARCHAR(100),  
    enterprise VARCHAR(100),  
    community VARCHAR(20),  
    hostname VARCHAR(100),  
    agentip  VARCHAR(16),  
    category VARCHAR(20),  
    severity VARCHAR(20),  
    uptime  VARCHAR(20),  
    traptime VARCHAR(30),  
    formatline VARCHAR(255));

    GRANT ALL ON snmptt TO snmptt;  
    \q

Note: To store the traptime as a real date/time (**timestamp** data type), change 'traptime VARCHAR(30),' to 'traptime timestamp,' and set **date\_time\_format\_sql** in **snmptt.ini** to **%Y-%m-%d %H:%M:%S**.

If logging of unknown traps to a SQL table is required, create the snmptt\_unknown table using:  

    su - postgres  
    psql snmptt  

    DROP TABLE snmptt_unknown;
    CREATE TABLE snmptt_unknown (
    trapoid VARCHAR(100),  
    enterprise VARCHAR(100),  
    community VARCHAR(20),  
    hostname VARCHAR(100),  
    agentip  VARCHAR(16),  
    uptime  VARCHAR(20),  
    traptime VARCHAR(30),  
    formatline VARCHAR(255));  

    GRANT ALL ON snmptt_unknown TO snmptt;  
    \q

Note: To store the traptime as a real date/time (**timestamp** data type), change 'traptime VARCHAR(30),' to 'traptime timestamp,' and set **date\_time\_format\_sql** in **snmptt.ini** to **%Y-%m-%d %H:%M:%S**.

If logging of statistics to a SQL table is required, create the snmptt\_statistics table using:  

    su - postgres  
    psql snmptt  


    DROP TABLE snmptt_statistics;  
    CREATE TABLE snmptt_statistics (  
    stat_time VARCHAR(30),  
    total_received BIGINT,  
    total_translated BIGINT,  
    total_ignored BIGINT,  
    total_skipped BIGINT,  
    total_unknown BIGINT);  

    GRANT ALL ON snmptt_statistics TO snmptt;  
    \q

Note: Only include **total_skipped** if **unknown_trap_nodes_match_mode** is set to **1**.

Note: To store the stat\_time as a real date/time (**timestamp** data type), change 'stat\_time VARCHAR(30),' to 'stat\_time timestamp,' and set **stat\_time\_format\_sql** in **snmptt.ini** to **%Y-%m-%d %H:%M:%S**.

The variable lengths I have chosen above should be sufficient, but they may need to be increased depending on your environment.  
  

## <a name="LoggingDatabase-ODBC"></a>DBD::ODBC

SNMPTT can access ODBC data sources using either the DBD::ODBC module on Linux and Windows, or the WIN32::ODBC module on Windows.

To configure SNMPTT for ODBC access using the module DBD::ODBC, modify the following variables in the snmptt script.

    dbd_odbc_enable = 1;
    dbd_odbc_dsn = 'snmptt';
    dbd_odbc_table = 'snmptt';
    dbd_odbc_table_unknown = 'snmptt';
    dbd_odbc_username = 'snmptt';
    dbd_odbc_password = 'password';

Note:   

SNMPTT does not create the DSN connection. You must define the DSN outside of SNMPTT. See 'Data Sources (ODBC)' in Windows help for information on creating a DSN connection.  
  
Defining **dbd\_odbc**\_table\_unknown is optional.  
  
Sample values are defined in the default ini file.

  

The following MS SQL Server / Access script can create the table inside an existing database.  Permissions etc should also be defined.

    CREATE TABLE snmptt (
    eventname character(50) NULL,
    eventid  character(50) NULL,
    trapoid character(100) NULL,
    enterprise character(100) NULL,
    community character(20) NULL,
    hostname character(100) NULL,
    agentip  character(16) NULL,
    category character(20) NULL,
    severity character(20) NULL,
    uptime  character(20) NULL,
    traptime character(30) NULL,
    formatline character(255) NULL);

Note: To store the traptime as a real date/time, change 'traptime character(30),' to the date/time data type supported by the database and and set **date\_time\_format\_sql** in **snmptt.ini** to a compatible format. For example: **%Y-%m-%d %H:%M:%S**.

If logging of unknown traps to a SQL table is required, create the snmptt\_unknown table using:  

    CREATE TABLE snmptt_unknown (
    trapoid character(100) NULL,
    enterprise character(100) NULL,
    community character(20) NULL,
    hostname character(100) NULL,
    agentip  character(16) NULL,
    uptime  character(20) NULL,
    traptime character(30) NULL,
    formatline character(255) NULL);

Note: To store the traptime as a real date/time, change 'traptime character(30),' to the date/time data type supported by the database and and set **date\_time\_format\_sql** in **snmptt.ini** to a compatible format. For example: **%Y-%m-%d %H:%M:%S**.

If logging of statistics to a SQL table is required, create the snmptt\_statistics table using:  

    CREATE TABLE snmptt_statistics (  
    stat_time character(30) NULL,  
    total_received BIGINT NULL,  
    total_translated BIGINT NULL,  
    total_ignored BIGINT NULL,  
    total_skipped BIGINT NULL,  
    total_unknown BIGINT NULL);

Note: Only include **total_skipped** if **unknown_trap_nodes_match_mode** is set to **1**.

Note: To store the stat\_time as a real date/time, change 'stat\_time character(30),' to the date/time data type supported by the database and and set **stat\_time\_format\_sql** in **snmptt.ini** to a compatible format. For example: **%Y-%m-%d %H:%M:%S**.

All variables are inserted into the database using '**INSERT INTO**' as text including the date and time.  The variable lengths I have chosen above should be sufficient, but they may need to be increased depending on your environment.  
 
## <a name="LoggingDatabase-Windows_ODBC"></a>Win32::ODBC

SNMPTT can access ODBC data sources using either the DBD::ODBC module on Linux and Windows, or the WIN32::ODBC module on Windows.

To configure SNMPTT for MS SQL via ODBC on Windows, modify the following variables in the snmptt script.

    sql_win32_odbc_enable = 1;  
    sql_win32_odbc_dsn = 'snmptt';  
    sql_win32_odbc_table = 'snmptt';  
    sql_win32_odbc_username = 'snmptt';  
    sql_win32_odbc_password = 'password';  

Note:   

SNMPTT does not create the DSN connection. You must define the DSN outside of SNMPTT. See 'Data Sources (ODBC)' in Windows help for information on creating a DSN connection.  
  
Defining **sql\_win32\_odbc**\_table\_unknown is optional.  
  
Sample values are defined in the default ini file.

The following MS SQL Server script can create the table inside an existing database.  Permissions etc should also be defined.

    CREATE TABLE snmptt (
    eventname character(50) NULL,
    eventid  character(50) NULL,
    trapoid character(50) NULL,
    enterprise character(50) NULL,
    community character(20) NULL,
    hostname character(100) NULL,
    agentip  character(16) NULL,
    category character(20) NULL,
    severity character(20) NULL,
    uptime  character(20) NULL,
    traptime character(30) NULL,
    formatline character(255) NULL);

Note: To store the traptime as a real date/time, change 'traptime character(30),' to the date/time data type supported by the database and and set **date\_time\_format\_sql** in **snmptt.ini** to a compatible format. For example: **%Y-%m-%d %H:%M:%S**.

If logging of unknown traps to a SQL table is required, create the snmptt\_unknown table using:  

    CREATE TABLE snmptt_unknown (
    trapoid character(50) NULL,
    enterprise character(50) NULL,
    community character(20) NULL,
    hostname character(100) NULL,
    agentip  character(16) NULL,
    uptime  character(20) NULL,
    traptime character(30) NULL,
    formatline character(255) NULL);

Note: To store the traptime as a real date/time, change 'traptime character(30),' to the date/time data type supported by the database and and set **date\_time\_format\_sql** in **snmptt.ini** to a compatible format. For example: **%Y-%m-%d %H:%M:%S**.

If logging of statistics to a SQL table is required, create the snmptt\_statistics table using:  

    CREATE TABLE snmptt_statistics (  
    stat_time character(30) NULL,  
    total_received BIGINT NULL,  
    total_translated BIGINT NULL,  
    total_ignored BIGINT NULL,  
    total_skipped BIGINT NULL,  
    total_unknown BIGINT NULL);

Note: Only include **total_skipped** if **unknown_trap_nodes_match_mode** is set to **1**.

Note: To store the stat\_time as a real date/time, change 'stat\_time character(30),' to the date/time data type supported by the database and and set **stat\_time\_format\_sql** in **snmptt.ini** to a compatible format. For example: **%Y-%m-%d %H:%M:%S**.

All variables are inserted into the database using '**INSERT INTO**' as text including the date and time.  The variable lengths I have chosen above should be sufficient, but they may need to be increased depending on your environment.  
   

# <a name="Executing-an-external-program"></a>Executing an external program


An external program can be launched when a trap is received.  The command line is defined in the **snmptt.conf** configuration file.  For example, to send a page using QPAGE ([http://www.qpage.org](http://www.qpage.org)), the following command line could be used:

    qpage -f TRAP notifygroup1 "$r $x $X Compaq Drive Array Spare Drive on controller $4, bus $5, bay $6 status is $3."

$r is translated to the hostname, $x is the current date, and $X is the current time (described in detail below).

To enable or disable the execution of EXEC definitions, edit the snmptt.ini file and modify the following variable:

    exec_enable

It is also possible to launch an external program when an unknown trap is received. This can be enabled by defining **unknown\_trap\_exec** in **snmptt.ini**. Passed to the command will be all standard and enterprise variables, similar to **unknown\_trap\_log\_file** but without the newlines.

# <a name="SNMPTT.CONF-Configuration-file-format"></a>SNMPTT.CONF Configuration file format

The configuration file (usually /etc/snmp/snmptt.conf or c:\\snmp\\snmptt.conf) contains a list of all the defined traps.

If your snmptt.conf file is getting rather large and you would like to divide it up into many smaller files, then do the following:

* create additional snmptt.conf files  
* add the file names to the **snmptt\_conf\_files** section in the snmptt.ini file.

For example:

    snmptt_conf_files = <<END  
    /etc/snmp/snmptt.conf.generic  
    /etc/snmp/snmptt.conf.compaq  
    /etc/snmp/snmptt.conf.cisco  
    /etc/snmp/snmptt.conf.hp  
    /etc/snmp/snmptt.conf.3com  
    END

The syntax of the snmptt.conf file  is:

> **EVENT** event\_name event\_OID "category" severity
> 
> **FORMAT** format\_string
> 
> \[**EXEC** command\_string\]
>
> \[**PREEXEC** command\_string\]
> 
> \[**NODES** sources\_list\]
> 
> \[**MATCH** \[MODE=\[or | and\]\] | \[$n:\[!\]\[(    ) | n | n-n | > n | < n | x.x.x.x | x.x.x.x-x.x.x.x | x.x.x.x/x\]\]
> 
> \[**REGEX** (    )(    )\[i\]\[g\]\[e\]\]
> 
> \[**SDESC**\]  
> \[**EDESC**\]
> 
 Note: Lines starting with a # are treated as comments and will be ignored.
 
 Note:  The EVENT and FORMAT line are REQUIRED.  Commands in \[\] are optional.  Do NOT include the \[\]s in the configuration file!

## <a name="SNMPTT.CONF-EVENT"></a>EVENT

 **EVENT** event\_name event\_OID "category" severity
 
 **event\_name:**
 
 > Unique text label (alias) **containing no spaces**.  This would match the name on the TRAP-TYPE or NOTIFICATION-TYPE line in the MIB file when converted using **snmpttconvertmib**.
 
 **event\_OID:**
 
 > Object identifier string in dotted format or symbolic notation **containing no spaces**.
 > 
 > For example, a Compaq (enterprise .1.3.6.1.4.1.232) cpqHoGenericTrap trap (trap 11001) would be written as:
 > 
 > > .1.3.6.1.4.1.232.0.11001
 > 
 > Symbolic names can also be used if the Net-SNMP Perl module is installed and enabled by setting **net\_snmp\_perl\_enable** in the snmptt.ini file.  For example:
 > 
 > > linkDown
 > 
 > > IF-MIB::linkDown
 > 
 > Notes:
 > 
 > * Net-SNMP 5.0.9 and earlier does not support including the module name (eg: IF-MIB::) when translating an OID.  A patch is available for 5.0.8+ that is included in Net-SNMP 5.1.1 and higher. The patch is available from the [Net-SNMP patch page](http://sourceforge.net/tracker/index.php?func=detail&aid=722075&group_id=12694&atid=312694).  If the version of Net-SNMP you are using does not support this feature and the event OID is specified with the module name, the event definition will be ignored.  Also note that UCD-SNMP may not properly convert symbolic names to numeric OIDs which could result in traps not being matched.

 > * SNMP V1 traps are in the format of enterprise ID (.1.3.6.1.4.1.232) followed by a 0, and then followed by the trap number (11001).

 > * There can be multiple entries for the same trap OID in the configuration file.  If **multiple\_event** is enabled in the snmptt.ini, then it will process all matching traps.  If **multiple\_event** is disabled, only the first matching entry will be used.
 > 
 > Wildcards in dotted format notation can  also be used.  For example:
 > 
 > > .1.3.6.1.4.1.232.1.2.\*
 > 
 > Notes:
 > 
 > * Specific trap matches are performed before wildcards so if you have an entry for .1.3.6.1.4.1.232.1.2.5 AND .1.3.6.1.4.1.232.1.2.\*, it will process the .5 trap when received even if the wildcard is defined first.
 
 > * If you want to capture all undefined traps, you can create a wildcard event at the end of your last snmptt.conf file using **.\***.  For example:

     EVENT unknown .* "Status Events" Normal

 > * Wildcard matches are only matched if there are NO exact matches.  This takes into consideration the NODES list.  Therefore, if there is a matching trap, but the NODES list prevents it from being considered a match, the wildcard entry will only be used if there are no other exact matches.
 
 **category:**
 
 * Character string enclosed in double quotes (").  Used when logging output (see above).
 
 * If the category is "**IGNORE**", no action will take place even if the snmptt.conf contains FORMAT and / or EXEC statements.
 
 * If the category is "**LOGONLY**", the trap will be logged as usual, but the EXEC statements will be ignored.

 Note:   If you plan on using an external program such as Nagios, you probably do not want any traps defined with **LOGONLY** as the EXEC line would never be used to submit the passive service check.
 
 **severity:**
 
 * Character string of the severity of the event.  Used in the output when logging.  Example: Minor, Major, Normal, Critical, Warning.  The **snmptt.ini** contains options to match the syslog level or NT Event Log type to the severity level.
 
## <a name="SNMPTT.CONF-FORMAT"></a>FORMAT

 **FORMAT** format\_string
 
 There can be only one FORMAT line per EVENT.
 
 The format string is used to generate the text that will be logged to any of the supported logging methods.
 
 <a name="Variable-substitutions"></a>Variable substitution is performed on this string using the following variables:
 
 > $A - Trap agent host name (**see Note 1**)  
 > $aA - Trap agent IP address  
 > $Be - securityEngineID (snmpEngineID) (**see Note 7**)  
 > $Bu - securityName (snmpCommunitySecurityName) (**see Note 7**)  
 > $BE - contextEngineID (snmpCommunityContextEngineID) (**see Note 7**)  
 > $Bn - contextName (snmpCommunityContextName) (**see Note 7**)  
 > $c - Category  
 > $C - Trap community string  
 > $D - Description text from SNMPTT.CONF or MIB file (**see Note 6**)  
 > $E - Enterprise trap OID in symbolic format  
 > $e  - Enterprise trap OID in number format (.1.3.6.1.4.1._n_)  
 > $j  - Enterprise number (_n_)  
 > $Fa  - alarm (bell) (BEL)  
 > $Ff  - form feed (FF)  
 > $Fn  - newline (LF, NL)  
 > $Fr  - return (CR)  
 > $Ft  - tab (HT, TAB)  
 > $Fz  - Translated FORMAT line (EXEC, log_format and syslog_format only)  
 > $G  - Generic trap number (0 if enterprise trap)  
 > $S  - Specific trap number (0 if generic trap)  
 > $H  - Host name of the system running SNMPTT  
 > $N  - Event name defined in .conf file of matched entry  
 > $i  - Event OID defined in .conf file of matched entry (could be a wildcard OID)  
 > $O - Trap OID in symbolic format (**see Note 4**)  
 > $o - Trap OID in numerical format (**see Note 4**)  
 > $p*n* - PREEXEC result n (1-_n_)  
 > $pu*n* - Unknown trap PREEXEC result n (1-_n_).  See **unknown_trap_preexec** setting in **snmptt.ini**.  
 > $R, $r  - Trap hostname (**see Note 1**)  
 > $aR, $ar - IP address  
 > $s  - Severity  
 > $T  - Uptime:  Time since network entity was initialized  
 > $X  - Time trap was spooled (daemon mode) or current time (standalone mode)  
 > $x  - Date trap was spooled (daemon mode) or current date (standalone mode)  
 > $# - Number of (how many) variable-bindings in the trap  
 > $$  - Print a $  
 > $@ - Number of seconds since the epoch of when the trap was spooled (daemon mode) or the current time (standalone mode)  
 > $_n_  - Expand variable-binding n (1-_n_) (**see Note 2,5**)  
 > $+_n_  - Expand variable-binding n (1-_n_) in the format of _variable name:value_ (**see Note 2,3,5**)  
 > $-_n_  - Expand variable-binding n (1-_n_) in the format of _variable name (variable type):value_ (**see Note 2,3,5**)  
 > $v*n*  - Expand variable name of the variable-binding n (1-_n_)(**see Note 3**)  
 > $\*  - Expand all variable-bindings (**see Note 5**)  
 > $+\*  - Expand all variable-bindings in the format of _variable name:value_ (**see Note 2,3,5**)  
 > $-\*  - Expand all variable-bindings in the format of _variable name (variable type):value_ (**see Note 2,3,5**)  
 
 Example:
 
 > FORMAT NIC switchover to slot $3, port $4 from slot $5, port $6
 
 Notes:
 
 > For the text log file, the output will be formatted as:
 > 
 > > **_date time trap-OID severity category hostname - format_**
 > 
 > For all other log files except MySQL, DBD::ODBC and Win32::ODBC, the output will be formatted as:
 > 
 > > **_trap-OID severity category hostname - format_**
 > 
 > For MySQL, DBD::ODBC and Win32::ODBC, the **formatline** column will contain only the **format** text.
 
 Note (1):
 
 > See the section '[Name Resolution / DNS](#DNS)' for important DNS information.
 
 Note (2):
 
 > If  **translate\_integers** is enabled in the **snmptt.ini** file, SNMPTT will attempt to convert integer values received in traps into text by performing a lookup in the MIB file.  
 > You must have the Net-SNMP Perl module installed for this to work and you must enable support for it by enabling **net\_snmp\_perl\_enable** in the snmptt.ini file.  
 > 
 > For this feature to work, you must ensure Net-SNMP is configured correctly with all the required MIBS.  If the option is enabled, but the value can not be found, the integer value will be used.  If the MIB files are present, but translations do not occur, ensure Net-SNMP is correctly configured to process all the required mibs.  This is configured in the Net-SNMP **/etc/snmp/snmp.conf** file.  Alternatively, you can try setting the **mibs\_enviroment** variable in **snmptt.ini** to **ALL** (no quotes) to force all MIBS to be initialized at SNMPTT startup.
 > 
 > If **translate\_integers** is enabled while using stand-alone mode, it may take longer to process each trap due to the initialization of the MIB files.
 
 Note (3):
 
 > $v*n*, $+*n* and $-*n* variable names and variable type are translated into the text name by performing a lookup in the MIB file.  You must have the Net-SNMP Perl module installed for this to work and you must enable support for it by enabling **net\_snmp\_perl\_enable** in the snmptt.ini file.  If **net\_snmp\_perl\_enable** is not enabled, the $v*n* variable will be replaced with the text 'variable*n*' where *n* is the variable number (1+).
 > 
 > For the name translation to work, you must ensure Net-SNMP is configured correctly with all the required MIBS.  If the option is enabled and the correct name is not returned, ensure Net-SNMP is correctly configured to process all the required mibs.  This is configured in the Net-SNMP **snmp.conf** file.  Alternatively, you can try setting the **mibs\_enviroment** variable in **snmptt.ini** to **ALL** (no quotes) to force all MIBS to be initialized at SNMPTT startup.
 
 Note (4):
 
 > If  **translate\_trap\_oid** is enabled in the **snmptt.ini** file, SNMPTT will attempt to convert the numeric OID of the received trap into symbolic form such as IF-MIB::linkDown.  You must have the Net-SNMP Perl module installed for this to work and you must enable support for it by enabling **net\_snmp\_perl\_enable** in the snmptt.ini file.  If **net\_snmp\_perl\_enable** is not enabled, it will default to using the numeric OID.   

 > Net-SNMP 5.0.9 and earlier does not support including the module name (eg: IF-MIB::) when translating an OID and most of the 5.0.x versions do not properly tranlsate numeric OIDs to long symbolic names.  A patch is available for 5.0.8+ that is included in Net-SNMP 5.1.1 and higher. The patch is available from the [Net-SNMP patch page](http://sourceforge.net/tracker/index.php?func=detail&aid=722075&group_id=12694&atid=312694).

 Note (5):
 
 > If  **translate\_oids** is enabled in the **snmptt.ini** file, SNMPTT will attempt to convert any numeric OIDs found inside the variables passed inside the trap to symbolic form.  You must have the Net-SNMP Perl module installed for this to work and you must enable support for it by enabling **net\_snmp\_perl\_enable** in the snmptt.ini file.  If **net\_snmp\_perl\_enable** is not enabled, it will default to using the numeric OID.   
 >   
 > Net-SNMP 5.0.9 and earlier does not support including the module name (eg: IF-MIB::) when translating an OID and most of the 5.0.x versions do not properly tranlsate numeric OIDs to long symbolic names.  A patch is available for 5.0.8+ that is inlcuded in Net-SNMP 5.1.1 and higher. The patch is available from the [Net-SNMP patch page](http://sourceforge.net/tracker/index.php?func=detail&aid=722075&group_id=12694&atid=312694).
 
 Note (6):
 
 > The **snmptt.ini** **description\_mode** option must be set to either 1 or 2. If set to 1, the description is pulled from the SNMPTT.CONF files. If set to 2, the description is pulled from the MIB file. If using the MIB file, you must have the Net-SNMP Perl module installed and enabled.

 Note (7):
 
 > These variables are only available when using the embedded trap handler for snmptrapd (snmptthandler-embedded).
 
## <a name="SNMPTT.CONF-EXEC"></a>EXEC
 
 \[**EXEC** command\_string\]
 
 There can be multiple EXEC lines per EVENT.
 
 Optional string containing a command to execute when a trap is received.  The EXEC lines are executed in the order that they appear.
 
 EXEC uses the same variable substitution as the FORMAT line.  You can use **$Fz** on the EXEC line to add the translated FORMAT line instead of repeating what you already defined on FORMAT.
 
 Examples:
 
    EXEC /usr/bin/qpage -f TRAP alex "$r: $x $X - NIC switchover to slot $3, port $4 from slot $5, port $6"  

    FORMAT NIC switchover to slot $3, port $4 from slot $5, port $6
    EXEC /usr/bin/qpage -f TRAP alex "$r: $x $X - $Fz"  

    EXEC c:\\snmp\\pager netops "$r: $x $X - NIC switchover to slot $3, port $4 from slot $5, port $6"
 
 Note: Unlike the FORMAT line, nothing is prepended to the message.  If you would like to include the hostname and date in the page above, you must use the variables such as $r, $x and $X.  
   
 Note: If the trap severity is set to LOGONLY in the snmptt.conf file, EXEC will not be executed.
 
## <a name="SNMPTT.CONF-PREEXEC"></a>PREEXEC
 
 \[**PREEXEC** command\_string\]
 
 There can be multiple PREEXEC lines per EVENT.
 
 Optional string containing a command to execute after a trap is received but **_before_** the FORMAT and EXEC statements are processed. The output of the external program is stored in the **$p*n*** variable where ***n*** is a number starting from 1. Multiple PREEXEC lines are permitted. The first PREEXEC stores the result of the command in **$p1**, the second in **$p2** etc. Any ending newlines are removed. The **snmptt.ini** parameter **pre\_exec\_enable** can be used to enable / disable **PREEXEC** statements.
 
 **PREEXEC** uses the same variable substitution as the FORMAT line.
 
 Example:
 
    EVENT linkDown .1.3.6.1.6.3.1.1.5.3 "Status Events" Normal  
    FORMAT Link down on interface $1($p1). Admin state: $2. Operational state: $3  
    PREEXEC /usr/local/bin/snmpget -v 1 -Ovq -c public $aA ifDescr.$1
 
 Sample output:
 
 > Link down on interface 69("100BaseTX Port 1/6 Name SERVER1"). Admin state up. Operational state: down
 
 In the above example the result is in quotes because that is what comes back from snmpget (it is not added by SNMPTT).
 
 Note: PREEXEC will execute even if the trap severity is set to LOGONLY in the snmptt.conf file.

## <a name="SNMPTT.CONF-NODES"></a>NODES
 
 \[**NODES** sources\_list\]
 
 Used to limit which devices can be mapped to this EVENT definition. 
 
 There can be multiple NODES lines per EVENT.
 
 Optional string containing any combination of host names, IP addresses, CIDR network address, network IP address ranges, or a filename.  If this keyword is omitted then ALL sources will be accepted.  Each entry is checked for a match.  As soon as one match occurs, searching stops.
 
 For example, if you only wanted devices on the subnet 192.168.1.0/24 to trigger this EVENT, you could use a NODES entry of:
 
    NODES 192.168.1.0/24
 
 Or, if you wanted devices on IPv4 subnet 192.168.1.0/24 and IPv6 subnet 2001:db8:a::/64:
 
     NODES 192.168.1.0/24 2001:db8:a::/64

 If a filename is specified, it must be specified with a full path. 
 
 There are two modes of operation: **POS** (positive - the default) and **NEG** (negative). If set to **POS**, then **NODES** is a 'match' if _any_ of the **NODES** entries match. If set to **NEG**, then **NODES** is a 'match' only if _none_ of the **NODES** entries match. To change the mode of operation, use one of the following statements:
 
    NODES MODE=POS
    NODES MODE=NEG
 
 A common use for this feature is when you have devices that implement a trap in a non-standard way (added additional variables for example) such as the linkDown and linkUp traps. By defining two EVENT statements and using NODES statements with NODES MODE, you can have one EVENT statement handle the standard devices, and the other handle the other devices with the extended linkDown / linkUp traps.
 
 Example 1:  
 
 > This example will match any hosts called **fred**, **barney**, **betty** or **wilma**:  
 >   
    NODES fred barney betty wilma
 
 Example 2:  
 
 > This example will match any hosts **not** called **fred**, **barney**, **betty** or **wilma**:  
 >   
    NODES fred barney betty wilma
    NODES MODE=NEG
 
 Example 3:  
 
 > This example will load the file /etc/snmptt-nodes (see below), and match any hosts called fred, barney, betty, wilma, network ip addresses  192.168.1.1, 192.168.1.2, 192.168.1.3, 192.168.2.1, network range 192.168.50.0/22 or network range 192.168.60.0-192.168.61.255:  
 >   
    NODES /etc/snmptt-nodes
 
 Example 4:  
 
 > This example will load both files /etc/snmptt-nodes and /etc/snmptt-nodes2 (see above example):  
 >   
    NODES /etc/snmptt-nodes /etc/snmptt-nodes2
 
 Example 5:  
 >
    NODES 192.168.4.0/22 192.168.60.0-192.168.61.255 /etc/snmptt-nodes2
 
 Example 6:  
 >
    NODES fred /etc/snmptt-nodes pebbles /etc/snmptt-nodes2 barney
 
 where snmptt-nodes contains:
 >
    fred  
    barney betty  
    # comment lines  
    192.168.1.1 192.168.1.2 192.168.1.3  
    192.168.2.1  
    192.168.50.0/22  
    192.168.60.0-192.168.61.255  
    wilma

 Notes:
 
 * The names are NOT case sensitive and comment lines are permitted by starting the line with a #.  
    
 * CIDR network addresses must be specified using 4 octets followed by a / followed by the number of bits.  For example: 172.16.0.0/24.  Using 172.16/24 will NOT work.  
    
 * Do not use any spaces between network ranges as they will be interpreted as two different values.  For example, 192.168.1.1   -    192.168.1.20 will not work.  Use 192.168.1.1-192.168.1.20 instead.  
    
 * By default, NODES files are loaded when the snmptt.conf files are loaded (during startup of SNMPTT).  The snmptt.ini option **dynamic\_nodes** can be set to 1 to have the nodes files loaded each time an EVENT is processed.  

 * See the section '[Name Resolution / DNS](#DNS)' for important DNS information.

 * See the section [IPv6](#Notes-ipv6) for important IPv6 information.

## <a name="SNMPTT.CONF-MATCH"></a>MATCH

 \[MATCH \[MODE=\[or | and\]\] | \[$n:\[!\]\[(    )\[i\] | n | n-n | > n | < n | x.x.x.x | x.x.x.x-x.x.x.x | x.x.x.x/x\]\]
 
 Optional match expression that must be evaluated to true for the trap to be considered a match to this EVENT definition.
 
 If a MATCH statement exists, and no matches evaluate to true, then the default will be to NOT match this EVENT definition.
 
 The following Perl regular expression modifiers are supported:
 
 > i - ignore case when trying to match
 
   
 
 The following command formats are available:
 
 > **MATCH MODE=\[or | and\]  
 > MATCH _$x:_ \[!\] _(reg) \[i\]_  
 > MATCH _$x:_ \[!\] _n_  
 > MATCH _$x:_ \[!\] _n-n_  
 > MATCH _$x:_ \[!\] _< n_  
 > MATCH _$x:_ \[!\] _\> n_  
 > MATCH _$x:_ \[!\] & _n_  
 > MATCH _$x:_ \[!\] _x.x.x.x_  
 > MATCH _$x:_ \[!\] _x.x.x.x-x.x.x.x_  
 > MATCH _$x:_ \[!\] _x.x.x.x/x_  
 > MATCH _$x:_ \[!\] _x:x:x_  
 > MATCH _$x:_ \[!\] _x:x:x/x_  
 > **  

 where:  
 
 > **or** or **and** set the default evaluation mode for ALL matches  
 > **$x** is any variable (example: $3, $A, $\* etc)  
 > **reg** is a regular expression  
 > **!** is used to negate the result (not)  
 > **&** is used to perform a bitwise AND  
 > **n** is a number  
 > **x.x.x.x** is an IP address  
 > **x.x.x.x-x.x.x.x** is an IPv4 network address range  
 > **x.x.x.x/x** is an IPv4 CIDR network addresss  
 > **x:x:x** is an IPv6 addresss  
 > **x:x:x/x** is an IPv6 CIDR network addresss  

 Notes:  
  
 * To limit which devices can be mapped to this EVENT definition based on the IP address / hostname of the device / agent that sent the trap, the **NODES** keyword is recommended.  
  
 * If the match mode is 'or', once a match occurs no other matches are performed and the end result is true.  
  
 * If the match mode is 'and', once a match fails, no other matches are performed and the end result is false.  
  
 * To use parentheses ( or ) in the search expression, they must be backslashed (\\).  
  
 * If no MATCH MODE= line exists, it defaults to 'or'.  
  
 * There can be only one match mode per EVENT.  If multiple MATCH MODE= lines exists, the last one in the list is used.

 * See the section [IPv6](#Notes-ipv6) for important IPv6 information.

 Examples:  
  
 > $2 must be between 1000 and 2000:  

 >
    MATCH $2: 1000-2000

 > Any one of the following must match (or): $3 must be 52, or $4 must be an IP address between 192.168.1.10 and 192.168.1.20, or the severity must be 'Major':  
  
 >
    MATCH $3: 52
    MATCH $4: 192.168.1.10-192.168.1.20
    MATCH $s: (Major)

 > $6 must be IPv6 address 2002:0000:0000:1234:abcd:ffff:c0a8:0101 or in subnet 2002:0000:0000:1234:0000:0000:0000:0000/64:
  
 >
    MATCH $6: 2002::1234:abcd:ffff:c0a8:0101
    MATCH $6: 2002:0000:0000:1234:0000:0000:0000:0000/64

 > All must match (and): $3 must be greater than 20, and $5 must not contain the words alarm or critical, $6 must contain the string '(1) remaining' and $7 must contain the string 'power' which is not case sensitive:  
  
 >
    MATCH $3: >20  
    MATCH $5: !(alarm|critical)  
    MATCH $6: (\(1\) remaining)  
    MATCH $7: (power)i  
    MATCH MODE=and

 > The integer $1 must have bit 4 set:  

 >
    MATCH $1: &8

## <a name="SNMPTT.CONF-REGEX"></a>REGEX
 
   
 \[**REGEX**(    )(    )\[i\]\[g\]\[e\]\]
 
 Optional regular expression to perform a search and replace on the translated FORMAT / EXEC line.  Multiple REGEX (    )(    ) lines are permitted.
 
 First (    ) contains the search expression.  
 Second (    ) contains the replacement text
 
 The following Perl regular expression modifiers are supported:
 
 > i - ignore case when trying to match left side  
 > g - replace all occurances instead of only the first  
 > e - execute the right side (eval) as code
 
 To use substitution with captures (memory parenthesis) or the **e** modifier, you must first enable support in the snmptt.ini file by setting **allow\_unsafe\_regex** to 1.  Note:  This is considered unsafe because the contents of the right expression is executed (eval) by Perl which could contain unsafe code.  If this option is enabled, **BE SURE THAT THE SNMPTT CONFIGURATION FILES ARE SECURE!**
 
 Each REGEX line is processed in order from top to bottom and are accumulative.  The second REGEX operates on the results of the first REGEX etc.
 
 **Example:**
 
 > FORMAT line before:  UPS has       detected a      building alarm.       Cause: UPS1 Alarm #14: Building alarm 3.  

 >   
    REGEX (Building alarm 3)(Computer room high temperature)  
    REGEX (Building alarm 4)(Moisture detection alarm)  
    REGEX (roOm)(ROOM)ig  
    REGEX (UPS)(The big UPS)  
    REGEX (\s+)( )g  
    >   

 > FORMAT line after:  The big UPS has detected a building alarm. Cause: UPS1 Alarm #14: Computer ROOM high temperature
>
 To use parentheses ( or ) in the search expression, they must be backslashed (\\) otherwise it is interpreted as a capture (see below).  The replacement text does not need to be backslashed.
 
 **Example:**
 
 > FORMAT line before:  Alarm (1) and (2) has been triggered  

 >  
    REGEX (\(1\))(One)  
    REGEX (\(2\))((Two))  
   
 > FORMAT line after:  Alarm One and (Two) has been triggered

 If **allow\_unsafe\_regex** is enabled, then captures can be used in the replacement text.  

 **Example:**

 > FORMAT line before:  The system has logged exception error 55 for the service testservice  
  
 > 
    REGEX (The system has logged exception error (\d+) for the service (\w+))(Service $2 generated error $1)  
  
 > FORMAT line after:  Service testservice generated error 55

 If **allow\_unsafe\_regex** is enabled and an e modifier is specified, then the right side is executed (evaluated).  This allows you to use Perl functions to perform various tasks such as convert from hex to decimal, format text using sprintf etc.  All text must be inside of quotes, and statements can be concatenated together using the dot (.).  

 **Example 1:**

 > FORMAT line before:  Authentication Failure Trap from IP address: C0 A8 1 FE  

 > 
    REGEX (Address: (\w+)\s+(\w+)\s+(\w+)\s+(\w+))("address: ".hex($1).".".hex($2).".".hex($3).".".hex($4))ei  
  
 > FORMAT line after:  Authentication Failure Trap from IP address: 192.168.1.254


 **Example 2:**

 > FORMAT line before:  Authentication Failure Trap from IP address: C0 A8 1 FE  
  
 > 
    REGEX (Address: (\w+)\s+(\w+)\s+(\w+)\s+(\w+))("address:".sprintf("%03d.%03d.%03d.%03d",hex($1),hex($2),hex($3),hex($4)))ie

 > FORMAT line after:  Authentication Failure Trap from IP address: 192.168.001.254
 
 **Example 3**

 > This example is for a BGP bgpBackwardTranstion trap.  The OID for the bgpBackwardTranstion trap has the IP address of the device that transitioned appended to the end of the OID.  To create a meaningful trap message, the IP address needs to be separated from the variable OID.  Because the IP address is part of the OID variable name instead of the OID value, a REGEX expression is needed.  The following uses the $+1 variable on the FORMAT line so REGEX can parse out the IP address.
 >
 > FORMAT line before:  Peer:$+2  

 > FORMAT line after substitution, but before REGEX:  Peer:bgpPeerState.192.168.1.1:idle  

 > 
    REGEX (Peer:.\*\.(\d+\.\d+\.\d+\.\d+):(.\*))("Peer: $1 has transitioned to $2")e  
  
 > FORMAT line after:  Peer: 192.168.1.1 has transitioned to idle
  
 **Example 4**
 
 > This example is a sample of using Perl subroutines inside of a REGEX statement.  

 > FORMAT line before:  Extremely severe error has occured  

 >
    REGEX (Extremely severe error has occured)(("Better get a lotto ticket!!  Here is a lotto number to try:".sprintf ("%s", lottonumber());sub lottonumber { for(my $i=0;$i<6;$i++) { $temp = $temp . " " . (int(rand 49) +1); } return $temp; } )ie  

 > FORMAT line after:  Better get a lotto ticket!!  Here is a lotto number to try: 36 27 38 32 29 6
 
 Note:  The REGEX expression is executed on the final translated FORMAT / EXEC line, after all variable substitutions have been completed.
 
   
 
## <a name="SNMPTT.CONF-SDESC"></a>SDESC
 
 \[**SDESC**\]
 
 Optional start of a description.  All text between this line and the line EDESC will be ignored by SNMPTT. This section can be used to enter comments about the trap for your own use.  If you use a SDESC, you MUST follow with a EDESC.
 
## <a name="SNMPTT.CONF-EDESC"></a>EDESC
 
 \[**EDESC**\]
 
 Used to end the description section.
 
 Example:
 
 >
    SDESC  
    Trap used when power supply fails in  
    a server.  
    EDESC

# <a name="SNMPTT.CONF-Configuration-file-Notes"></a>SNMPTT.CONF Configuration file Notes

When there are multiple definitions of the same trap in the configuration file, the following rules apply:

**A match occurs when:**

*   The received trap OID matches a defined OID in the configuration file
*   **AND** **(** the hostname matches a defined hostname in the NODES entry **OR** there is no NODES entry **)**
*   **AND** **(** the MATCH statement evaluates to TRUE **OR** the there is no MATCH entry  **)**

**If multiple\_event is set to 1 in snmptt.ini:**

*   A trap is handled as many times as it matches in the configuration file
*   If any number of exact matches exist, the wildcard match is NOT performed
*   If an exact match does NOT exist, the wildcard match IS performed if **(** the hostname matches a defined hostname in the NODES entry **OR** there is no NODES entry **)** **AND** **(** the MATCH statement evaluates to TRUE **OR** the there is no MATCH entry  **)**

**If multiple\_event is set to 0 in snmptt.ini:**

*   A trap is handled once using the first match in the configuration file
*   If an exact match exists, the wildcard match is NOT performed
*   If an exact match does NOT exist, the wildcard match IS performed if **(** the hostname matches a defined hostname in the NODES entry **OR** there is no NODES entry **)** **AND** **(** the MATCH statement evaluates to TRUE **OR** the there is no MATCH entry  **)**

  

# <a name="DNS"></a>Name resolution / DNS

Snmptrapd passes the IP address of the device sending the trap (host name), the host name of the device sending the trap (host name, if configured to resolve host names) and the IP address of the actual SNMP agent (agent).  
  
If the configuration setting **dns\_enable** is set to 0 (dns disabled), then the host name of the AGENT will not be available for the **$A** variable, **NODES** matches, and the hostname column in SQL databases.  The only exception to this is if the (host) IP address matches the (agent) IP address and snmptrapd is configured to resolve host names.  In that case, the host name of the (host) will be used for the (agent) host name as they are obviously the same host.  
  
If the configuration setting **dns\_enable** is set to 1 (dns enabled), then the host name of both the host and the AGENT will be resolved via DNS.  **NODES** entries will also be resolved to IP addresses before performing matches.  
  
The host name may resolve to the Fully Qualified Domain Name (FQDN).  For example: barney.bedrock.com.  Adding an entry for the host in your /etc/hosts file or %systemroot%\\system32\\drivers\\etc\\hosts may result in the short name being used instead (barney).  You can also enable the **strip\_domain** / **strip\_domain\_list** options to have SNMPTT strip the domain of any FQDN host.  See the **snmptt.ini** file for details.

To allow IP addresses to be resolved to host names, PTR records must exist in DNS or the local hosts file must contain all hosts.  
  
It is recommended that either DNS be installed on the machine running SNMPTT / snmptrapd or a local hosts file be configured will all devices.  DNS should be configured as a secondary (authoritive) for the domains that it will receive traps from.  This will reduce network resolution traffic, speed up resolution, and remove the dependency of the network for DNS.  If a local DNS or hosts file is not used, then the entire network management station could become useless during a DNS / remote network outage and could cause false alarms for network management software.  
  
# <a name="Sample-SNMPTT.CONF-file"></a>Sample SNMPTT.CONF files
  
## <a name="Sample1-SNMPTT.CONF-file"></a>Sample1


Note: The examples folder also contains a sample snmptt.conf file.

Following is a sample of two defined traps in **snmptt.conf:**

    #  
    EVENT COMPAQ_11003 .1.3.6.1.4.1.232.0.11003 "LOGONLY" Normal  
    FORMAT Compaq Generic Trap: $*  
    EXEC qpage -f TRAP notifygroup1 "Compaq Generic Trap: $*"  
    NODES /etc/snmp/cpqnodes  
    SDESC  
    Generic test trap  
    EDESC  
    #  
    #  
    EVENT cpqDa3AccelBatteryFailed .1.3.6.1.4.1.232.0.3014 "Error Events" Critical  
    FORMAT Battery status is $3.  
    EXEC qpage -f TRAP notifygroup1 "$s $r $x $X: Battery status is $3"  
    NODES ntserver1 ntserver2 ntserver3  
    #  
    #

## <a name="Sample2-SNMPTT.CONF-file"></a>Sample2

Following is a sample of a list of files to load in **snmptt.ini:**

    snmptt_conf_files = <<END  
    /etc/snmp/snmp-compaq.conf  
    /etc/snmp/snmp-compaq-hsv.conf  
    END

Following is a sample of one defined trap in **/etc/snmp/snmptt-compaq.conf:**

    #  
    EVENT COMPAQ_11003 .1.3.6.1.4.1.232.0.11003 "LOGONLY" Normal  
    FORMAT Compaq Generic Trap: $*  
    EXEC qpage -f TRAP notifygroup1 "Compaq Generic Trap: $*"  
    NODES /etc/snmp/cpqnodes  
    SDESC  
    Generic test trap  
    EDESC  
    #

Following is a sample of one defined trap in **/etc/snmp/snmptt-compaq-hsv.conf:**

    #  
    EVENT mngmtAgentTrap-16025 .1.3.6.1.4.1.232.0.136016025 "Status Events" Normal  
    FORMAT Host $1 : SCellName-TimeDate $2 : EventCode $3 : Description $4  
    EXEC qpage -f TRAP notifygroup1 "Host $1 : SCellName-TimeDate $2 : EventCode $3 : Description $4"  
    SDESC  
    "Ema EMU Internal State Machine Error [status:10]"  
    EDESC  
    #

# <a name="Notes"></a>Notes

## <a name="Notes-trapd.conf"></a>trapd.conf & MIB files

An existing HP Openview trapd.conf can be used in most cases but the file must be a VERSION 3 file.  SNMPTT does not support all the variables implemented in HPOV, but most are available.  The following variables may or may not match exactly to HPOV: $O, $o, $r, $ar, $R, $aR.

Some vendors (such as Compaq and Cisco ) provide a file that can be imported in to HP Openview using an HP Openview utility.  snmpttconvert can be used to convert the file to snmptt.conf format.

Some vendors provide a MIB file that contains TRAP or NOTIFICATION definitions.  snmpttconvertmib can be used to convert the file to snmptt.conf format.  

## <a name="Notes-ipv6"></a>IPv6

* For incoming traps, a simple Perl regular expression is used to detect an IPv6 address for the trap host and Agent IPs as it is assumed that Net-SNMP is passing a valid IPv6 address.  If the address has a zone index such as **%ens160** or **%1** appended to it, the zone index is removed.  Zone indexes are not removed from enterprise variable values.
* When DNS is enabled to resolve enterprise variables, the trap host and Agent IP **(dns_enabled = 1)**, a complex regular expression is used to confirm that the IP address is valid before passing on to the **IO::Socket::IP** module for DNS resolution.  The [Dartware](https://community.helpsystems.com/forums/intermapper/miscellaneous-topics/5acc4fcf-fa83-e511-80cf-0050568460e4?_ga=2.113564423.1432958022.1523882681-2146416484.1523557976) regular expression is used.  Also see [here](https://raw.githubusercontent.com/richb-intermapper/IPv6-Regex/master/test-ipv6-regex.pl) for a test suite.
* For **NODES** and **MATCH**, the [Net::IP](http://search.cpan.org/search?module=Net::IP) module is used as it allows you to test to see if two IP addresses are the same or if one IP address is within the range of another.  IPv6 addresses can be represented in multiple ways so this module is used to ensure that an IP address such as **2002:0000:0000:1234:abcd:ffff:c0a8:0101** is matched to its shorthand version of **2002::1234:abcd:ffff:c0a8:0101**.  When running a modified version of the test suite above against Net::IP, it was found that it only passed 316 out of 490 tests compared to Dartmouth which passed 489 out of 490.  There may be issues with matching some IP addresses passed in enterprise variables for MATCH but  NODES should not be affected as Net-SNMP should be passing a supported format for both the host and agent IP addresses.

# <a name="Limitations"></a>Limitations

## **Standalone mode only:**

With a 450 Mhz PIII (way back in 1998) and a 9000 line snmptt.conf containing 566 unique traps (EVENTs), it took under a second to process the trap including logging and executing the qpage program.  The larger the snmptt.conf file is, the longer it will take to process.  If there are a large number of traps being received, daemon mode should be used.  If it takes 1 second to process one trap, then obviously you shouldn't try to process more than one trap per second.  Daemon mode should be used instead.

Note: Enabling the Net-SNMP Perl module will greatly increase the startup time of SNMPTT.  Daemon mode is recommended.

## **Standalone or daemon mode:**

The SNMPTRAPD program blocks when executing traphandle commands.  This means that if the program called never quits, SNMPTRAPD will wait forever.  If a trap is received while the traphandler is running, it is buffered and will be processed when the traphandler finishes.  I do not know how large this buffer is.

The program called by SNMPTT (EXEC) blocks SNMPTT.  If you call a program that does not return, SNMPTT will be left waiting.  In standalone mode, this would cause snmptrapd to wait forever also.  
 

# <a name="Feedback"></a>Feedback & Bugs

Please send me any comments - good or bad - to alex\_b@users.sourceforge.net.  If you have any problems including converting trap files, please send me an email and include the file you are trying to convert and I will try to take a look at it.

Please also send any bug reports, patches or improvements so I can fix / add them and add it to the next release.  You can also use Sourceforge for [bugs](http://sourceforge.net/tracker/?group_id=51473&atid=463393) and [feature requests](http://sourceforge.net/tracker/?atid=463396&group_id=51473&func=browse).  
 

# <a name="Integration-with-other-software"></a>Integration with other software

## <a name="Nagios-Netsaint"></a>Nagios     

### Overview

This section will outline the basic steps to integrate SNMPTT with Nagios Core.  If you are using Nagios XI, see [Handling SNMP Traps With Nagios](https://www.nagios.com/solutions/snmp-traps/).

Before attempting to integrate SNMPTT with Nagios, please ensure that you have a fully functioning SNMPTT system that can at least log translated traps to a log file.

  

### Nagios Passive Service Checks

Passive service checks allow Nagios to process service check results that are submitted by external applications.  Using SNMPTT's EXEC statement, the received trap can be passed to Nagios using the **submit\_check\_result** script included with Nagios.  Once received by Nagios, Nagios will handle alerting for the trap.  

One service is defined for each Nagios host that is to receive traps from SNMPTT.  The benefits of using only one service entry is that it makes it easier to set up Nagios. Trying to define every possible trap for every host you have is not recommended.  For example, after converting the MIBS from Compaq, there are over 340 traps defined.  Trying to define this for every Compaq server would not be a good idea as 40 servers \* 340 traps = 13,600 service definitions.

The downside of using only one service entry is that you will only see the last trap that was received on the Nagios console.  Alerting will be handled by Nagios for each trap received but the console will only show the last one as being in the warning or critical state.  The service will remain in this state until you manually force a service check unless you have freshness checking enabled (Nagios 2.0 and higher).  See Clearing received traps in Nagios below.

  

### Nagios Volatile Services

When defining the service for receiving the SNMPTT translated trap, the service must be defined as volatile.  When a service is changed from an OK state to a non-OK state, contacts are notified.  Normally, a service is Nagios in not defined volatile which means if another service check is performed and the state is still non-OK then NO contacts are notified.  Because there is only one service entry for SNMP traps, we need to make sure we are contacted every time a trap comes in.

  

### Creating the Nagios service entry

Following is a sample service entry for Nagios.
 
    define service{
        host_name               server01            # Name of host
        service_description     TRAP                # Name of service.  What you use here must match the same value for the submit_check_result script
        is_volatile             1                   # Enables volatile services
        check_command           check-host-alive    # Used to reset the status to OK when 'Schedule an immediate check of this service' is selected.
        max_check_attempts      1                   # Leave as 1.
        normal_check_interval   1                   # Leave as 1.
        retry_check_interval    1                   # Leave as 1.
        active_checks_enabled   0                   # Prevent active checks from occuring as we are only using passive checks.
        passive_checks_enabled  1                   # Enables passive checks
        check_period            24x7                # Required for freshness checking.
        notification_interval   31536000            # Notification interval.  Set to a very high number to prevent you from
                                                    #  getting pages of previously received traps (1 year - restart Nagios 
                                                    #  at least once a year! - do not set to 0!).
        notification_period     24x7                # When you can be notified.  Can be changed
        notification_options    w,u,c               # Notify on warning, unknown and critical.  Recovery is not enabled so we do not 
                                                    #  get notified when a trap is cleared.
        notifications_enabled   1                   # Enable notifications
        contact_groups          cg_core             # Name of contact group to notify
    }

Note:  To simplify the configuration, you can create a service template.

Note:  Previous versions of this documentation defined a **check\_period** of none, and did not set **active\_checks\_enabled** to 0.  As of SNMPTT 1.2, setting **active\_checks\_enabled** to 0 instead of setting **check\_period** to none is recommened as freshness checks require it.  The recovery notification option has also been removed so we do not get notified when a trap is cleared.

### Creating the SNMPTT EXEC statement
 
The Nagios distribution should contain the script **submit\_check\_result** in the **contrib/eventhandlers** directory.  Create a directory called **eventhandlers** under **libexec** (/usr/local/nagios/libexec) and copy the **submit\_check\_result** script to that directory.  Make sure the script is executable (**chmod +x submit\_check\_result**).  
  
The **submit\_check\_result** script expects the following arguments:  
  
> **host\_name**
> **svc\_description**
> **return\_code**
> **plugin\_output**

The possible return codes are: **0**=OK, **1**=WARNING, **2**=CRITICAL, **-1**=UNKNOWN.  See the top of the **submit\_check\_result** script for a detailed description of each argument.  
  
Create an **EXEC** statement such as the following for each **EVENT** entry in your snmptt.conf file:   

    EXEC /usr/local/nagios/libexec/eventhandlers/submit_check_result $r TRAP 1 "xxxxxx"
 
where "xxxxxx" is the text for the trap using the same format as the FORMAT statement.  For example:  
  
    EXEC /usr/local/nagios/libexec/eventhandlers/submit_check_result $r TRAP 1 "Drive $1 in bay $2 has failed"

The variable substitution **$r** is used to pass the host name, TRAP matches the service definition defined above, 1 represents a WARNING, and "xxxxxx" is the same text used for your FORMAT line.

Instead of repeating the same text as the FORMAT line, you can instead use the **$Fz** variable in the EXEC statement.  For example, to generate the EXEC command when using snmpttconvertmib:

Create a file called exec-commands.txt with (all on one line):

    /usr/local/nagios/libexec/eventhandlers/submit_check_result $r TRAP 1 "$Fz"

Run snmpttconvertmib using:

    snmpttconvertmib --in=/usr/share/snmp/mibs/mibname.mib --out=/etc/snmp/snmptt.conf --exec_mode=1 --exec_file=exec-commands.txt

Note:  Run snmpttconvertmib -h for information on the command line options.

You must make sure that the host definition in Nagios matches the hostname that will be passed from SNMPTT using the **$r** variable.  See the section '[Name Resolution / DNS](#DNS)' for important DNS information.  
 

### Clearing received traps in Nagios

Using the above configuration, once a trap is received for a host, it will remain in the WARNING state.  To clear the trap from the Nagios console, open the TRAP service and click 'Schedule an immediate check of this service'.  This will cause the defined service check to be run (check-host-alive in the example above) which will then change the status code to OK and clear the warning after a minute or so, assuming of course the system responds OK to the check-host-alive check.  An alternative to using check-host-alive is to create a new command called reset-trap with:  
  
    #!/bin/sh  
    /bin/echo "OK: No recent traps received"  
    exit 0
  
Be sure to create a command definition in your **commands.cfg** file.  See the 'Object configuration file options' section of the Nagios documentation.  
  
Nagios 2.0 introduced service and host result freshness checks.  Service freshness checks can be used to automatically reset the trap notification to an OK state by defining **check\_freshness** and **freshness\_threshold** in the service definition.  Using freshness checks is recommended over normal active checks (defined by **normal\_check\_interval**) because the next check time of a normal active check does not change when a service changes state.  Because of this, if you wanted to clear the trap after 24 hours, the last trap would be cleared some time between when it happened at 24 hours, depending on when the last active check was done.  With freshness checking, the check command will be run **freshness\_threshold** seconds after the last passive result was received.  
  
For freshness checking to work, **normal\_check\_interval** must be set to **1**, **valid check\_period** should be set to **24x7** and the following service definitions should be added. 

    check_freshness         1           # Enable freshness checking
    freshness_threshold     86400       # Reset trap alert every 24 hours.

### SNMP heartbeat monitoring

If you have an application that sends periodic SNMP heartbeats, it is possible to use freshness checking to alert if a heartbeat has not been received.  
  
To configure a heartbeat trap, start by creating a new service definition by following 'Creating the Nagios service entry' above, but use a new service\_description such as MyApp\_heartbeat.  Next, add / change the following service definitions.  

    check_freshness         1                           # Enable freshness checking
    freshness_threshold     1200                        # Check freshness every 20 minutes.
    check_command           myapp_heartbeat_alarm_set   # Command to execute when a heartbeat is not received within freshness_threshold seconds.
    notification_options    w,u,c,r                     # Notify on warning, unknown critical and recovery.
  
Note:  For freshness checking to work, **normal\_check\_interval** must be set to **1**, and valid **check\_period** should be set to **24x7**.  
  
In this example, it is assumed that the heartbeat trap is received every 15 minutes, so a freshness\_threshold of 20 minutes was selected in case the heartbeat was delayed.  
  
Create the new **myapp\_heartbeat\_alarm\_set** command for Nagios:  

    #!/bin/sh  
    /bin/echo "CRITICAL: Heartbeat signal from MyApp was not received!"  
    exit 2
 
Be sure to create a command definition in your **commands.cfg** file.  See the 'Object configuration file options' section of the Nagios documentation.  
  
Next, add an **EXEC** statement to the snmptt.conf file for the trap definition:  

    EXEC /usr/local/nagios/libexec/eventhandlers/submit_check_result $r MyApp_heartbeat 1 "Heartbeat signal from MyApp received."
 
As long as the traps are received, the MyApp\_heartbeat service will have an OK status.  If the heartbeat is not received, the freshness command will be executed which will set the status to **CRITICAL**.  
    

## <a name="Icinga"></a>Icinga  

### Overview

This section will outline the basic steps to integrate SNMPTT with Icinga.  Some of the configuration and scripts were copied from [Icinga's SNMPTT documentation](https://icinga.com/docs/icinga-2/snapshot/doc/07-agent-based-monitoring/#snmp-traps-and-passive-check-results).

Before attempting to integrate SNMPTT with Icinga, please ensure that you have a fully functioning SNMPTT system that can at least log translated traps to a log file.

  

### Icinga Passive Service Checks

Passive service checks allow Icinga to process service check results that are submitted by external applications.  Using SNMPTT's EXEC statement, the received trap can be passed to Icinga via the curl program.  Once received by Icinga, Icinga will handle alerting for the trap.  

In this guide, we setup **one** service definition for each Icinga host that is to receive traps from SNMPTT.  The benefits of using only one service entry is that it  makes it easier to set up Icinga. Trying to define every possible trap for every host you have is not recommended.  For example, after converting the MIBS from Compaq, there are over 340 traps defined.  Trying to define this for every Compaq server would not be a good idea as 40 servers \* 340 traps = 13,600 service definitions.  
  

The downside of using only one service entry is that you will only see the last trap that was received on the Icinga console.  Alerting will be handled by Icinga for each trap received but the console will only show the last one as being in the warning or critical state.  The service will remain in this state until you manually force a service check unless you have freshness checking enabled.  See Clearing received traps in Icinga below.

  

### Icinga Volatile Services

When defining the service for receiving the SNMPTT translated trap, the service must be defined as volatile.  When a service is changed from an OK state to a non-OK state, contacts are notified.  Normally, a service in Icinga is not defined volatile which means if another service check is performed and the state is still non-OK then NO contacts are notified.  Because there is only one service entry for SNMP traps, we need to make sure we are contacted every time a trap comes in.
 

### Creating the Icinga service entry

Following is a sample service entry for Icinga.

    object Service "TRAP" {  
      host_name = "server1.domain"  
      import "generic-service"  
    
      check_command         = "dummy"  
      event_command         = "trap-reset-event"  
    
      enable_notifications  = 1  
      enable_active_checks  = 0  
      enable_passive_checks = 1  
      enable_flapping       = 0  
      volatile              = 1  
      enable_perfdata       = 0  
    
      vars.dummy_state      = 0  
      vars.dummy_text       = "Manual reset."  
    
      vars.sla              = "24x7"  
    }
 

Note:  To simplify the configuration, you can instead apply the service to hosts using an 'apply Service'.  See the [Icinga SNMPTT documentation](https://icinga.com/docs/icinga-2/snapshot/doc/07-agent-based-monitoring/#snmp-traps-and-passive-check-results) for an example.

  

### Creating the SNMPTT EXEC statement

  
Create an EXEC statement such as the following for each **EVENT** entry in your snmptt.conf file:  

    EXEC /usr/bin/curl -k -s -S -i -u apiuser:password -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/actions/process-check-result' -d '{ "type": "Service", "filter": "host.name==\"$A\" && service.name==\"TRAP\"", "exit_status": 2, "plugin_output": "xxxxxx", "check_source": "$A", "pretty": true }'

where **_apiuser_:_password_** is the API username and password, ***xxxxxx*** is the text for the trap using the same format as the FORMAT statement.  
  
The variable substitution **$A** is used to pass the host name for **host.name** and **check\_source**, TRAP for **service.name** matches the service definition defined above, **exit\_status** of **1** represents a **WARNING**, and **xxxxxx** is the same text used for your FORMAT line.

Instead of repeating the same text as the FORMAT line, you can instead use the **$Fz** variable in the EXEC statement.  For example, to generate the EXEC command when using snmpttconvertmib:

Create a file called exec-commands.txt with (all on one line):

    /usr/bin/curl -k -s -S -i -u apiuser:password -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/actions/process-check-result' -d '{ "type": "Service", "filter": "host.name==\"$A\" && service.name==\"TRAP\"", "exit_status": 2, "plugin_output": "$Fz", "check_source": "$A", "pretty": true }'

Run snmpttconvertmib using:

    snmpttconvertmib --in=/usr/share/snmp/mibs/mibname.mib --out=/etc/snmp/snmptt.conf --exec_mode=1 --exec_file=exec-commands.txt

Note:  Run snmpttconvertmib -h for information on the command line options.

An API user must be defined in api-users.conf with the permission **actions/process-check-result**.  Example:  
  
    object ApiUser "snmptt" {  
      password = "xxxxxxxxxxxxxxx"  
      permissions = [ "actions/process-check-result" ]  
    }
  
You must make sure that the host definition in Icinga matches the hostname that will be passed from SNMPTT using the **$A** variable.  See the section '[Name Resolution / DNS](#DNS)' for important DNS information.  
  

### Clearing received traps in Icinga

Using the above configuration, once a trap is received for a host, it will remain in the WARNING state.  To clear the trap from the Icinga console, open the TRAP service and click 'Check Now'.  This will cause the defined event check to be run (trap-reset-event in the example above) which will then change the status code to OK and clear the warning.  For this to work, you must define an Icinga command:  
  
    object EventCommand "trap-reset-event" {  
      command = [ ConfigDir + "/scripts/trap_reset_event.sh" ]  
    
      arguments = {  
        "-i" = "$service.state_id$"  
        "-n" = "$host.name$"  
        "-s" = "$service.name$"  
      }  
    }
  
Create the **trap\_reset\_event.sh** script in **ConfDir** **/scripts** (/etc/icinga2/scripts) and make sure it's executable (**chmod +x**).  
  
    #!/bin/bash  
    
    SERVICE_STATE_ID=""  
    HOST_NAME=""  
    SERVICE_NAME=""  
    
    show_help()  
    {  
    cat <<-EOF  
        Usage: ${0##*/} [-h] -n HOST_NAME -s SERVICE_NAME  
        Writes a coldstart reset event to the Icinga command pipe.  
    
          -h                  Display this help and exit.  
          -i SERVICE_STATE_ID The associated service state id.  
          -n HOST_NAME        The associated host name.  
          -s SERVICE_NAME     The associated service name.  
    EOF  
    }  
    
    while getopts "hi:n:s:" opt; do  
        case "$opt" in  
          h)  
              show_help  
              exit 0  
              ;;  
          i)  
              SERVICE_STATE_ID=$OPTARG  
              ;;  
          n)  
              HOST_NAME=$OPTARG  
              ;;  
          s)  
              SERVICE_NAME=$OPTARG  
              ;;  
          '?')  
              show_help  
              exit 0  
              ;;  
          esac  
    done  
    
    if [ -z "$SERVICE_STATE_ID" ]; then  
        show_help  
        printf "\n  Error: -i required.\n"  
        exit 1  
    fi  
    
    if [ -z "$HOST_NAME" ]; then  
        show_help  
        printf "\n  Error: -n required.\n"  
        exit 1  
    fi  
    
    if [ -z "$SERVICE_NAME" ]; then  
        show_help  
        printf "\n  Error: -s required.\n"  
        exit 1  
    fi  
    
    if [ "$SERVICE_STATE_ID" -gt 0 ]; then  
        echo "[`date +%s`] PROCESS_SERVICE_CHECK_RESULT;$HOST_NAME;$SERVICE_NAME;0;Auto-reset (`date +"%m-%d-%Y %T"`)." >> /var/run/icinga2/cmd/icinga2.cmd  
    fi  

To have the TRAP service automatically cleared 20 minutes after the last trap was received, modify the service entry to enable active checks and define a check\_interval:  
  
    enable_passive_checks = 1  
    check_interval        = 1200

## <a name="Zabbix"></a>Zabbix

Information on handling SNMP traps with [Zabbix](https://www.zabbix.com) can be found in the [Zabbix documentation](https://www.zabbix.com/documentation/current/manual/config/items/itemtypes/snmptrap).

## <a name="SEC"></a>SEC - Simple Event Correlator

### Overview

[Simple Event Correlator (SEC)](http://kodu.neti.ee/%7Eristo/sec/) is a free and platform independent event correlation tool.

This section will outline the basic steps to integrate SNMPTT with SEC.  It will not attempt to explain how SEC works.  There is very good documentation available on the [SECs web page](http://kodu.neti.ee/%7Eristo/sec/) and a good introduction to SEC can be found [here](http://simple-evcorr.sourceforge.net/SEC-tutorial/article.html).  You should be able to install and configuration SEC before attempting to integrate it with SNMPTT.  You should also have a functioning SNMPTT system that can at least log translated traps to a log file.

This section outlines one method of integrating SEC with SNMPTT.  Another method is documented in the [March 2005 edition](https://web.archive.org/web/20050429210306/http://www.samag.com/articles/2005/0503/) of **Sys Admin Magazine** in an article written by Francois Meehan.  A copy of the article is available [here](https://www.drdobbs.com/snmp-trap-handling-with-nagios/199102017).
  
Here are a couple of examples of why you would want to integrate SNMPTT with SEC:   

1. You have a 'noisy' device that constantly sends the same trap over and over again.  It would be possible to simply disable the trap in SNMPTT, but you want the trap to be logged, just not excessively.  The SEC 'SingleWithSupress' could be used to reduce the number of traps logged.
2. Router interfaces often go up and down and you are receiving a trap for each event.  You do not want to be alerted every time the interface 'bounces', but you do want to be alerted if it happens many times over a set period of time.  You want to be alerted when the interface is down for more than 10 seconds, and then when the interface comes back up.

The following outlines how the flow of traps between SNMPTT and SEC could take place:
 
1. SNMPTT receives a trap.
2. SNMPTT logs the trap to a separate log file such as /var/log/snmptt/snmptt.sec.log using '/bin/echo ...' for the EXEC statement.  No FORMAT line is defined so the trap is not logged to the regular snmptt.log log file (or SQL table if a SQL server is used).
3. SEC monitors the log file for new entries.
4. SEC correlates the messages from the log file.
5. When a new alert needs to be generated by SEC based on its rules, SEC will call an external script which will feed the information back into SNMPTT as a trap using a user defined unique trap OID.  The unique trap OID is defined in a custom snmptt.conf file (such as /etc/snmp/snmptt.conf.sec).
6.  SNMPTT will process the new trap as it would any other trap by logging to snmptt.log, a SQL table etc.
 
### Configuration Overview
 
The following outlines how example 2 from above could be handled using SEC.  This is a slightly modified version of the example from the [SEC Examples page](http://kodu.neti.ee/%7Eristo/sec/examples.html).
 
The example provides the following:

* Prevents interface flapping from flooding the log files
* Provides an 'unstable' and 'stable' alert based on how often the interface bounces.
 
The following steps need to be completed:

1. Modify the Cisco snmptt.conf file to output linkDown and linkUp messages to a separate log file.
2. Create a new snmptt.conf file to handle incoming alerts from SEC
3. Create a SEC configuration file to correlate the linkDown / linkUp messages and pass new alerts to a script
4. Create a script that will feed the messages from SEC back in to SNMPTT
5. Test
 
### 1\. Modify the Cisco SNMPTT.CONF file

The existing SNMPTT.CONF file needs to be modified to output the linkDown and linkUp messages to a separate log file for processing by SEC.

Following is an example snmptt.conf.cisco file modified to log a linkdown or linkup message to /var/log/snmptt/snmptt.sec.log.  As you can see there are no FORMAT lines so the trap will not be logged to the regular SNMPTT log system.

    EVENT Cisco_Link_Down .1.3.6.1.6.3.1.1.5.3.1.3.6.1.4.1.9 "Cisco Events" Minor  
    EXEC /bin/echo "node=$A msg_text=cisco linkdown trap on interface $1" >> /var/log/snmptt/snmptt.sec.log  
    SDESC  
    This event occurs when the Cisco agent  
    detects an interface has gone down.  
    
    A linkDown trap signifies that the sending  
    protocol entity recognizes a failure in one of  
    the communication links represented in the  
    agent's configuration.  
    EDESC  
    #  
    #  
    #  
    EVENT Cisco_Link_Up .1.3.6.1.6.3.1.1.5.4.1.3.6.1.4.1.9 "Cisco Events" Normal  
    EXEC /bin/echo "node=$A msg_text=cisco linkup trap on interface $1" >> /var/log/snmptt/snmptt.sec.log  
    SDESC  
    This event occurs when the Cisco agent  
    detects an interface has come back up.  
    
    A linkUp trap signifies that the sending  
    protocol entity recognizes that one of the  
    communication links represented in the agent's  
    configuration has come up.  
    EDESC  
    #  
    #  
    #

 
### 2\. Create a new SNMPTT.CONF file for incoming SEC alerts

A new SNMPTT.CONF file needs to be created which will handle the incoming traps from SEC.  
  
Following is an example snmptt.conf.sec file to accept incoming traps from SEC.  Use an enterprise OID that will not interferre with any other OIDs already configured on your system.  For example, .1.3.6.1.4.1.9999.  
   
 
    EVENT Cisco_Link_DownUp .1.3.6.1.4.1.9999.1 "Cisco Events" Normal  
    FORMAT $1  
    #  
    #  
    #  
    EVENT Cisco_Link_DownUp .1.3.6.1.4.1.9999.2 "Cisco Events" Major  
    FORMAT $1  
    #  
    #  
    #

### 3\. Create a SEC configuration file
 
Following is a SEC configuration file that handles the even correlation for the Cisco traps.  This file is the same as the file available on the [SEC Examples page](http://kodu.neti.ee/%7Eristo/sec/examples.html) except comments and file paths have been modified.  
   
 
    ########################################################  
              Sample SEC ruleset for SNMPTT  
    ########################################################  
    
    # process Cisco linkDown/linkUp trap events received from  
    # SNMPTT via log file  
   
    type=PairWithWindow  
    ptype=RegExp  
    pattern=node=(\S+).*msg_text=cisco linkdown trap on interface (\S+)  
    desc=CISCO $1 INTERFACE $2 DOWN  
    action=event %s;  
    continue2=TakeNext  
    ptype2=RegExp  
    pattern2=node=$1.*msg_text=cisco linkup trap on interface $2  
    desc2=CISCO %1 INTERFACE %2 BOUNCE  
    action2=event %s;  
    window=20  
    
    type=SingleWithSuppress  
    continue=TakeNext  
    ptype=RegExp  
    pattern=CISCO (\S+) INTERFACE (\S+) DOWN  
    desc=cisco $1 interface $2 down  
    action=reset +1 %s  
    window=60  
    
    type=Pair  
    ptype=RegExp  
    pattern=CISCO (\S+) INTERFACE (\S+) DOWN  
    desc=cisco $1 interface $2 down  
    action=shellcmd /home/snmptt/cisco_msg $1 $2 major down  
    ptype2=RegExp  
    pattern2=node=$1.*msg_text=cisco linkup trap on interface $2  
    desc2=cisco %1 interface %2 up  
    action2=shellcmd /home/snmptt/cisco_msg %1 %2 normal up  
    window=86400  
    
    type=SingleWith2Thresholds  
    ptype=RegExp  
    pattern=CISCO (\S+) INTERFACE (\S+) BOUNCE  
    desc=cisco $1 interface $2 is unstable  
    action=shellcmd /home/snmptt/cisco_msg $1 $2 major unstable  
    window=3600  
    thresh=10  
    desc2=cisco $1 interface $2 is stable again  
    action2=shellcmd /home/snmptt/cisco_msg $1 $2 normal stable  
    window2=10800  
    thresh2=0
 
   
Here is a quick breakdown of what each rule does:  
   
First rule:  
 
* If a linkDown is received (node=x msg\_text=cisco linkdown trap on interface x from SNMPTT), and then a linkUp is received within 20 seconds, it is considered a BOUNCE.  A new 'event' is created with the internal SEC event 'CISCO %1 INTERFACE %2 BOUNCE' is created which is passed to the other rules. 
* If a linkDown is received and a linkUp is not received within 20 seconds, a new 'down' internal SEC event is created (CISCO $1 INTERFACE $2 DOWN) which is passed to the other rules.
 
Second rule:  
 
* Allows only one 'CISCO x INTERFACE x DOWN' message to be processed over 60 seconds.
 
Third rule:  
 
* When a SEC internally generated 'CISCO $1 INTERFACE $2 DOWN' message is found, it passes the host name, interface number and 'major down' to the cisco\_msg script.
* When a SEC internally generated 'CISCO $1 INTERFACE $2 UP' message is found, it passes the host name, interface number and 'normal up' to the cisco\_msg script.
 
Fourth rule:  
 
* If ten 'CISCO %1 INTERFACE %2 BOUNCE' messages are detected over the span of 1 hour, it passes the host name, interface number and 'major unstable' to the cisco\_msg script.
* If after the last unstable alert there are no 'CISCO %1 INTERFACE %2 BOUNCE' messages for 3 hours, it passes the host name, interface number and 'normal stable' to the cisco\_msg script.

### 4\. Create a script to pass a trap back to SNMPTT
 
Following is a Perl script that passes the information passed from SEC back to SNMPTT by calling **snmptthandler** directly.  This file is basically a modified Perl version of the shell script available on the [SEC Examples page](http://kodu.neti.ee/%7Eristo/sec/examples.html).   
 
    #!/usr/bin/perl  
    #  
    # the cisco_msg script:  
    #  
    use Socket;  
    
    node = shift(@ARGV);  
    interface = shift(@ARGV);  
    severity = shift(@ARGV);  
    text  = shift(@ARGV);  
    
    temp_ipaddr = gethostbyname($node);  
    if (defined($temp_ipaddr)) {  
      $ipaddr = Socket::inet_ntoa(scalar($temp_ipaddr));  
    }  
    else {  
      $ipaddr = "0.0.0.0";  
    }  
    
    # use snmpget utility from Net-SNMP package  
    ifname=`/usr/bin/snmpget -c public -OQv $NODE .1.3.6.1.2.1.2.2.1.2.$IF`  
    description=`/usr/bin/snmpget -c public -OQv $NODE .1.3.6.1.4.1.9.2.2.1.1.28.$IF`  
    
    message="Interface $ifname ($description) $text";  
    message=~s/\"/\'/g;  
    
    open (TRAP, "|/usr/sbin/snmptthandler");  
    
    select TRAP;  
    
    print "$node\n";  
    print "$ipaddr\n";  
    print ".1.3.6.1.2.1.1.3.0 00:00:00:00.00\n";  
    if ($severity=~/normal/i) {  
      print ".1.3.6.1.6.3.1.1.4.1.0 .1.3.6.1.4.1.9999.1\n";  
    }  
    else {  
      print ".1.3.6.1.6.3.1.1.4.1.0 .1.3.6.1.4.1.9999.2\n";  
    }  
    print ".1.3.6.1.4.1.9999.1.1 $message\n";  
    print ".1.3.6.1.6.3.18.1.3.0 $ipaddr\n";  
    print ".1.3.6.1.6.3.18.1.4.0 public\n";  
    print ".1.3.6.1.6.3.1.1.4.3.0 .1.3.6.1.4.1.9999\n";  
    
    close TRAP;
 
   
## <a name="EventWin"></a>Windows Event Log forwarding
 
### Overview
 
The Windows utility Event to Trap Translator (**evntwin.exe** and **evntcmd.exe)** can be used to configure Windows to forward user selectable Event Log entries to an SNMP manager when using the Microsoft SNMP service. SNMPTT can be configured to process these traps like any other trap.  If the Event to Trap Translator is not already installed on your machine, it should be available from the Microsoft Resource Kit, SMS or after installation of the Microsoft SNMP service (Windows 2000 AS and Windows XP or higher).
 
**This section will outline the basic steps to configure Windows to forward event log entries to Net-SNMP / SNMPTT when using the Microsoft SNMP server (not the Net-SNMP snmpd.exe agent).  It will not attempt to explain how evntwin.exe and evntcmd.exe function.  Documentation on using evntwin.exe and evntcmd.exe is available on the Microsoft web site and should be reviewed. You should have a functioning SNMPTT system that can at least log translated traps to a log file before attempting this.**
 
### SNMP Service
 
The Windows SNMP Service is the Microsoft SNMP agent which is responsible for handling SNMP requests from management stations such as queries for CPU utilization, disk space etc. The agent is also responsible for sending traps to management stations when an event occurs.

Note: The Microsoft SNMP Trap Service is used to RECEIVE SNMP traps which is similar to the Net-SNMP **snmptrapd.exe** daemon. The Microsoft SNMP Trap Service is NOT used to send traps and is not required.
 
### Configuring the trap destination

The Windows SNMP agent needs to be configured to forward traps to your Net-SNMP / SNMPTT management station. This is done using the following steps:

*   Open **Administrative Tools**
*   Open **Services**
*   Open **Local Policies**
*   Open **SNMP Service**
*   Click the **Traps** tab
*   Enter a community name and click Add to List
*   Click Add and enter the IP address of the management station
*   Click Apply
*   Click OK
*   Right-click on **SNMP Service** and select **Restart**

After the service is restarted, a **coldStart** trap will be sent to the management station. If SNMPTT has been configured to translate **coldStart** messages, you should see a log entry similar to the following:

**Thu Sep 9 21:33:06 2004 .1.3.6.1.6.3.1.1.5.1 Normal "Status Events" server1 - Device reinitialized (coldStart)**

Note:If the SNMP Service is not listed in the Services Control Panel, then it needs to be installed using Add/Remove Programs. Under Add/Remove Windows Components, select **Management and Monitoring Tools** and then **Simple Network Management Protocol**.
 
### Configuring the Event to Trap Translator
 
The following steps explain how to configure the Event to Trap Translator to forward system logon failures to SNMPTT:
 
*   Launch **evntwin.exe**
*   For **Configuration Type** select **Custom**
*   Click the **Edit** button
*   Inside **Event Sources**, expand **Security** and then click **Security**
*   Locate Event ID **529** (Logon Failure:%n%tReason:%t%tUnknown username or bad password%n.)
*   Click **Add**
*   Click **OK**
*   Click **Apply**
 
The SNMP agent should now forward all logon failures to the SNMP management station. A restart of the SNMP service should not be necessary.
 
### Configuring SNMPTT to accept the Microsoft traps
 
An SNMPTT.CONF file needs to be created to handle the Microsoft traps. All Microsoft traps start with .1.3.6.1.4.1.311.1.13.1. For simplicity, a single SNMPTT.CONF EVENT entry will be used with a wildcard to accept all Microsoft traps. Following is an example **snmptt.conf.microsoft** file which needs to be included in the list of .conf files in the **TrapFiles** section in **snmptt.ini**:
 
    EVENT EventLog .1.3.6.1.4.1.311.1.13.1.* "Regular" Normal
    FORMAT EventLog entry: $1
 
The first enterprise variable (**$1**) contains the complete text that is displayed in the Event Log Description box. Variables are described in more detail in the **Advanced Section**.
 
After creating the **snmptt.conf.microsoft** file and adding it to the **snmptt.ini**, restart SNMPTT.
 
### Testing
 
To test that the trap is received by SNMPTT, a logon failure in Windows should be created.
 
Your default installation of Windows may not create Event Log entries for unsuccessful logins. To configure Windows to log all failed logins, follow these steps:
 
*   Open **Administrative Tools**
*   Open **Local Security Policy**
*   Open **Local Policies**
*   Open **Audit Policy**
*   Enable auditing of failures for **Audit account logon events**
*   Enable auditing of failures for **Audit logon events**
 
The settings should take effect immediately, and a reboot should not be required.
 
To generate an event log entry, you can either log off and try to log on to the system with an invalid username and password, or use the **runas.exe** command from command prompt. For example:
 
    runas /user:fakeuser cmd
 
When prompted for a password, press **Enter**.
 
SNMPTT should log something similar to the following:
 
**Thu Sep 9 21:05:40 2004 .1.3.6.1.4.1.311.1.13.1.8.83.101.99.117.114.105.116.121.0.529 Normal "Regular" server1 - Event Log entry: Logon Failure:.....Reason:..Unknown user name or bad password.....User Name:.fakeuser.....Domain:.......Logon Type:.joint-iso-ccitt.....Logon Process:.seclogon.....Authentication Package:.Negotiate.....Workstation Name:.SERVER1.**
 
The text in the log entry should match the text in the **Description** field of the Event Log entry but without the formatting.
 
### Advanced Configuration
 
#### Specific EVENTs
 
Instead of using a wildcard EVENT entry to match all Microsoft traps, it is possible to create EVENT entries for each trap. As SNMPTT will only match using wildcard entries if there is no exact EVENT match, it may be desirable to create EVENT entries for a select number of important events, and keep the wildcard to catch any others.

To determine the trap OID that will be used for the EVENT, display the entry in **evntwin.exe** and combine the **Enterprise OID**, a **0** and the **Trap Specific ID**. For example, for the security event ID 529 used above:
 
> Enterprise OID: 1.3.6.1.4.1.311.1.13.1.8.83.101.99.117.114.105.116.121
 
> Trap Specific ID: 529
 
Based on the information above, the following EVENT line would be used::
 
    EVENT EventLog 1.3.6.1.4.1.311.1.13.1.8.83.101.99.117.114.105.116.121.0.529 "Regular" Normal
 
#### Enterprise variables
 
Each trap sent from the Event to Trap Translator contains the text displayed in the Description, User and Computer fields for the Event Log. Also passed are the individual variables which are used by the Windows SNMP Service to create the Description field in the Event Log.
 
The following lists the enterprise variables that can be used in SNMPTT for each trap:
 
*   $1:Event Log Description
*   $2:Event Log User
*   $3:Event Log Computer
*   $4:?
*   $5:?
*   $6:Event to Trap Translator variable %1
*   $7:Event to Trap Translator variable %2
*   $8:Event to Trap Translator variable %3
*   $9:Event to Trap Translator variable %4
*   $_n_:Event to Trap Translator variable %_n-5_
 
As the individual variables are passed in the trap, it is possible to recreate the FORMAT line instead of using the passed Description ($1) field. For example, $1 in the previous example contains:

**Logon Failure:.....Reason:..Unknown user name or bad password.....User Name:.fakeuser.....Domain:.......Logon Type:.joint-iso-ccitt.....Logon Process:.seclogon.....Authentication Package:.Negotiate.....Workstation Name:.SERVER1.**

By reviewing the Description field as defined in the **evntwin.exe** utility, a new cleaned up FORMAT line can be used that does not contain all the dots.

Following is the text from the Description field in **evntwin.exe** which will be used as a reference. Notice the use of %_n_ variables which are equivalent to the SNMPTT $n variables +5 (%1 = SNMPTT's $6). Note: In the example below, %n is a newline and %t is a tab while %_n_ is a variable number.

Logon Failure:%n %tReason:%t%tUnknown user name or bad password%n %tUser Name:%t%1%n %tDomain:%t%t%2%n %tLogon Type:%t%3%n %tLogon Process:%t%4%n %tAuthentication Package:%t%5%n %tWorkstation Name:%t%6

The EVENT entry could be cleaned up using:

    EVENT EventLog 1.3.6.1.4.1.311.1.13.1.8.83.101.99.117.114.105.116.121.0.529 "Regular" Normal  
    FORMAT Logon Failure: Reason: Unknown user name or bad password. User Name: $6, Domain: $7, Logon Type: $8, Logon Process: $9, Auth package: $10, Workstation name: $11

## <a name="Hobbit"></a>Xymon / Hobbit

Information on handling SNMP traps with [Xymon](https://xymon.sourceforge.io/) (formerly [Hobbit](http://hobbitmon.sourceforge.net/)) can be found at [http://cerebro.victoriacollege.edu/hobbit-trap.html](http://cerebro.victoriacollege.edu/hobbit-trap.html).