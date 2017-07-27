prefix=/usr/local

# files that need mode 755
EXEC_FILES=relasticsearch-document-cleaner

all:
	@echo "usage: make install"
	@echo "       make uninstall"
	@echo "       make reinstall"

help:
	$(MAKE) all

install:
	install -m 0755 $(EXEC_FILES) $(prefix)/bin

uninstall:
	test -d $(prefix)/bin && \
	cd $(prefix)/bin && \
	rm -f $(EXEC_FILES)

reinstall:
	git pull origin master
	$(MAKE) uninstall && \
	$(MAKE) install