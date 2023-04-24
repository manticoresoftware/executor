%define debug_package %{nil}

Summary: {{ DESC }}
Name: {{ NAME }}
Version: {{ VERSION }}
Release: 1%{?dist}
Group: Applications
License: PHP-3.01
Packager: {{ MAINTAINER }}
Vendor: {{ MAINTAINER }}

Source: tmp.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
BuildArch: {{ ARCH }}

%description
{{ DESC }}

%prep
rm -rf %{buildroot}

%setup -n %{name}

%build

%install
mkdir -p %{buildroot}/usr/bin
cp -p usr/bin/manticore-executor %{buildroot}/usr/bin/

%clean
rm -rf %{buildroot}

%post
if [ -f /etc/ssl/cert.pem ]; then
  exit 0
fi

for cert in "/etc/ssl/certs/ca-certificates.crt" \
  "/etc/pki/tls/certs/ca-bundle.crt" \
  "/etc/ssl/ca-bundle.pem" \
  "/etc/pki/tls/cacert.pem" \
  "/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem"; do
  if [ -f "$cert" ]; then
    ln -s "$cert" /etc/ssl/cert.pem
    break
  fi
done

%postun

%files
%doc usr/share/{{ NAME }}-README.md
%license usr/share/{{ NAME }}-LICENSE
%defattr(1755, root, root)
/usr/bin/manticore-executor
