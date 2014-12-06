#!@RCD_SCRIPTS_SHELL@
#
# $NetBSD: dnscache.sh,v 1.6 2014/12/06 09:41:04 schmonz Exp $
#
# @PKGNAME@ script to control dnscache (caching DNS resolver)
#

# PROVIDE: dnscache named
# REQUIRE: NETWORKING mountcritremote syslogd
# BEFORE:  DAEMON

name="dnscache"

# User-settable rc.conf variables and their default values:
: ${dnscache_postenv:=""}
: ${dnscache_ip:="127.0.0.1"}
: ${dnscache_ipsend:="0.0.0.0"}
: ${dnscache_size:="1000000"}
: ${dnscache_datalimit:="3000000"}
: ${dnscache_log:="YES"}
: ${dnscache_logcmd:="logger -t nb${name} -p daemon.info"}
: ${dnscache_nologcmd:="@LOCALBASE@/bin/multilog -*"}

if [ -f /etc/rc.subr ]; then
	. /etc/rc.subr
fi

rcvar=${name}
required_dirs="@PKG_SYSCONFDIR@/dnscache/ip @PKG_SYSCONFDIR@/dnscache/servers"
required_files="@PKG_SYSCONFDIR@/dnscache/servers/@"
command="@LOCALBASE@/bin/${name}"
start_precmd="dnscache_precmd"

dnscache_precmd()
{
	if [ -f /etc/rc.subr ]; then
		checkyesno dnscache_log || dnscache_logcmd=${dnscache_nologcmd}
	fi
	if [ ! -f @PKG_SYSCONFDIR@/dnscache/seed ]; then
		old_umask=$(umask)
		umask 066
		dd if=/dev/urandom bs=128 count=1 of=@PKG_SYSCONFDIR@/dnscache/seed
		umask ${old_umask}
	fi
	required_files="${required_files} @PKG_SYSCONFDIR@/dnscache/seed"
	command="@SETENV@ - ${dnscache_postenv} ROOT=@PKG_SYSCONFDIR@/dnscache IP=${dnscache_ip} IPSEND=${dnscache_ipsend} CACHESIZE=${dnscache_size} @LOCALBASE@/bin/envuidgid dnscache @LOCALBASE@/bin/softlimit -o250 -d ${dnscache_datalimit} @LOCALBASE@/bin/dnscache <@PKG_SYSCONFDIR@/dnscache/seed 2>&1 | @LOCALBASE@/bin/setuidgid dnslog ${dnscache_logcmd}"
	command_args="&"
	rc_flags=""
}

if [ -f /etc/rc.subr ]; then
	load_rc_config $name
	run_rc_command "$1"
else
	@ECHO_N@ " ${name}"
	dnscache_precmd
	eval ${command} ${dnscache_flags} ${command_args}
fi
