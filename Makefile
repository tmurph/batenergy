PKGNAME = system-sleep-debug
PKGVER != cat version
PKGREL != cat release
ARCH = any
PKGFULLNAME := $(PKGNAME)-$(PKGVER)-$(PKGREL)-$(ARCH).pkg.tar.zst

.PHONY: clean

all: $(PKGFULLNAME)

install: $(PKGFULLNAME)
	pacman -U --noconfirm $<

clean:
	rm -f PKGBUILD $(PKGFULLNAME)

data.yml: SHA256SUM != sha256sum batenergy.sh | cut -d' ' -f1
data.yml: version release batenergy.sh
	echo '---' >$@
	echo 'pkgname:' $(PKGNAME) >>$@
	echo 'pkgver:' $(PKGVER) >>$@
	echo 'pkgrel:' $(PKGREL) >>$@
	echo 'arch:' $(ARCH) >>$@
	echo 'sha256sum:' $(SHA256SUM) >>$@
	echo '---' >>$@

PKGBUILD: data.yml PKGBUILD.template
	mustache $^ >$@

$(PKGFULLNAME): PKGBUILD
	makepkg -fc
