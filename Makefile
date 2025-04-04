# $NetBSD: Makefile,v 1.39 2025/04/03 01:03:25 schmonz Exp $
#

DISTNAME=		djbdns-run-20250402
CATEGORIES=		net
MASTER_SITES=		# empty
DISTFILES=		# empty

MAINTAINER=		schmonz@NetBSD.org
COMMENT=		Configures djbdns to cache and serve queries
LICENSE=		2-clause-bsd

DEPENDS+=		${DEPENDS_DJBDNS}
DEPENDS+=		daemontools-[0-9]*:../../sysutils/daemontools

WRKSRC=			${WRKDIR}
NO_CHECKSUM=		yes

MAKE_DIRS+=		${PKG_SYSCONFDIR}/axfrdns
MAKE_DIRS+=		${PKG_SYSCONFDIR}/dnscache/ip
MAKE_DIRS+=		${PKG_SYSCONFDIR}/dnscache/servers
MAKE_DIRS+=		${PKG_SYSCONFDIR}/rbldns
MAKE_DIRS+=		${PKG_SYSCONFDIR}/tinydns
PKG_GROUPS=		${DJBDNS_DJBDNS_GROUP}
PKG_USERS+=		${DJBDNS_AXFR_USER}:${DJBDNS_DJBDNS_GROUP}
PKG_USERS+=		${DJBDNS_CACHE_USER}:${DJBDNS_DJBDNS_GROUP}
PKG_USERS+=		${DJBDNS_LOG_USER}:${DJBDNS_DJBDNS_GROUP}
PKG_USERS+=		${DJBDNS_RBL_USER}:${DJBDNS_DJBDNS_GROUP}
PKG_USERS+=		${DJBDNS_TINY_USER}:${DJBDNS_DJBDNS_GROUP}
RCD_SCRIPTS=		djbdns axfrdns dnscache rbldns tinydns
FILES_SUBST+=		DJBDNS_AXFR_USER=${DJBDNS_AXFR_USER:Q}
FILES_SUBST+=		DJBDNS_CACHE_USER=${DJBDNS_CACHE_USER:Q}
FILES_SUBST+=		DJBDNS_LOG_USER=${DJBDNS_LOG_USER:Q}
FILES_SUBST+=		DJBDNS_RBL_USER=${DJBDNS_RBL_USER:Q}
FILES_SUBST+=		DJBDNS_TINY_USER=${DJBDNS_TINY_USER:Q}
FILES_SUBST+=		PKGNAME=${PKGNAME:Q}

INSTALLATION_DIRS=	share/doc/djbdns-run share/examples/djbdns-run
BUILD_DEFS+=		DJBDNS_AXFR_USER DJBDNS_CACHE_USER DJBDNS_LOG_USER
BUILD_DEFS+=		DJBDNS_RBL_USER DJBDNS_TINY_USER
BUILD_DEFS+=		DJBDNS_DJBDNS_GROUP

CONF_FILES+=		${PREFIX}/share/examples/${PKGBASE}/dnsroots.global \
			${PKG_SYSCONFDIR}/dnscache/servers/@
CONF_FILES+=		${PREFIX}/share/examples/${PKGBASE}/axfrdns-tcp \
			${PKG_SYSCONFDIR}/axfrdns/tcp

SUBST_CLASSES+=		rcd
SUBST_STAGE.rcd=	pre-configure
SUBST_FILES.rcd=	README.pkgsrc
SUBST_VARS.rcd=		PKG_SYSCONFDIR RCD_SCRIPTS_DIR

.include "options.mk"

post-extract:
	${CP} ${FILESDIR}/README.pkgsrc ${WRKSRC}/

do-build:
	${TOUCH} ${WRKSRC}/dnscache-ip

do-install:
	${INSTALL_DATA} ${WRKSRC}/README.pkgsrc ${DESTDIR}${PREFIX}/share/doc/djbdns-run
	${INSTALL_DATA} ${WRKSRC}/dnscache-ip ${DESTDIR}${PREFIX}/share/examples/djbdns-run
	${INSTALL_DATA} ${FILESDIR}/axfrdns-tcp ${DESTDIR}${PREFIX}/share/examples/djbdns-run
	${INSTALL_DATA} ${PREFIX}/${DNSROOTS_GLOBAL} ${DESTDIR}${PREFIX}/share/examples/djbdns-run

.include "../../mk/bsd.pkg.mk"
