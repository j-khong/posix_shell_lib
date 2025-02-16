VERSION = $(shell git describe --tags --abbrev=0)
TARFILE = posix_shell_lib-$(VERSION).tar.gz

all: build

build:
	./release/build.sh "$(VERSION)" "$(shell pwd)/dist"
	tar -czvf "$(TARFILE)" -C dist "$(VERSION)"
	rm -fr dist

release: build
	gh release create $(VERSION) $(TARFILE) --title "$(VERSION)" --notes "new version $(VERSION)"

.PHONY: all build release
