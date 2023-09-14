# grep -Po '^\S+(?=:)' Makefile | tr '\n' ' '
.PHONY: install install-run-manjaro install-dev-manjaro commit rebuild build create start status stop remove login test-unit test-integration test-functional test-all test-suite test-name

install:
	DESTDIR="$${DESTDIR:-}" ./install

install-run-manjaro:
	./tools/install-run-manjaro

install-dev-manjaro:
	./tools/install-dev-manjaro

commit:
	git cz

img-rebuild:
	vedv image build --force --no-cache --name ydf-manjaro-dev

img-build:
	vedv image build --force --name ydf-manjaro-dev

ct-create:
	vedv container create --name ydf-manjaro-dev ydf-manjaro-dev

ct-start:
	vedv container start --wait ydf-manjaro-dev

ct-status:
	vedv container ls | grep ydf-manjaro-dev

ct-stop:
	vedv container stop ydf-manjaro-dev

ct-remove:
	vedv container remove --force ydf-manjaro-dev || :

ct-login:
	vedv container login ydf-manjaro-dev

ct-copy-files:
	vedv container copy --no-vedvfileignore ydf-manjaro-dev . .

prepare-test-environment: ct-remove ct-create ct-start ct-copy-files

test-unit: prepare-test-environment
	vedv container exec ydf-manjaro-dev make -f Makefile.vedv test-unit

test-integration:
	vedv container exec ydf-manjaro-dev make -f Makefile.vedv test-integration

test-functional: prepare-test-environment
	vedv container exec ydf-manjaro-dev make -f Makefile.vedv test-functional

test-all: prepare-test-environment
	vedv container exec ydf-manjaro-dev make -f Makefile.vedv test-all

test-suite: prepare-test-environment
	vedv container exec ydf-manjaro-dev make -f Makefile.vedv test-suite u='$(u)'

test-name: prepare-test-environment
	vedv container exec ydf-manjaro-dev make -f Makefile.vedv test-name n='$(n)' u='$(u)'
