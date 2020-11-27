PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man
HOMEDIR = $(shell echo $(shell pwd) | cut -d "/" -f 1-3)
install:
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f rofiles.sh ${DESTDIR}${PREFIX}/bin/rofiles
	chmod 755 ${DESTDIR}${PREFIX}/bin/rofiles
	mkdir -p ${DESTDIR}${MANPREFIX}/man1
	cp -f rofiles.1 ${DESTDIR}${MANPREFIX}/man1
	chmod 644 ${DESTDIR}${MANPREFIX}/man1/rofiles.1
	mkdir -p ${HOMEDIR}/.config/rofiles
	chmod 777 ${HOMEDIR}/.config/rofiles
	touch ${HOMEDIR}/.config/rofiles/config.sh
	chmod 777 ${HOMEDIR}/.config/rofiles/config.sh
	mkdir -p ${HOMEDIR}/.config/rofiles/functions
	chmod 777 ${HOMEDIR}/.config/rofiles/functions

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/rofiles\
		${DESTDIR}${MANPREFIX}/man1/rofiles.1
