PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man

install:
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f rofiles.sh ${DESTDIR}${PREFIX}/bin/rofiles
	chmod 755 ${DESTDIR}${PREFIX}/bin/rofiles
	mkdir -p ${DESTDIR}${MANPREFIX}/man1
	cp -f rofiles.1 ${DESTDIR}${MANPREFIX}/man1
	chmod 644 ${DESTDIR}${MANPREFIX}/man1/rofiles.1

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/rofiles\
		${DESTDIR}${MANPREFIX}/man1/rofiles.1
