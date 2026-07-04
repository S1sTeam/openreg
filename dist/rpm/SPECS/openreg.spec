Name: openreg
Version: 2.1.0
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
