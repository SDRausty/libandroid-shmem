#!/bin/sh

IFS='
'

MYARCH=linux-x86
if uname -s | grep -i "linux" > /dev/null ; then
	MYARCH=linux-x86
fi
if uname -s | grep -i "darwin" > /dev/null ; then
	MYARCH=darwin-x86
fi
if uname -s | grep -i "windows" > /dev/null ; then
	MYARCH=windows-x86
fi

NDK=`which ndk-build`
NDK=`dirname $NDK`
NDK=`readlink -f $NDK`

grep "64.bit" "$NDK/RELEASE.TXT" >/dev/null 2>&1 && MYARCH="${MYARCH}_64"

[ -z "$NDK" ] && { echo "You need Andorid NDK r8 or newer installed to run this script" ; exit 1 ; }
GCCPREFIX=arm-linux-androideabi
GCCVER=4.6
PLATFORMVER=android-14
LOCAL_PATH=`dirname $0`
if which realpath > /dev/null ; then
	LOCAL_PATH=`realpath $LOCAL_PATH`
else
	LOCAL_PATH=`cd $LOCAL_PATH && pwd`
fi
ARCH=armeabi-v7a

CFLAGS="\
-fpic -ffunction-sections -funwind-tables -fstack-protector \
-no-canonical-prefixes -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb \
-fomit-frame-pointer -fno-strict-aliasing -finline-limit=64 -marm -fno-omit-frame-pointer \
-DANDROID -DNDEBUG -O2 -g -finline-functions -Wa,--noexecstack -Wformat -Werror=format-security \
-isystem$NDK/platforms/$PLATFORMVER/arch-arm/usr/include \
-isystem$NDK/sources/cxx-stl/gnu-libstdc++/$GCCVER/include \
-isystem$NDK/sources/cxx-stl/gnu-libstdc++/$GCCVER/libs/$ARCH/include \
$CFLAGS"

UNRESOLVED="-Wl,--no-undefined"
SHARED="-Wl,--gc-sections -Wl,-z,nocopyreloc"
if [ -n "$BUILD_LIBRARY" ]; then
	[ -z "$SHARED_LIBRARY_NAME" ] && SHARED_LIBRARY_NAME=libapplication.so
	SHARED="-shared -Wl,-soname,$SHARED_LIBRARY_NAME"
fi
if [ -n "$ALLOW_UNRESOLVED_SYMBOLS" ]; then
	UNRESOLVED=
fi

LDFLAGS="\
$SHARED \
--sysroot=$NDK/platforms/$PLATFORMVER/arch-arm \
-L$NDK/platforms/$PLATFORMVER/arch-arm/usr/lib \
-lc -lm -ldl -lz \
-L$NDK/sources/cxx-stl/gnu-libstdc++/$GCCVER/libs/$ARCH \
-lgnustl_static \
-march=armv7-a -Wl,--fix-cortex-a8 \
-no-canonical-prefixes $UNRESOLVED -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now \
-lsupc++ \
$LDFLAGS"

env PATH=$NDK/toolchains/$GCCPREFIX-$GCCVER/prebuilt/$MYARCH/bin:$LOCAL_PATH:$PATH \
CFLAGS="$CFLAGS" \
CXXFLAGS="$CXXFLAGS $CFLAGS" \
LDFLAGS="$LDFLAGS" \
CC="$NDK/toolchains/$GCCPREFIX-$GCCVER/prebuilt/$MYARCH/bin/$GCCPREFIX-gcc" \
CXX="$NDK/toolchains/$GCCPREFIX-$GCCVER/prebuilt/$MYARCH/bin/$GCCPREFIX-g++" \
RANLIB="$NDK/toolchains/$GCCPREFIX-$GCCVER/prebuilt/$MYARCH/bin/$GCCPREFIX-ranlib" \
LD="$NDK/toolchains/$GCCPREFIX-$GCCVER/prebuilt/$MYARCH/bin/$GCCPREFIX-ld" \
AR="$NDK/toolchains/$GCCPREFIX-$GCCVER/prebuilt/$MYARCH/bin/$GCCPREFIX-ar" \
CPP="$NDK/toolchains/$GCCPREFIX-$GCCVER/prebuilt/$MYARCH/bin/$GCCPREFIX-cpp $CFLAGS" \
CXXCPP="$NDK/toolchains/$GCCPREFIX-$GCCVER/prebuilt/$MYARCH/bin/$GCCPREFIX-cpp -x c++ $CFLAGS" \
NM="$NDK/toolchains/$GCCPREFIX-$GCCVER/prebuilt/$MYARCH/bin/$GCCPREFIX-nm" \
AS="$NDK/toolchains/$GCCPREFIX-$GCCVER/prebuilt/$MYARCH/bin/$GCCPREFIX-as" \
STRIP="$NDK/toolchains/$GCCPREFIX-$GCCVER/prebuilt/$MYARCH/bin/$GCCPREFIX-strip" \
"$@"
