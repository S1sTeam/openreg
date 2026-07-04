VERSION := $(shell grep '^VERSION=' openreg.sh | head -1 | sed "s/VERSION=\"\(.*\)\"/\1/")
NAME := openreg
DIST_DIR := dist
DEB_DIR := $(DIST_DIR)/deb
RPM_DIR := $(DIST_DIR)/rpm
APK_DIR := $(DIST_DIR)/apk
TAR_NAME := $(NAME)-$(VERSION)

.PHONY: all clean dist deb rpm apk tar release

all: clean dist deb rpm apk tar

clean:
	rm -rf $(DIST_DIR) *.tar.gz

dist: $(DIST_DIR)
	cp openreg.sh $(DIST_DIR)/$(NAME)
	chmod +x $(DIST_DIR)/$(NAME)

$(DIST_DIR):
	mkdir -p $(DIST_DIR)

# ─── tar.gz ────────────────────────────────────────
tar: dist
	tar -czf $(TAR_NAME).tar.gz -C $(DIST_DIR) $(NAME) openreg.ps1
	@echo "  ✓  $(TAR_NAME).tar.gz"

# ─── .deb ───────────────────────────────────────────
deb: dist
	mkdir -p $(DEB_DIR)/usr/local/bin
	mkdir -p $(DEB_DIR)/DEBIAN
	cp $(DIST_DIR)/$(NAME) $(DEB_DIR)/usr/local/bin/
	cp openreg.ps1 $(DEB_DIR)/usr/local/bin/
	cat > $(DEB_DIR)/DEBIAN/control <<-EOF
Package: $(NAME)
Version: $(VERSION)
Section: utils
Priority: optional
Architecture: all
Depends: bash, curl, warp-cli, proxychains4
Maintainer: S1sTeam
Description: WARP proxy manager for opencode
 Manage Cloudflare WARP from terminal.
 Auto-proxy for opencode — bypass rate limits.
EOF
	cat > $(DEB_DIR)/DEBIAN/postinst <<-'EOF'
#!/bin/sh
set -e
chmod +x /usr/local/bin/openreg /usr/local/bin/openreg.ps1 2>/dev/null || true
echo "  openreg $(VERSION) installed."
echo "  Run 'openreg install' to set up WARP."
EOF
	chmod 755 $(DEB_DIR)/DEBIAN/postinst
	dpkg-deb --build $(DEB_DIR) $(DIST_DIR)/$(NAME)_$(VERSION)_all.deb
	@echo "  ✓  $(NAME)_$(VERSION)_all.deb"

# ─── .rpm ───────────────────────────────────────────
rpm: dist
	mkdir -p $(RPM_DIR)/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
	mkdir -p $(RPM_DIR)/SOURCES/usr/local/bin
	cp $(DIST_DIR)/$(NAME) $(RPM_DIR)/SOURCES/usr/local/bin/
	cp openreg.ps1 $(RPM_DIR)/SOURCES/usr/local/bin/
	cat > $(RPM_DIR)/SPECS/$(NAME).spec <<-EOF
Name: $(NAME)
Version: $(VERSION)
Release: 1
Summary: WARP proxy manager for opencode
License: MIT
URL: https://github.com/S1sTeam/openreg
Group: Applications/System
BuildArch: noarch
Requires: bash, curl, warp-cli, proxychains-ng

%description
Manage Cloudflare WARP from terminal.
Auto-proxy for opencode — bypass rate limits.

%install
mkdir -p %{buildroot}/usr/local/bin
cp %{_sourcedir}/usr/local/bin/openreg %{buildroot}/usr/local/bin/
cp %{_sourcedir}/usr/local/bin/openreg.ps1 %{buildroot}/usr/local/bin/

%files
/usr/local/bin/openreg
/usr/local/bin/openreg.ps1

%post
chmod +x /usr/local/bin/openreg /usr/local/bin/openreg.ps1 2>/dev/null || true

%changelog
* $(date '+%a %b %d %Y') S1sTeam <openreg@s1s.team> - $(VERSION)-1
- Initial release
EOF
	cd $(RPM_DIR) && rpmbuild --define "_topdir $(PWD)/$(RPM_DIR)" -bb SPECS/$(NAME).spec 2>&1 | tail -1
	cp $(RPM_DIR)/RPMS/noarch/$(NAME)-$(VERSION)-1.noarch.rpm $(DIST_DIR)/ 2>/dev/null || true
	@echo "  ✓  $(NAME)-$(VERSION)-1.noarch.rpm"

# ─── .apk (Alpine) ─────────────────────────────────
apk: dist
	which abuild 2>/dev/null || { echo "  abuild not found, skipping apk"; exit 0; }
	mkdir -p $(APK_DIR)/$(NAME)
	cp openreg.sh $(APK_DIR)/$(NAME)/openreg
	cp openreg.ps1 $(APK_DIR)/$(NAME)/
	cat > $(APK_DIR)/$(NAME)/APKBUILD <<-EOF
pkgname=$(NAME)
pkgver=$(VERSION)
pkgrel=1
pkgdesc="WARP proxy manager for opencode"
url="https://github.com/S1sTeam/openreg"
arch="noarch"
license="MIT"
depends="bash curl warp-cli proxychains-ng"
source="openreg openreg.ps1"

build() {
	true
}

package() {
	install -Dm755 "\$srcdir"/openreg "\$pkgdir"/usr/local/bin/openreg
	install -Dm755 "\$srcdir"/openreg.ps1 "\$pkgdir"/usr/local/bin/openreg.ps1
}
EOF
	cd $(APK_DIR) && abuild checksum 2>/dev/null; abuild -r 2>/dev/null
	cp $(APK_DIR)/$(NAME)-$(pkgver)-r*.apk $(DIST_DIR)/ 2>/dev/null || true
	@echo "  ✓  $(NAME)-$(VERSION)-r1.apk"

# ─── GitHub Release ────────────────────────────────
release: all
	@echo "Creating GitHub release v$(VERSION)..."
	gh release create v$(VERSION) \
		--title "openreg v$(VERSION)" \
		--notes "See README for changelog." \
		$(TAR_NAME).tar.gz \
		$(DIST_DIR)/$(NAME)_$(VERSION)_all.deb \
		$(DIST_DIR)/$(NAME)-$(VERSION)-1.noarch.rpm \
		openreg.sh openreg.ps1 2>/dev/null || \
	gh release upload v$(VERSION) \
		$(TAR_NAME).tar.gz \
		$(DIST_DIR)/$(NAME)_$(VERSION)_all.deb \
		$(DIST_DIR)/$(NAME)-$(VERSION)-1.noarch.rpm \
		openreg.sh openreg.ps1 --clobber 2>/dev/null
