<!DOCTYPE doctype PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta name="generator" content=
"HTML Tidy for HTML5 for Linux version 5.4.0" />
<meta content="text/html; charset=utf-8" http-equiv=
"Content-Type" />
<meta content="Alex Burger" name="Author" />
<meta content="Mozilla/4.78 [en] (Windows NT 5.0; U) [Netscape]"
name="GENERATOR" />
<link rel="StyleSheet" type="text/css" href="layout1.css" />
<title>SNMP Trap Translator FAQ</title>
</head>

#SNMPTT FAQ / Troubleshooting

**([www.snmptt.org](http://www.snmptt.org))**  
This file was last updated on: March 25th, 2021

#Table of Contents

## Installation

* [What version of Net-SNMP should I run?](#What_version_of_NET-SNMP_should_I_run)
* [Do I need the UCD-SNMP / Net-SNMP Perl module?](#Do_I_need_the_UCD-SNMP_Net-SNMP_Perl_module)
* [I want to enable the Perl support for UCD-SNMP / Net-SNMP under Linux, but I installed UCD-SNMP / Net-SNMP using RPMs. What is the easiest way to install the module without recompiling everything?](#I_want_to_enable_the_Perl_support_for_UCD-SNMP)
* [I want to use Net-SNMP under Windows. What should I do?](#I_want_to_use_Net-SNMP_under_Windows)
* [How to I enable the Perl support for UCD-SNMP / Net-SNMP under Windows](#How_to_I_enable_the_Perl_support_for_UCD-SNMP)
* [**Which trap handler should I use?  snmptthandler or snmptthandler-embedded?**](#Which_trap_handler_should_I_use)
* [Are there any sample files to get me started?](#Are_there_any_sample_files_to_get_me_started)
* [Why doesn't the snmptt-init.d script work with Debian?](#Why_doesnt_the_snmptt-init.d_script_work_with_Debian)

## General

* [I have enabled net\_snmp\_perl\_enable but the variable names are not being translated into text using $vn, $-n, $+n, $-\* or $+\*. How do I troubleshoot it?](#I_have_enabled_net_snmp_perl_enable_but_the_variable)
* [I have enabled translate\_integers but the integer values are not being translated into text. How do I troubleshoot it?](#I_have_enabled_net_snmp_perl_enable_but_the_variable)
* [SNMPTT is not working! How do I troubleshoot it?](#SNMPTT_is_not_working)
* [I have configured SNMPTT correctly with an snmptt.ini file, snmptt.conf file(s) etc and it still does not process traps. Everything appears in the snmpttunknowntrap.log file. What did I do wrong?](#I_have_configured_SNMPTT_correctly_with_an_snmptt)
* [I have disabled syslog support in SNMPTT, but my syslog (or NT Event Log) is still filling up with trap messages. How do I disable them?](#I_have_disabled_syslog_support_in_SNMPTT)
* [I am using syslog (or NT Event Log) to log trap messages, but there are two log entries for each trap received. How do I prevent it?](#I_have_disabled_syslog_support_in_SNMPTT)
* [I set translate\_oids or translate\_trap\_oid, but the trap is being logged in numerical form. Why?](#I_set_translate_oids_or_translate_trap_oid)
* [I converted a MIB using snmpttconvertmib but the OIDs are appearing as text instead of being numerical. Why?](#I_converted_a_MIB_using_snmpttconvertmib_but_the_OIDs)
* [Does SNMPTT use DNS?](#Does_SNMPTT_use_DNS)
* [Is there a front-end alarm browser available for SNMPTT?](#Is_there_a_front-end_alarm_browser_available_for_SNMPTT)
* [When I convert a MIB file using snmpttconvertmib I get 'Bad operator (\_) errors](#When_I_convert_a_MIB_file_using_snmpttconvertmib)
* [Double quotation marks (") are being logged with a \\ in front of them. How can this be disabled?](#Double_quotation_marks)
* [Each trap received is being logged multiple times. Why?](#Each_trap_received_is_being_logged_multiple)


**<a name="What_version_of_NET-SNMP_should_I_run"></a>Q:  What version of Net-SNMP should I run?**

A:  If you have no plans on using the Net-SNMP Perl module (see the next question), then any recent version of Net-SNMP should be sufficient with the exception of Net-SNMP 5.1.  Net-SNMP 5.1.1 and higher can be used.  If you plan on using UCD-SNMP 4.2.3 (provided by Compaq for RedHat 7.2), then you must at least use a newer version of snmptrapd.

If you plan on enabling the Net-SNMP Perl module, **Net-SNMP v5.1.1 or higher is recommended.**  This will allow you to use all the features of snmptt.  Net-SNMP 5.0.8 and 5.0.9  can also be patched with [patch 722075](http://sourceforge.net/tracker/index.php?func=detail&aid=722075&group_id=12694&atid=312694) to provide similar functionality.  The patch is available from the [Net-SNMP patch page](http://sourceforge.net/tracker/index.php?func=detail&aid=722075&group_id=12694&atid=312694).

The standard way to apply the patch is to follow these steps:  

1.  Download a fresh copy of Net-SNMP 5.0.9 or 5.0.8
2.  Uncompress the archive (tar xvf net-snmp-5.0.9.tar.gz)
3.  cd net-snmp-5.0.x
4.  patch -p0 < /path/to/patch.net-snmp-722075
5.  Compile Net-SNMP as per Net-SNMP documentation  
    

If you run freebsd, you can simply copy the patch file into /usr/ports/net/net-snmp/files and rename it to patch-snmp-72205.  When you rebuild Net-SNMP, the patch will be included.

**<a name="Do_I_need_the_UCD-SNMP_Net-SNMP_Perl_module"></a>Q: Do I need the UCD-SNMP / Net-SNMP Perl module?**

A:  SNMPTT does not REQUIRE the Perl module, but it is recommended.  By enabling the Perl module, you will get the following benefits:  

*   Proper $v, $E, $O, $-n, $+n, $-\*, $+\* (and others that use textual names) variable substitution
*   Conversion of numerical OIDs to text form
*   Conversion of INTEGER values to enumeration tags (for example: **Status is now OK** instead of **Status is now 1**)
*   Conversion of the enterprise into textual form for logging to SQL databases
*   Ability for traps passed from **snmptrapd** or loaded from the **snmptt.conf** files to contain symbolic OIDs such as **linkDown** and **IF-MIB::linkUp**
*   Variable syntax, description and enums when converting a MIB file using snmpttconvertmib

Unless Net-SNMP 5.1.1 or higher or 5.0.8 / 5.0.9 with patch 72205 is used, some Perl features may not work correctly.  The use of Net-SNMP 5.1.1 or higher or 5.0.8 / 5.0.9 with patch 72205 is **highly recommended**.  
  
Note1:  In addition to the regular Perl modules, Net-SNMP allows Perl to be embedded into the SNMP agent (snmpd) and trap receiver (snmptrapd) by specifying --enable-embedded-perl during compilation. This is **only** required by SNMPTT if you plan on using the embedded trap handler (snmptthandler-embedded).  
  
Note2:  Do not confuse the CPAN module Net::SNMP (use Net::SNMP;) with the Net-SNMP Perl module (use SNMP;).  They are two completely unrelated programs.  Net::SNMP is a stand-alone SNMP module for Perl, while the Net-SNMP Perl module is a Perl extension of the [Net-SNMP](http://www.net-snmp.org) software and is included with [Net-SNMP](http://www.net-snmp.org). Distributions such as RedHat provide the Perl modules in a separate RPM package called 'net-snmp-perl'.  
  

**<a name="I_want_to_enable_the_Perl_support_for_UCD-SNMP"></a>Q:  I want to enable the Perl support for under Linux, but I installed *Net-SNMP* using RPMs.  What is the easiest way to install the module without recompiling everything?**

A:  There are two Perl components for Net-SNMP:

> 1) The Perl modules which allow you to create stand-alone Perl programs that use the 'SNMP' module (use SNMP;)

> 2) Embedded Perl for snmpd and snmptrapd which allow you to write Perl programs that are loaded and run from inside of snmpd and snmptrapd.

The Perl modules (1) are optional but recommended.  See [**Do I need the UCD-SNMP / Net-SNMP Perl module?**](Do_I_need_the_UCD-SNMP_Net-SNMP_Perl_module) for the benefits of enabling the Perl modules.  

Embedded Perl (2) is only needed if you want to use the embedded trap handler (snmptthandler-embedded).See xxxxx for the benefits of using the embedded handler.

For the Perl modules (1), most Linux distributions provide RPMs.  For RedHat, install the net-snmp-perl RPM package using yum.

If you compiled Net-SNMP from source, then the Perl module should be enabled by default.  Typing the following is an easy test to see if the Perl module has been installed:

    perl
    use SNMP;

If you get an error message starting with 'Can't locate SNMP.pm in @INC....' then the Perl module has not been installed.  Press control-C to exit Perl if there was no error.

For embedded Perl support (2), you may have to compile Net-SNMP yourself using the '--enable-embedded-perl' configuration option.  To test to see if you already have embedded Perl enabled:

* Type **snmptrapd -H 2>&1 | grep perl**.  It should give **perl   PERLCODE** if embedded Perl is enabled.  

* If it's not available, you need to compile and install Net-SNMP using the **\--enable-embedded-perl** configure option.  Use the net-snmp-users mail list for assistance.

If you are using UCD-SNMP, you should not have to re-compile the entire package.  Try the following:

1.  Download the source RPM that matches the binary RPM you downloaded.  For example: ucd-snmp-4.2.3-1.src.rpm
2.  Install the RPM
3.  Locate the installed source code.  For Mandrake, it should be in /usr/src/RPM/SOURCES
4.  Go into the sub directory perl/SNMP
5.  Follow the instructions in the README file

Note:  If you have installed Net-SNMP 5.0.9 or 5.0.8 using RPM packages, and want to apply patch 722075, you will need to re-compile the entire package and re-install.  Patch 722075 makes modifications to both the Perl source files, and the main snmp libraries so the above steps will not work.

**<a name="I_want_to_use_Net-SNMP_under_Windows"></a>Q:  I want to use Net-SNMP under Windows.   What should I do?**

  

A:  You have at least three options:

1.  Download the Net-SNMP 5.1.2+ binary from the Net-SNMP home page and install.  
    
2.  Download the Net-SNMP 5.1.2+ source and compile using MSVC++, MinGW or Cygwin as described in the Net-SNMP README.WIN32 file.  This should create a working snmptrapd.  See the question: **How to I enable the Perl support for UCD-SNMP / Net-SNMP under Windows**? Note: Net-SNMP 5.1.2 or higher is recommended if compiling under Windows as it contains the latest Windows specific compiling improvements.  
    

**<a name="How_to_I_enable_the_Perl_support_for_UCD-SNMP"></a>Q:  How to I enable the Perl support for UCD-SNMP / Net-SNMP under Windows**

A:  There are two Perl components for Net-SNMP:

1. The Perl modules which allow you to create stand-alone Perl programs that use the 'SNMP' module (use SNMP;)
2. Embedded Perl for snmpd and snmptrapd which allow you to write Perl programs that are loaded and run from inside of snmpd and snmptrapd.

The Perl modules (1) are optional but recommended.  See [**Do I need the UCD-SNMP / Net-SNMP Perl module?**](Do_I_need_the_UCD-SNMP_Net-SNMP_Perl_module) for the benefits of enabling the Perl modules.  
  

As of July 2009, embedded Perl (2) is not currently supported under Windows.

***Native Windows:***

> Install ActiveState ActivePerl and then the ActivePerl **.ppm** module included in  the Net-SNMP binary available from the [Net-SNMP web site](http://www.net-snmp.org).

> If you compiled your own version of Net-SNMP, see the perl/README document for instructions on compiling the Perl modules.

***Cygwin:***

> Download the Net-SNMP 5.1.2+ source and compile using Cygwin as described in the Net-SNMP README.WIN32 file.

> Compile the Perl modules as described in the perl\\SNMP\\README file. 

> The program **snmptt-net-snmp-test** can be used to perform various translations to test the functionality of the installed UCD-SNMP / Net-SNMP Perl module.  The value of **best\_guess** can be specified on the command line to determine how translations should occur.  If you are using 5.0.8+ with patch 722075 or 5.1.1+, use:  **snmptt-net-snmp-test --best\_guess=2**.


**<a name="Which_trap_handler_should_I_use"></a>Q:  Which trap handler should I use?  snmptthandler or snmptthandler-embedded?**

A:  The standard handler is fine for most installations.  The embedded handler was introduced in snmptt 1.3 and is recommended if there is a high volume of traps being received.

*Standard Handler:*

The standard handler is a small Perl program that is called each time a trap is received by snmptrapd when using daemon mode.  The limitations of this handler are:  

*   Each time a trap is received, a process must be created to run the snmptthandler program and snmptt.ini is read each time.
*   SNMPv3 EngineID and names are not passed by snmptrapd to snmptthandler

The benefits of using this handler are:  

*   Does not require embedded Perl for snmptrapd
*   Has been around since v0.1 if snmptt.
*   Sufficient for most installations

*Embedded Handler:*

The embedded handler is a small Perl program that is loaded directly into snmptrapd when snmptrapd is started.  The limitations of this handler are:  

*   Requires embedded Perl for snmptrapd
*   Only works with daemon mode

The benefits of using this handler are:  

*   The handler is loaded and initialized when snmptrapd is started, so there is less overhead as a new process does not need to be created and initialization is done only once (loading of snmptt.ini).
*   SNMPv3 EngineID and names variables are available in snmptt (B\* variables)  
    

  
**<a name="Are_there_any_sample_files_to_get_me_started"></a>Q: Are there any sample files to get me started?**

A:  Yes, the examples folder contains a sample snmptt.conf file, and a sample trap file for testing.  

1.  Install SNMPTT as described in this document
2.  Copy the **snmptt.conf.generic** file to the location specified in the snmptt.ini file (probably **/etc/snmp/** or **c:\\snmp**)
3.  Add **snmptt.conf.generic** to the **snmptt\_conf\_files** section of **snmptt.ini**.
4.  For standalong mode, test SNMPTT by typing:  **snmptt < sample-trap.generic**  
    For daemon mode, test SNMPTT by copying sample-trap.generic.daemon to the spool folder
5.  Check the logs files etc for a sample linkDown trap

**<a name="Why_doesnt_the_snmptt-init.d_script_work_with_Debian"></a>Q:  Why doesn't the snmptt-init.d script work with Debian?**
  
The snmptt-init.d script provided with SNMPTT was written for Mandrake and RedHat.  To make the script work with Debian without requiring any re-writing of the script, copy **/etc/init.d/skeleton** to **/etc/init.d/functions**.  

**<a name="I_have_enabled_net_snmp_perl_enable_but_the_variable"></a>Q:  I have enabled net\_snmp\_perl\_enable but the variable names are not being translated into text using $v_n, $-n, $+n, $-\* or $+\*_.  How do I troubleshoot it?**

**<a name="I_have_enabled_net_snmp_perl_enable_but_the_variable"></a>Q:  I have enabled translate\_integers but the integer values are not being translated into text.   How do I troubleshoot it?**

A:  You must have the UCD-SNMP / Net-SNMP Perl module installed and working, and must ensure UCD-SNMP / Net-SNMP is configured correctly with all the required MIBS.

For starters, make sure the SNMP module is working.  Type:

    perl
    use SNMP;

If you get an error after typing 'use SNMP', then the module is not installed correctly.  Re-install the module and make sure you execute the tests while building.

If the MIB files are present, but translations do not occur, ensure UCD-SNMP / Net-SNMP is correctly configured to process all the required mibs.  This is configured in the snmp.conf file.  Alternatively, you can try setting the **mibs\_enviroment** variable in snmptt.ini to **ALL** (no quotes) to force all MIBS to be initialized at SNMPTT startup.

If everything appears to be fine, try translating the variable name by hand by using snmptranslate.  Get the variable name OID from the snmptt.debug file from the second Value 0+ section, and type:

    snmptranslate -Td _oid_

This should return the OBJECT-TYPE for the variable if it exists in a MIB file

If you are using UCD-SNMP v4.2.3, then the variables will not translate properly because SNMPTRAPD does not pass them correctly to SNMPTT.  Upgrade to a newer version of snmptrapd.  

**<a name="SNMPTT_is_not_working"></a>Q:  SNMPTT is not working!  How do I troubleshoot it?**

A:  Start by enabling **enable\_unknown\_trap\_log** in the **snmptt.ini** file.  Look inside this file to see if the traps are being passed correctly to SNMPTT but not being handled correctly.  Next, enable debug mode of 2 and specify a debug text file to log to in the snmptt.ini file.  After a trap is received, take a look at the file to try to determine what is going wrong.  Disable both logs when you are finished.

To make troubleshooting a particular trap easier when working in daemon mode, try the following.  This will prevent you have having to continuously generate the trap on the host.

1. Shut down SNMPTT
2. Generate the trap
3. Copy the resulting # file from the spool directory (/var/spool/snmptt) to the /tmp directory as /tmp/test-trap 
4. Edit the file, removing the first line (which is a large number that contains the date / time)
5. Run SNMPTT in standalone method using: **snmptt < test-trap**
6. Troubleshoot by using the log files etc  
    

**<a name="I_have_configured_SNMPTT_correctly_with_an_snmptt"></a>Q:  I have configured SNMPTT correctly with an snmptt.ini file, snmptt.conf file(s) etc and it still does not process traps.  Everything appears in the snmpttunknowntrap.log file.  What did I do wrong?**

A:  You probably didn't start snmptrapd correctly.  Make sure it is started using:

    snmptrapd -On

If it is not started with **\-On**, then it will not pass traps using numeric OIDs and SNMPTT will not process them.

As an alternative, you can edit your **snmp.conf** file to include the line: **printNumericOids 1**. This setting will take effect no matter what is used on the command line.

Note:  If the UCD-SNMP / Net-SNMP Perl module is installed and enabled, then SNMPTT should be able to handle traps passed using symbolic form.  The Perl module (used by SNMPTT) in Net-SNMP 5.0.8 and previous versions should be able to handle single symbolic names (eg: coldTrap).  UCD-SNMP may not properly convert symbolic names to numeric OIDs which could result in traps not being matched.  A patch is available from the Net-SNMP web site for 5.0.8+ to allow it to handle other symbolic names such as module::symbolic name (eg: SNMPv2-MIB::coldTrap) etc.  The patch is available from the contrib folder, or it can be downloaded from the [Net-SNMP patch page](http://sourceforge.net/tracker/index.php?func=detail&aid=722075&group_id=12694&atid=312694).  Net-SNMP 5.1.1 and higher contain this patch.

**<a name="I_have_disabled_syslog_support_in_SNMPTT"></a>Q:  I have disabled syslog support in SNMPTT, but my syslog (or NT Event Log) is still filling up with trap messages.  How do I disable them?**

**Q:  I am using syslog (or NT Event Log) to log trap messages, but there are two log entries for each trap received.  How do I prevent it?**

A:  What you are seeing are **snmptrapd** trap messages, not SNMPTT messages.  SNMPTT trap messages start with '**snmptt\[pid\]:**' while snmptrapd messages start with '**snmptrapd\[pid\]:**'.  If you do not start snmptrapd with either the **\-P** or **\-o** (lowercase o) switches, syslog support will be forced on.  Snmptrapd should be started using '**snmptrapd -On**' and this results in syslog being forced on.  The reason for this is the original design of snmptrapd assumed that if you are not going to display messages on the screen or log to a file, then you must want syslog output.

A workaround is to have snmptrapd log all messages to /dev/null, or to a text file that can be regularily purged if needed.  To log to a text file, start snmptrapd using:

    snmptrapd -On -o /var/log/snmptrapd.log

This will cause **ALL** snmptrapd messages to be logged to the file which means all snmptrapd 'system' messages such as startup and shutdown will not be logged to syslog.

A patch for Net-SNMP 5.0.7 is available that adds a new switch (-t) to prevent TRAP messages from being logged to syslog, but allowing system messages to continue to be logged.  The patch is available from the [Net-SNMP patch section](http://sourceforge.net/tracker/?func=detail&atid=312694&aid=695312&group_id=12694).  This patch is available in Net-SNMP 5.1.1 and higher.  With this patch, snmptrapd should be started using:

    snmptrapd -On -t

**<a name="I_set_translate_oids_or_translate_trap_oid"></a>Q:  I set translate\_oids or translate\_trap\_oid, but the trap is being logged in numerical form.  Why?  **
****Q:  I set translate\_oids or translate\_trap\_oid to 1 or 3 in snmptt.ini, but the trap is not being logged with a long symbolic name.  Why?**

A:  The current version of Net-SNMP (5.0.9 at the time of this writing) and everything before it does not support including the module name (eg: IF-MIB::) when translating an OID and most of the 5.0.x versions do not properly tranlsate numeric OIDs to long symbolic names.  A patch is available for 5.0.8+ that will appear in later releases of Net-SNMP (5.1.1+).  The patch is available from the contrib folder, or it can be downloaded from the [Net-SNMP patch page](http://sourceforge.net/tracker/index.php?func=detail&aid=722075&group_id=12694&atid=312694).  
  
The program **snmptt-net-snmp-test** can be used to perform various translations to test the functionality of the installed UCD-SNMP / NE-SNMP Perl module.  The value of **best\_guess** can be specified on the command line to determine how translations should occur.  
  
**<a name="I_converted_a_MIB_using_snmpttconvertmib_but_the_OIDs"></a>Q:  I converted a MIB using snmpttconvertmib but the OIDs are appearing as text instead of being numerical.  Why?**

**For example:**

    EVENT linkUp .iso.org.dod.internet.snmpV2.snmpModules.snmpMIB.snmpMIBObjects.snmpTraps.linkUp "Status Events" Normal

instead of

    EVENT linkUp .1.3.6.1.6.3.1.1.5.4 "Status Events" Normal

  
A:  **Snmpttconvertmib** uses the **snmptranslate** command to convert MIB files.  With Net-SNMP v5.0.2 and newer, setting the **\-On** switch on the **snmptranslate** command causes the output to be in numerical format, which is what is needed for **snmpttconvertmib**.

With Net-SNMP v5.0.1 and all versions of UCD-SNMP, setting the -On switch will TOGGLE the setting of using numerical output.  With Net-SNMP v5.0.2 and newer, setting the -On switch will FORCE the output to be numerical.

**Snmpttconvermib** will use the **\-On** switch for snmptranslate **only** if it detects anything but UCD-SNMP or Net-SNMP v5.0.1.

If you are using UCD-SNMP, or Net-SNMP v5.0.1, the best option is to modify your **snmp.conf** file (for UCD-SNMP / Net-SNMP), and add or modify the line:

    printNumericOids 1

This will cause all applications to output in numerical format including **snmptranslate**.  Note: This will affect other UCD-SNMP / Net-SNMP programs you are using, if any.  
  
**<a name="Does_SNMPTT_use_DNS"></a>Q:  Does SNMPTT use DNS?**
  
Only if it is enabled.  See the [Name Resolution / DNS](#DNS) section.  
  

**<a name="Is_there_a_front-end_alarm_browser_available_for_SNMPTT"></a>Q:  Is there a front-end alarm browser available for SNMPTT?**

A:  Take a look at [SNMPTT-GUI](http://sourceforge.net/projects/snmptt-gui).  SNMPTT-GUI aims to provide a web based frontend for SNMPTT.  The GUI is made up of server side perl cgi scripts with client side javascripts which interfaces to a SQL database using DBI::ODBC.

SNMPTT-GUI questions should be directed to the project admins on the [SNMPTT-GUI Sourceforge page](http://sourceforge.net/projects/snmptt-gui/).  
 
**<a name="When_I_convert_a_MIB_file_using_snmpttconvertmib"></a>Q:  When I convert a MIB file using snmpttconvertmib I get 'Bad operator (\_) errors.**  

A:  You need to enable support for underlines / underscores in MIB files.  See the snmp.conf man page.  Support can be enabled by adding this line to your main snmp.conf file: 

    mibAllowUnderline 1

**<a name="Double_quotation_marks"></a>Q:  Double quotation marks (") are being logged with a \\ in front of them.  How can this be disabled?**
  
A:  Set **remove\_backslash\_from\_quotes = 1** in the **snmptt.ini** to have the \\ removed from double quotes (").

  
**<a name="Each_trap_received_is_being_logged_multiple"></a>Q:  Each trap received is being logged multiple times. Why?**

A:  There are a few possible reasons for this.

*   The device is sending the trap multiple times. If the device is running Net-SNMP's agent (snmpd), make sure there is only ONE trapsink, trap2sink or informsink line in **snmpd.conf**. If you are sending the trap using SNMP V1, use **trapsink**. For SNMP V2, use **trap2sink**. For SNMP V3, use **informsink**. Having both a trapsink and a trap2sink for example will cause snmpd to send the trap **twice**. Once using SNMP V1 and once using SNMP V2. It is possible that snmpd is loading multiple **snmp.conf** files. Start **snmpd** using **snmpd -f -Dread\_config** to see what configuration files are being loaded.
*   Snmptrapd is passing the trap to SNMPTT multiple times. Ensure there is only one **traphandle** statement in **snmptrapd.conf**. It is possible that snmpdtrapd is loading multiple **snmptrapd.conf** files. Start **snmpdtrapd** using **snmpd -f -Dread\_config** to see what configuration files are being loaded.
*   There is more than one **EVENT** line defined in one or more **snmptt.conf** files for the trap and **multiple\_event** is enabled in **snmptt.ini**. To find all duplicate **EVENT** entries, run **snmptt --dump**