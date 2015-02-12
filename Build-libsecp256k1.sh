#!/bin/bash
# This generates the spec256k1 lib

# Create Params
BASE_DIR="${PWD}"
SOURCE_PATH="${BASE_DIR}/secp256k1"
CONFIGURE_PATH="${SOURCE_PATH}/configure"
MIN_SDK="8.0"
OUTPUT_PATH="${BASE_DIR}/libsecp256k1"
HEADER_PATH="/include"
LIB_NAME="libsecp256k1.a"

## Compiler Config
CC_PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
PHONE_SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/"
SIM_SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/"
CC_FLAGS=" -Wno-error -Wno-implicit-function-declaration -miphoneos-version-min=${MIN_SDK}  -no-integrated-as"


## We need to Generate All Architecture
# Output Paths
OUTPUT_SUB_PATH="usr/local/lib/"
BUILD_OUTPUT="${SOURCE_PATH}/output"
ARMV7_OUTPUT="${BUILD_OUTPUT}/armv7/${OUTPUT_SUB_PATH}"
ARM64_OUTPUT="${BUILD_OUTPUT}/arm64/${OUTPUT_SUB_PATH}"
SIM86_OUTPUT="${BUILD_OUTPUT}/x86_64/${OUTPUT_SUB_PATH}"
SIM368_OUTPUT="${BUILD_OUTPUT}/i368/${OUTPUT_SUB_PATH}"

## Check if we actually need to execute
if [ -f "${OUTPUT_PATH}/${LIB_NAME}" ]
    then
    echo "Library already created no need to run."
    xcrun -sdk iphoneos lipo -info "${OUTPUT_PATH}/${LIB_NAME}"
    exit 0
fi


#Use Functions

# Execute auto gen
cd "${SOURCE_PATH}"
# Create config scripts if needed
./autogen.sh


# Configure for armv7 and armv7s
echo "Cleaning..."
cd "${SOURCE_PATH}"
make distclean

echo "Configuring for armv7 and armv7s"
ARCH_STRING="-arch armv7s -arch armv7"
CC_HOST="arm-apple-darwin"
"${CONFIGURE_PATH}" CC="${CC_PATH}" CFLAGS="-isysroot ${PHONE_SDK_PATH}${CC_FLAGS} ${ARCH_STRING}" --host="${CC_HOST}" --enable-static --disable-shared

echo "Making armv7 and armv7s"
make
make install DESTDIR="${SOURCE_PATH}/output/armv7"

# Configure for x86_64
echo "Cleaning..."
cd "${SOURCE_PATH}"
make distclean

echo "Configuring for x86_64"
ARCH_STRING="-arch x86_64"
CC_HOST="x86_64-apple-darwin"
"${CONFIGURE_PATH}" CC="${CC_PATH}" CFLAGS="-isysroot ${SIM_SDK_PATH} ${CC_FLAGS} ${ARCH_STRING}" --host="${CC_HOST}" --enable-static --disable-shared

echo "Making x86_64"
make
make install DESTDIR="${SOURCE_PATH}/output/x86_64"

# Configure for i368
echo "Cleaning..."
cd "${SOURCE_PATH}"
make distclean

echo "Configuring for i368"
"${CONFIGURE_PATH}" CC="${CC_PATH}" CFLAGS="-isysroot ${SIM_SDK_PATH} ${CC_FLAGS} -arch i386" --host="${CC_HOST}" --enable-static --disable-shared

echo "Making i368"
make ARCH=i386
make install DESTDIR="${SOURCE_PATH}/output/i368"


# Configure for arm64
echo "Cleaning..."
cd "${SOURCE_PATH}"
make distclean

##### TODO: ADD arm64
#echo "Configuring for arm64"
#ARCH_STRING="-arch arm64"
#CC_HOST="aarch64-apple-darwin"
#"${CONFIGURE_PATH}" CC="${CC_PATH}" CFLAGS="-isysroot ${PHONE_SDK_PATH}${CC_FLAGS} ${ARCH_STRING}" --host="${CC_HOST}" --enable-static --disable-shared
#
#echo "Making arm64"
#make
#make install DESTDIR="${SOURCE_PATH}/output/64"


## Combine the architectures together into a single lib

echo "Creating output dir."
rm -r "${OUTPUT_PATH}"
mkdir "${OUTPUT_PATH}"


echo "Creating fat library..."
lipo -create "${ARMV7_OUTPUT}${LIB_NAME}" "${SIM86_OUTPUT}${LIB_NAME}" "${SIM368_OUTPUT}${LIB_NAME}" -output "${OUTPUT_PATH}/${LIB_NAME}"
xcrun -sdk iphoneos lipo -info "${OUTPUT_PATH}/${LIB_NAME}"

echo "Copying headers..."
cp -R "${ARMV7_OUTPUT}..${HEADER_PATH}" "${OUTPUT_PATH}/${HEADER_PATH}"

echo "Cleaning up build dirs."
rm -r "${BUILD_OUTPUT}"

echo "Finished '${OUTPUT_PATH}'"
exit 0