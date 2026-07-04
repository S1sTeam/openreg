#!/bin/bash
set -e
VERSION=$(grep '^VERSION=' openreg.sh | head -1 | sed 's/VERSION="\(.*\)"/\1/')
NAME="openreg"
DIST="dist"
TAR="$NAME-$VERSION.tar.gz"
echo "Building openreg v$VERSION"
mkdir -p "$DIST"

# tar.gz
cp openreg.sh "$DIST/$NAME"
chmod +x "$DIST/$NAME"
cp openreg.ps1 "$DIST/" && tar -czf "$TAR" -C "$DIST" "$NAME" openreg.ps1
echo "  ✓ $TAR"

# .deb
DEB_DIR="$DIST/deb"
mkdir -p "$DEB_DIR/usr/local/bin" "$DEB_DIR/DEBIAN"
cp "$DIST/$NAME" "$DEB_DIR/usr/local/bin/"
cp openreg.ps1 "$DEB_DIR/usr/local/bin/"
cat > "$DEB_DIR/DEBIAN/control" <<EOF
Package: $NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: all
Depends: bash, curl, warp-cli, proxychains4
Maintainer: S1sTeam
Description: WARP proxy manager for opencode
 Manage Cloudflare WARP from terminal.
 Auto-proxy for opencode — bypass rate limits.
EOF
cat > "$DEB_DIR/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
chmod +x /usr/local/bin/openreg /usr/local/bin/openreg.ps1 2>/dev/null || true
echo "  openreg installed."
echo "  Run 'openreg install' to set up WARP."
EOF
chmod 755 "$DEB_DIR/DEBIAN/postinst"
dpkg-deb --build "$DEB_DIR" "$DIST/${NAME}_${VERSION}_all.deb"
echo "  ✓ ${NAME}_${VERSION}_all.deb"

# .rpm
RPM_DIR="$DIST/rpm"
mkdir -p "$RPM_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
mkdir -p "$RPM_DIR/SOURCES/usr/local/bin"
cp "$DIST/$NAME" "$RPM_DIR/SOURCES/usr/local/bin/"
cp openreg.ps1 "$RPM_DIR/SOURCES/usr/local/bin/"
cat > "$RPM_DIR/SPECS/$NAME.spec" <<EOF
Name: $NAME
Version: $VERSION
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
EOF
if command -v rpmbuild &>/dev/null; then
  cd /tmp/openreg && rpmbuild --define "_topdir $PWD/$RPM_DIR" -bb "$RPM_DIR/SPECS/$NAME.spec" 2>/dev/null
  cp "$RPM_DIR/RPMS/noarch/${NAME}-${VERSION}-1.noarch.rpm" "$DIST/" 2>/dev/null && echo "  ✓ ${NAME}-${VERSION}-1.noarch.rpm"
fi

# release on GitHub
if command -v gh &>/dev/null && gh auth status &>/dev/null; then
  echo "Creating GitHub release v$VERSION..."
  gh release create "v$VERSION" \
    --title "openreg v$VERSION" \
    --notes "See README for full changelog." \
    "$TAR" \
    "$DIST/${NAME}_${VERSION}_all.deb" \
    $(ls "$DIST"/*.rpm 2>/dev/null || true) \
    openreg.sh openreg.ps1 2>/dev/null || \
  gh release upload "v$VERSION" \
    "$TAR" \
    "$DIST/${NAME}_${VERSION}_all.deb" \
    $(ls "$DIST"/*.rpm 2>/dev/null || true) \
    openreg.sh openreg.ps1 --clobber 2>/dev/null
fi

echo "Done."
