Summary: {{ DESC }}
Name: {{ NAME }}
Version: {{ VERSION }}
Release: 1%{?dist}
Group: Applications
License: Apache-2.0
Packager: {{ MAINTAINER }}
Vendor: {{ MAINTAINER }}
Requires: {{ EXECUTOR_NAME }} >= {{ EXECUTOR_VERSION }}
Requires: {{ COLUMNAR_NAME }} >= {{ COLUMNAR_VERSION }}
Requires: {{ GALERA_NAME }} >= {{ GALERA_VERSION }}
Requires: {{ LOAD_NAME }} >= {{ LOAD_VERSION }}
Requires: ca-certificates

Source: tmp.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
BuildArch: noarch

%description
{{ DESC }}

%prep
rm -rf %{buildroot}

%setup -n %{name}

%build

%install

%clean
rm -rf %{buildroot}

%post

%postun

%files
%defattr(-, root, root)
%license usr/share/{{ NAME }}-LICENSE

%changelog
