# grep -Po '^\S+(?=:)' Makefile | tr '\n' ' '
.PHONY: install uninstall install-tohome install-opt-manjaro install-dev-manjaro install-opt-ubuntu install-dev-ubuntu test-unit test-integration test-functional test-all test-suite test-name commit img-rebuild img-build ct-create ct-start ct-status ct-stop ct-remove ct-login ct-copy-files

include .env

export TEST_OS
export HOST_OS

define _script
#
# Configure ydf on home
#


# Add ~/.root/usr/bin to PATH in ~/.zshrc and ~/.bashrc

if [ -f ~/.zshrc ] && ! grep -q '.root/usr/bin' ~/.zshrc; then
	cat <<'EOF' >>~/.zshrc

export PATH="${HOME}/.root/usr/bin:${PATH}"

EOF

	echo
	echo 'Added ~/.root/usr/bin to PATH in ~/.zshrc'
fi

if [ -f ~/.bashrc ] && ! grep -q '.root/usr/bin' ~/.bashrc; then
	cat <<'EOF' >>~/.bashrc

export PATH="${HOME}/.root/usr/bin:${PATH}"
EOF

	echo
	echo 'Added ~/.root/usr/bin to PATH in ~/.bashrc'
fi

# Copy configuration file from skel
if [ ! -f ~/.ydf.env ]; then
  cp -v ~/.root/etc/skel/.ydf.env ~/

	echo
	echo 'Copied configuration file ~/.ydf.env from skel'
fi

if [ ! -d ~/.ydf-packages ]; then
	mkdir -v ~/.ydf-packages
	echo '/envsubst.env' >~/.ydf-packages/.gitignore

	echo
	echo 'Created ~/.ydf-packages'
fi

echo
echo "It's recomended to create a git repository of ~/.ydf-packages"

echo
echo 'DONE'
endef

export script = $(value _script)

install:
	# ENV VARS: DESTDIR
	./install

uninstall:
	# ENV VARS: DESTDIR
	./uninstall

install-tohome:
	# ENVARS: DESTDIR
	DESTDIR=~/.root ./install
	@eval "$$script"


# install-run-manjaro:
# 	./tools/install-run-manjaro

install-opt-manjaro:
	./tools/install-opt-manjaro

install-dev-manjaro:
	./tools/install-dev-manjaro

# install-run-ubuntu:
# 	./tools/install-run-ubuntu

install-opt-ubuntu:
	./tools/install-opt-ubuntu

install-dev-ubuntu:
	./tools/install-dev-ubuntu

test-unit:
	tools/ct-clean-exec make -f Makefile.vedv test-unit

test-integration:
	tools/ct-clean-exec make -f Makefile.vedv test-integration

test-functional:
	tools/ct-clean-exec make -f Makefile.vedv test-functional

test-all:
	# MANDATORY ENVARS: TEST_OS
	RECREATE_CONTAINER=false tools/ct-clean-exec make -f Makefile.vedv test-all && \
	tools/update-pkgs-dev-host-version && \
	vedv container exec ydf-$(TEST_OS)-dev 'TEST_OS=$(TEST_OS) tools/update-pkgs-test-versions' && \
	vedv container exec ydf-$(TEST_OS)-dev cat packages-opt-$(TEST_OS).versions \
		>packages-opt-$(TEST_OS).versions && \
	vedv container exec ydf-$(TEST_OS)-dev cat packages-run-$(TEST_OS).versions \
			>packages-run-$(TEST_OS).versions || :

	vedv container remove --force ydf-$(TEST_OS)-dev
	vedv container create --name ydf-$(TEST_OS)-dev ydf-$(TEST_OS)-dev
	@echo '>>Starting container in background for the next run. It can take up to 30 seconds for container to be ready'
	vedv container start ydf-$(TEST_OS)-dev &>/dev/null


test-suite:
	tools/ct-clean-exec make -f Makefile.vedv test-suite u='$(u)'

test-name:
	tools/ct-clean-exec make -f Makefile.vedv test-name n='$(n)' u='$(u)'

commit:
	git cz

img-rebuild:
	vedv image build --force --no-cache --name ydf-$(TEST_OS)-dev Vedvfile.$(TEST_OS)

img-build:
	vedv image build --force --name ydf-$(TEST_OS)-dev Vedvfile.$(TEST_OS)

ct-create:
	vedv container create --name ydf-$(TEST_OS)-dev ydf-$(TEST_OS)-dev

ct-start:
	vedv container start --wait ydf-$(TEST_OS)-dev

ct-status:
	vedv container ls | grep ydf-$(TEST_OS)-dev

ct-copy-files:
	vedv container copy --no-vedvfileignore ydf-$(TEST_OS)-dev . .

ct-login:
	vedv container login ydf-$(TEST_OS)-dev

ct-stop:
	vedv container stop ydf-$(TEST_OS)-dev

ct-remove:
	vedv container remove --force ydf-$(TEST_OS)-dev
