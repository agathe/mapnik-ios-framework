
LIBRARY = libmapnik.a

all: update libmapnik.a
libmapnik.a: build_arches
	echo "Making libmapnik or something"

update:
	git submodule init
	git submodule update

# Build separate architectures
build_arches:
	make ${CURDIR}/build/armv7/lib/libmapnik.a ARCH=armv7

PREFIX = ${CURDIR}/build/${ARCH}
LIBDIR = ${PREFIX}/lib

XCODE_DEVELOPER = $(shell xcode-select --print-path)

IOS_SDK = ${XCODE_DEVELOPER}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk

CXX = ${XCODE_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++
CC = ${XCODE_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
CFLAGS = -isysroot ${IOS_SDK} -I${IOS_SDK}/usr/include -arch ${ARCH}
CXXFLAGS = -stdlib=libc++ -isysroot ${IOS_SDK} -I${IOS_SDK}/usr/include -arch ${ARCH}
LDFLAGS = -stdlib=libc++ -isysroot ${IOS_SDK} -L${IOS_SDK}/usr/lib -L${LIBDIR} -arch ${ARCH}

${LIBDIR}/libmapnik.a: ${LIBDIR}/libpng.a ${LIBDIR}/libproj.a ${LIBDIR}/libtiff.a ${LIBDIR}/libjpeg.a ${LIBDIR}/libicuuc.a
	# Building architecture: ${ARCH}
	cd mapnik && ./configure CXX=${CXX} CC=${CC} \
		CUSTOM_CFLAGS="${CFLAGS} -I${IOS_SDK}/usr/include/libxml2" \
		CUSTOM_CXXFLAGS="${CXXFLAGS} -DUCHAR_TYPE=char16_t -std=c++11 -I${IOS_SDK}/usr/include/libxml2" \
		CUSTOM_LDFLAGS="${LDFLAGS}" \
		FREETYPE_CONFIG=${PREFIX}/bin/freetype-config XML2_CONFIG=/bin/false \
		{LTDL_INCLUDES,OCCI_INCLUDES,SQLITE_INCLUDES,RASTERLITE_INCLUDES}=. \
		{BOOST_PYTHON_LIB,LTDL_LIBS,OCCI_LIBS,SQLITE_LIBS,RASTERLITE_LIBS}=. \
		BOOST_INCLUDES=${PREFIX}/include \
		BOOST_LIBS=${PREFIX}/lib \
		ICU_INCLUDES=${PREFIX}/include \
		ICU_LIBS=${PREFIX}/lib \
		PROJ_INCLUDES=${PREFIX}/include \
		PROJ_LIBS=${PREFIX}/lib \
		PNG_INCLUDES=${PREFIX}/include \
		PNG_LIBS=${PREFIX}/lib \
		CAIRO_INCLUDES=${PREFIX} \
		CAIRO_LIBS=${PREFIX} \
		JPEG_INCLUDES=${PREFIX}/include \
		JPEG_LIBS=${PREFIX}/lib \
		TIFF_INCLUDES=${PREFIX}/include \
		TIFF_LIBS=${PREFIX}/lib \
		INPUT_PLUGINS=shape \
		BINDINGS=none \
		LINKING=static \
		DEMO=no \
		RUNTIME_LINK=static \
		PREFIX=${PREFIX}


# LibPNG
${LIBDIR}/libpng.a:
	cd libpng && env CXX=${CXX} CC=${CC} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" ./configure --host=arm-apple-darwin --disable-shared --prefix=${PREFIX} && make clean install

# LibProj
${LIBDIR}/libproj.a:
	cd libproj && env CXX=${CXX} CC=${CC} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" ./configure --host=arm-apple-darwin --disable-shared --prefix=${PREFIX} && make clean install

# LibTiff
${LIBDIR}/libtiff.a:
	cd libtiff && env CXX=${CXX} CC=${CC} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" ./configure --host=arm-apple-darwin --disable-shared --prefix=${PREFIX} && make clean install

# LibJpeg
${LIBDIR}/libjpeg.a:
	cd libjpeg && env CXX=${CXX} CC=${CC} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" ./configure --host=arm-apple-darwin --disable-shared --prefix=${PREFIX} && make clean install

# LibIcu
libicu_host/config/icucross.mk:
	cd libicu_host && ./configure && make

${LIBDIR}/libicuuc.a: libicu_host/config/icucross.mk
	touch ${CURDIR}/license.html
	cd libicu && env CXX=${CXX} CC=${CC} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS} -std=c++11 -I${CURDIR}/libicu/tools/tzcode" LDFLAGS="${LDFLAGS}" ./configure --host=arm-apple-darwin --disable-shared --enable-static --prefix=${PREFIX} --with-cross-build=${CURDIR}/libicu_host && make clean install

clean:
	rm -rf libmapnik.a
	rm -rf build
	cd libpng && make clean
	cd libproj && make clean
	cd libtiff && make clean
	cd libjpeg && make clean