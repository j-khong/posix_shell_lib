VERSION = $(shell git describe --tags --abbrev=0)
TARFILE = posix_shell_lib-$(VERSION).tar.gz
DIST_DIR = dist

all: build

build: gen_lib
	@tar -czvf "$(TARFILE)" -C $(DIST_DIR) "$(VERSION)" > /dev/null 2>&1
	@echo "🚀 package generated"
	@rm -fr $(DIST_DIR)

gen_lib:
	if [ -d $(DIST_DIR) ]; then rm -fr $(DIST_DIR); fi
	./release/build.sh "$(VERSION)" "$(shell pwd)/$(DIST_DIR)"

release: build
	gh release create $(VERSION) $(TARFILE) --title "$(VERSION)" --notes "new version $(VERSION)"

tests: gen_lib gen_config
	./tests/run_on_distros.sh

gen_config:
	@echo 'get_lib_root_folder() {' > tests/config.sh
	@echo 'echo "dist/'$(shell git describe --tags --abbrev=0)'"' >> tests/config.sh
	@echo '}' >> tests/config.sh
	@echo '' >> tests/config.sh
	@echo 'get_lib_prefix() {' >> tests/config.sh
	@echo 'echo "posixshell"' >> tests/config.sh
	@echo '}' >> tests/config.sh
	@echo '' >> tests/config.sh


.PHONY: all build release tests


