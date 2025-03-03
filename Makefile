#
# This makefile is targeted at developers.
# For a one-shot production build, look into Dockerfile.
#

# Used to select commands with different usage under GNU/Linux and *BSD/Darwin
# such as 'sed'.
ifeq ($(shell uname -s),Linux)
  LINUX = true
else
  LINUX = false
endif

# :(
ifeq ($(LINUX),true)
  SED = sed -i -e
else
  SED = sed -i ''
endif

# Routine build. It assumes all dependencies and configuration are already
# in place and correct. It should be fast since it's called often during
# development.
#
.PHONY: build
build:
	$(MAKE) build-core
	$(MAKE) -C toy-matcher
	cd semgrep && pipenv install --dev
	$(MAKE) -C semgrep build

.PHONY: install
install:
	$(MAKE) -C semgrep-core install
	python3 -m pip install semgrep

.PHONY: build-core
build-core:
	$(MAKE) -C semgrep-core
	$(MAKE) -C semgrep-core install

# Update and rebuild everything within the project.
#
.PHONY: rebuild
rebuild:
	git submodule update --init
	-$(MAKE) clean
	$(MAKE) config
	$(MAKE) build

# This is a best effort to install some external dependencies.
# Should run infrequently.
#
.PHONY: setup
setup:
	git submodule update --init
	opam update -y
	./scripts/install-tree-sitter-runtime
	opam install -y --deps-only ./semgrep-core/src/pfff
	opam install -y --deps-only ./semgrep-core/src/ocaml-tree-sitter-core
	opam install -y --deps-only ./semgrep-core

# Install development dependencies in addition to build dependencies.
#
.PHONY: dev-setup
dev-setup:
	$(MAKE) setup
	opam install -y --deps-only ./semgrep-core/dev

# This needs to run initially or when something changed in the external
# build environment. This typically looks for the location of libraries
# and header files outside of the project.
#
.PHONY: config
config:
	cd semgrep-core/src/ocaml-tree-sitter-core && ./configure

# Remove from the project tree everything that's not under source control
# and was not created by 'make setup'.
#
.PHONY: clean
clean:
	-$(MAKE) -C semgrep-core clean
	-$(MAKE) -C semgrep clean

# Same as 'make clean' but may remove additional files, such as external
# libraries installed locally.
#
# Specifically, this removes all files that are git-ignored. New source files
# are preserved, so this command is considered safe.
#
.PHONY: gitclean
gitclean:
	git clean -dfX
	git submodule foreach --recursive git clean -dfX

# Prepare a release branch interactively.
# It's safe to run it multiple times.
.PHONY: release
release:
	./scripts/release/bump

.PHONY: test
test:
	$(MAKE) -C semgrep-core test
	$(MAKE) -C semgrep test
