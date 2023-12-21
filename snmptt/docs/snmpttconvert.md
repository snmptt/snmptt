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
<title>SNMP Trap Translator Convert</title>
</head>

#SNMP Trap Translator Convert v1.5

**(**[**SNMPTTCONVERT**](http://www.snmptt.org)**)**  
This file was last updated on:  August 30th, 2004

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
 

#SNMPTTCONVERT

Some vendors provide a file that can be imported into HP Openview using a HP Openview utiltity.  SNMPTTCONVERT is a simple Perl script which will convert one of these files into the format used by SNMPTT.  The file can contain multiple traps.

For example, if the file ciscotrap.txt contained:

     rpsFailed {.1.3.6.1.4.1.437.1.1.3} 6 5 - "Status Events" 1  
     Trap received from enterprise $E with $# arguments: sysName=$1  
     SDESC  
     "A redundant power source is connected to the switch but a failure exists in  
     the power system."  
     EDESC

Executing snmpttconvert ciscotrap.txt would output:

     #  
     #  
     #  
     EVENT rpsFailed .1.3.6.1.4.1.437.1.1.3.0.5 "Status Events" Normal  
     FORMAT Trap received from enterprise $E with $# arguments: sysName=$1  
     #EXEC qpage -f TRAP notifygroup1 "Trap received from enterprise $E with $# arguments: sysName=$1"  
     SDESC  
     "A redundant power source is connected to the switch but a failure exists in  
     the power system."  
     EDESC
  
Note:  The #EXEC line is added by default.  This can be changed by editing the SNMPTTCONVERT script.