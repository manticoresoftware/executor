@echo on
@REM https://github.com/actions/runner-images/blob/main/images/win/Windows2022-Readme.md
set PHP_VERSION=%1
set LZ4_REV=8ce521e086fcc4d81c57a60915676673e341ab05
set PHP_SDK_REV=1bb6a4adb5633760d241140ada4dfac3b8d8d2f3
set OS_ARCH=x64
git clone https://github.com/microsoft/php-sdk-binary-tools.git
cd php-sdk-binary-tools
git checkout %PHP_SDK_REV%
@REM "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x86_amd64 10.0.19041.0
set PHP_SDK_OS_ARCH=%OS_ARCH%
set PHP_SDK_ARCH=%OS_ARCH%
set PHP_SDK_VS=vs17

set PHP_SDK_BIN_PATH=%cd%\bin
set PHP_SDK_ROOT_PATH=%cd%
set PHP_SDK_MSYS2_PATH=%PHP_SDK_ROOT_PATH%\msys2\usr\bin
set PHP_SDK_PHP_CMD=%PHP_SDK_BIN_PATH%\php\do_php.bat
set PATH=%PHP_SDK_BIN_PATH%;%PHP_SDK_MSYS2_PATH%;%PATH%

for /f "tokens=1* delims=: " %%a in ('link /?') do ( 
	set PHP_SDK_VC_TOOLSET_VER=%%b
	goto break0
)
:break0

set _=php-dev
md %_%\%PHP_SDK_VS%\%PHP_SDK_ARCH%\deps\bin
md %_%\%PHP_SDK_VS%\%PHP_SDK_ARCH%\deps\lib
md %_%\%PHP_SDK_VS%\%PHP_SDK_ARCH%\deps\include
cd %_%\%PHP_SDK_VS%\%PHP_SDK_ARCH%
set _=

cd php-dev\vs17\x64\
wget "https://windows.php.net/downloads/releases/php-%PHP_VERSION%-src.zip"
unzip php-%PHP_VERSION%-src.zip
del unzip php-%PHP_VERSION%-src.zip
cd "php-%PHP_VERSION%-src"

md dist
set prefix="%cd%\dist"
buildconf --force
configure ^
  --with-prefix=%prefix% --disable-all ^
  --disable-cgi --disable-phpdbg ^
  --with-pcre-jit --enable-cli
set CL=/MP
nmake
nmake install
