# grep -Po '^\S+(?=:)' Makefile | tr '\n' ' '
.PHONY: install install-run-manjaro install-dev-manjaro commit test-unit test-integration test-functional test-all test-all-ci test-suite test-tag test-name untested

install:
	DESTDIR="$${DESTDIR:-}" ./install

install-run-manjaro:
	./tools/install-run-manjaro


install-dev-manjaro:
	./tools/install-dev-manjaro

commit:
	git cz

test-unit:
	./tools/bats-unit

test-integration:
	./tools/bats-integration

test-functional:
	./tools/bats-functional

test-all: test-unit test-integration test-functional

# ci server does not support VT-x so we can't run integration or functional tests
test-all-ci: test-unit

test-suite:
	./tools/bats $(u)

test-tag:
	./tools/bats --filter-tags '$(t)' $(u)

test-name:
	./tools/bats --filter '$(n)' $(u)

untested:
	./tools/untested $(f)


