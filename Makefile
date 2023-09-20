# grep -Po '^\S+(?=:)' Makefile | tr '\n' ' '
.PHONY: install install-tohome install-run-manjaro install-dev-manjaro test-unit test-integration test-functional test-all test-suite test-name commit img-rebuild img-build ct-create ct-start ct-status ct-stop ct-remove ct-login ct-copy-files

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

echo
echo "It's recomended to create a git repository of ~/.ydf-packages"

echo
echo 'DONE'
endef

export script = $(value _script)

install:
	# ENV VARS: DESTDIR
	./install

install-tohome:
	# ENVARS: DESTDIR
	DESTDIR=~/.root ./install
	@eval "$$script"


install-run-manjaro:
	./tools/install-run-manjaro

install-dev-manjaro:
	./tools/install-dev-manjaro

test-unit:
	tools/ct-clean-exec make -f Makefile.vedv test-unit

test-integration:
	tools/ct-clean-exec make -f Makefile.vedv test-integration

test-functional:
	tools/ct-clean-exec make -f Makefile.vedv test-functional

test-all:
	# # MANDATORY ENVARS: OS
	tools/ct-clean-exec make -f Makefile.vedv test-all && \
	./tools/update-pkgs-versions

test-suite:
	tools/ct-clean-exec make -f Makefile.vedv test-suite u='$(u)'

test-name:
	tools/ct-clean-exec make -f Makefile.vedv test-name n='$(n)' u='$(u)'

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
	vedv container remove --force ydf-manjaro-dev

ct-login:
	vedv container login ydf-manjaro-dev

ct-copy-files:
	vedv container copy --no-vedvfileignore ydf-manjaro-dev . .
