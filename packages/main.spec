Summary: {{ DESC }}
Name: {{ NAME }}
Version: {{ VERSION }}
Release: 1%{?dist}
Group: Applications
License: PHP 3.01
Packager: {{ MAINTAINER }}
Vendor: {{ MAINTAINER }}

Source: tmp.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
BuildArch: {{ ARCH }}

%description
{{ DESC }}

%prep
rm -rf $RPM_BUILD_ROOT

%setup -n %{name}

%build

%install
mkdir -p $RPM_BUILD_ROOT
cp -p usr/bin/manticore-executor $RPM_BUILD_ROOT/

%clean
rm -rf $RPM_BUILD_ROOT

%post

%postun

%files
%defattr(-, root, root)
/manticore-executor

%changelog
