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

Source: tmp.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
BuildArch: noarch

%description
{{ DESC }}

%prep

%build

%install

%clean

%post

%postun

%files
%defattr(-, root, root)

%changelog
