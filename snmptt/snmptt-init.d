#!/bin/bash
# init file for snmptt
# Alex Burger - 8/29/02
# 	      - 9/8/03 - Added snmptt.pid support to Stop function
#
# chkconfig: - 50 50
# description: Simple Network Management Protocol (SNMP) Daemon
#
# processname: /usr/sbin/snmptt
# pidfile: /var/run/snmptt.pid

# source function library
. /etc/init.d/functions

OPTIONS="--daemon"
RETVAL=0
prog="snmptt"

start() {
	echo -n $"Starting $prog: "
        daemon /usr/sbin/snmptt $OPTIONS
	RETVAL=$?
	echo
	touch /var/lock/subsys/snmptt
	return $RETVAL
}

stop() {
	echo -n $"Stopping $prog: "
	killproc /usr/sbin/snmptt 2>/dev/null
	RETVAL=$?
	echo
	rm -f /var/lock/subsys/snmptt
	if test -f /var/run/snmptt.pid ; then
	  [ $RETVAL -eq 0 ] && rm -f /var/run/snmptt.pid
	fi
	return $RETVAL
}

reload(){
        echo -n $"Reloading config file: "
        killproc snmptt -HUP
        RETVAL=$?
        echo
        return $RETVAL
}

restart(){
	stop
	start
}

condrestart(){
    [ -e /var/lock/subsys/snmptt ] && restart
    return 0
}

case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  restart)
	restart
        ;;
  reload)
	reload
        ;;
  condrestart)
	condrestart
	;;
  status)
        status snmptt
	RETVAL=$?
        ;;
  *)
	echo $"Usage: $0 {start|stop|restart|condrestart|reload}"
	RETVAL=1
esac

exit $RETVAL
