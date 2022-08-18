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
<title>SNMP Trap Translator Convert MIB</title>
</head>

#SNMP Trap Translator Convert MIB v1.5

**(**[**SNMPTTCONVERTMIB**](http://www.snmptt.org)**)**  
This file was last updated on:  October 2nd, 2021

#License

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
  

#SNMPTTCONVERTMIB

**SNMPTTCONVERTMIB** is a Perl script which will read a MIB file and convert the **TRAP-TYPE** (v1) or **NOTIFICATION-TYPE** (v2) definitions into a configuration file readable by **SNMPTT**.

For example, if the file **CPQHOST.mib** (v1) contained:

    CPQHOST-MIB DEFINITIONS ::= BEGIN

        IMPORTS  
            enterprises             FROM RFC1155-SMI  
    .  
    .  
    . (lines removed)  
    .  
    .  
        cpqHo2NicSwitchoverOccurred2 TRAP-TYPE  
            ENTERPRISE compaq  
            VARIABLES { sysName, cpqHoTrapFlags, cpqHoIfPhysMapSlot,  
                        cpqHoIfPhysMapPort, cpqHoIfPhysMapSlot,  
                        cpqHoIfPhysMapPort }  
            DESCRIPTION  
                "This trap will be sent any time the configured redundant NIC  
                becomes the active NIC."

                 --#TYPE "Status Trap"  
                 --#SUMMARY "NIC switchover to slot %s, port %s from slot %s, port %s."  
                 --#ARGUMENTS {2, 3, 4, 5}  
                 --#SEVERITY MAJOR  
                 --#TIMEINDEX 99  
            ::= 11010

Executing **snmpttconvertmib CPQHOST.mib snmptt.conf** would APPEND to the end of the **snmptt.conf** file (specified on the command line):

    #  
    #  
    #  
    EVENT cpqHo2NicSwitchoverOccurred2 .1.3.6.1.4.1.232.0.11010 "Status Events" Normal  
    FORMAT Status Trap: NIC switchover to slot $3, port $4 from slot $5, port $6.  
    #EXEC qpage -f TRAP notifygroup1 "Status Trap: NIC switchover to slot $3, port $4 from slot $5, port $6."  
    SDESC  
    This trap will be sent any time the configured redundant NIC  
    becomes the active NIC.  
    EDESC
 
Notes:

* To specifiy an EXEC statement, use the \--exec= command line option.  
* To prevent the --#TYPE text from being prepended to the --#SUMMARY line, change **$prepend\_type** to **0** in the **SNMPTTCONVERTMIB** script.
* See the help screen for more options (snmpttconvertmib --h).

## Requirements

* Net-SNMP [**snmptranslate**](http://www.net-snmp.org/man/snmptranslate.html) utility
* **Optional**: Net-SNMP **[Perl module](http://www.net-snmp.org/FAQ.html#Where_can_I_get_the_perl_SNMP_package_)**  
    
Snmpttconvertmib converts a MIB file using the snmptranslate utility. 

If the Net-SNMP Perl module is enabled using **\--net\_snmp\_perl** on the command line, it can provide more detailed variable descriptions in the DESC sestion if available such as:

* variable syntax
* variable description
* variable enums

For example:

    2: globalStatus  
       Syntax="INTEGER"  
          2: ok  
          4: failure  
       Descr="Current status of the entire library system"

## Converting a MIB file

See the snmpttconvertmib help screen for all possible command line options (snmpttconvertmib -h) before converting a MIB file.  Depending on what type of information is available in the MIB file, you may want to change how the FORMAT / EXEC lines are generated.

Before trying to convert  MIB file, you should ensure that the MIB file can be parsed by Net-SNMP

1. Copy the MIB file to the Net-SNMP mibs folder
2. Type: **export MIBS=ALL** to ensure all the mibs will be read in by **snmptranslate**
3. Make sure the MIB file can be interpreted by **snmptranslate** correctly.  Simply typing **snmptranslate** should tell you if it was able to read the mib file correctly.  If it can't, an error will be produced at the top of the help screen.
4. Try to translate a TRAP-TYPE or NOTIFICATION-TYPE entry contained inside the MIB file.  For example, if the MIB file contains the Notification definition of 'rptrHealth NOTIFICATION-TYPE', then type:  snmptranslate rptrHealth -IR -Td.  If you get 'Unknown object identifier: xxx' then the MIB file was not found or parsed correctly.  
    

Running snmpttconvertmib:  
 

1. Make sure the MIB file has been successfully installed (see above)  
2. Edit the options between OPTIONS START and OPTIONS END in snmpttconvertmib if needed  
3. If you are using **UCD-SNMP**, or **Net-SNMP v5.0.1**, then add the folllowing to your snmp.conf file: **printNumericOids 1** (note:  this will affect all snmp commands).  This ensures the OIDs are returned in numerical format.  Other versions of Net-SNMP do not require this change, as **snmpttconvertmib** will use a command line switch to force it on when calling **snmptranslate**.
4. Convert the mib file with: **snmpttconvertmib --in=_path-to-mib_ --out=_output-file-name_**.  Note:  the **output-file-name** is appended to, so remember to delete it first if needed.  
    
Examples:

Convert a MIB file without defining an EXEC command:

    snmpttconvertmib --in=/usr/share/snmp/mibs/CPQHOST.mib --out=/etc/snmp/snmptt.conf.compaq

If the Net-SNMP Perl module is installed and you want more descriptive variable descriptions, add --net_snmp_perl to the command line:

    snmpttconvertmib --in=/usr/share/snmp/mibs/CPQHOST.mib --out=/etc/snmp/snmptt.conf.compaq --net_snmp_perl

Append an EXEC command.  The generated FORMAT line from the MIB will be appended to the end of the line surrounded by quotes.  You can disable the quotes by modifying the setting at the top of the snmpttconvertmib script.

    snmpttconvertmib --in=/usr/share/snmp/mibs/CPQHOST.mib --out=/etc/snmp/snmptt.conf.compaq --exec 'qpage -f TRAP notifygroup1'

    Result: EXEC qpage -f TRAP notifygroup1 "A linkUp trap signifies that the SNMP entity, acting in an $*"
   
Same as above, but read the EXEC line(s) from the file exec-commands.txt.  Multiple commands can be added to the file to generate multiple EXEC lines per trap.

    snmpttconvertmib --in=/usr/share/snmp/mibs/CPQHOST.mib --out=/etc/snmp/snmptt.conf.compaq --exec_file exec-commands.txt

Append an EXEC command but don't add the generated FORMAT line.  The variable substitution **$Fz** is used in the --exec line which will cause SNMPTT to replace it with the generated FORMAT line when a trap arrives.

    snmpttconvertmib --in=/usr/share/snmp/mibs/CPQHOST.mib --out=/etc/snmp/snmptt.conf.compaq --exec_mode=1 --exec '/usr/bin/myscript { $Fz }'

Same as above but instead of SNMPTT having to replace **$Fz** with the FORMAT line, snmpttconvertmib will do the substitution:

    snmpttconvertmib --in=/usr/share/snmp/mibs/CPQHOST.mib --out=/etc/snmp/snmptt.conf.compaq --exec_mode=2 --exec '/usr/bin/myscript { $Fz }'

Append a PREEXEC command.

    snmpttconvertmib --in=/usr/share/snmp/mibs/CPQHOST.mib --out=/etc/snmp/snmptt.conf.compaq --preexec '/usr/local/bin/snmpget -v 1 -Ovq -c public $aA ifDescr.$1'

    Result: PREEXEC /usr/local/bin/snmpget -v 1 -Ovq -c public $aA ifDescr.$1

Same as above, but read the PREEXEC line(s) from the file preexec-commands.txt.  Multiple commands can be added to the file to generate multiple PREEXEC lines per trap.

    snmpttconvertmib --in=/usr/share/snmp/mibs/CPQHOST.mib --out=/etc/snmp/snmptt.conf.compaq --preexec_file preexec-commands.txt

To convert all the CPQ\* files in the current folder, you can use:

Unix / Linux:

    for i in CPQ*  
      do  
      /usr/local/sbin/snmpttconvertmib --in=$i --out=snmptt.conf.compaq  
    done  

Windows:

    for %i in (CPQ*) do perl snmpttconvertmib --in=%i --out=snmptt.conf.compaq  

### How it works
   
Some MIB files contain **\--#SUMMARY** and **\--#ARGUMENTS** lines which are used by Novell's Network Management system.  These MIB files convert very well to **SNMPTT** as they contain detailed information that can be used on the **FORMAT** and **EXEC** lines.  Compaq's MIBs usually have these lines.

Other MIBS contain only a **DESCRIPTION** section where the first line contains the **FORMAT** string.  In some MIBS, this line also contains variables similar to the **\--#SUMMARY** lines.

The mib file is searched for the name of the MIB file.  This should be at the top of the file and contain 'name DEFINITIONS ::=BEGIN'.  This name will be used when looking up the TRAP / NOTIFICATION to ensure the correct MIB file is accessed.

The mib file is also searched for lines containing **TRAP-TYPE** or NOTIFICATION-TYPE.  If it finds one that appears to be a valid trap definition, it reads in the following lines until a ::= is found while looking for the **DESCRIPTION** section.  It then looks for the **\--#SUMMARY** and **\--#ARGUMENTS** line if enabled.

**SNMPTRANSLATE** is used with the following syntax to find the **OID** of the trap:

    snmptranslate -IR -Ts mib-name::trapname -m mib-filename

Notes:

* If  Net-SNMP 5.0.2 or newer is detected, the command line also includes the -On switch.  See the [FAQ](file:///h:/cvs/snmptt/readme.html#FAQ-Troubleshooting).
* If **\--#SUMMARY** and **\--#ARGUMENTS** are found, the **%_letter_** variables are replaced with **$_number_** variables based on the values lists in the **\--#ARGUMENTS** section incremented by 1 (ARGUMENTS starts with 0, SNMPTT starts with 1).  This will be used to define the **FORMAT** and **EXEC** lines.
* If there is no **\--#SUMMARY** and **\--#ARGUMENTS** lines, but the first line of the **DESCRIPTION** contains **%_letter_** variables, then that line will be used to define the **FORMAT** and **EXEC** lines.  The **%_letter_** variables are replaced with **$_number_** variables starting at 1 and going up.
* If there is no **\--#SUMMARY** and **\--#ARGUMENTS** lines, and the first line of the **DESCRIPTION** does not contain **%_letter_** variables, then that line will be sed to define the **FORMAT** and **EXEC** lines followed by a **$\*** which will dump all received variables.
* If the entry contains variables, the variables are listed in the DESC section.   If \--net\_snmp\_perl is specified, the syntax, description and enums for each variable is used.
* Note:  This can be changed by specifying a --format=n command line option.  See the snmpttconvertmib help screen for all possible command line options (snmpttconvertmib --h).
