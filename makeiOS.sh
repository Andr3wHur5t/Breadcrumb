#!/bin/bash
# Compiles code using autogen, and make into iOS arctectures.

# Colors
Black='\033[0;30m'
Blue='\033[0;34m'
Green='\033[0;32m'
Cyan='\033[0;36m'
Red='\033[0;31m'
Purple='\033[0;35m'
Orange='\033[0;33m'
LightGray='\033[0;37m'
NC='\033[0m' # No Color


# This script will change the current path so keep a refrence to the orign path
ORIGIN_PATH="${PWD}"

# Arguments used in the script
OUTPUT_DIR="${PWD}/iOS/"
SOURCE_DIR="${PWD}"
OUTPUT_NAME=""
CONFIGURE_SCRIPT_PATH=""
MAKE_DEVICE=0
MAKE_SIMULATOR=0
MIN_SDK="8.0"

# This shows help for the command
show_help () {
    echo -e "Compiles code using autogen, and make into iOS arctectures";
    echo "Copyright (c) 2015 Andrew Hurst <andr3whur5t@live.com> under MIT license.";
    echo "    -h Shows this dialoge.";
    echo "    -n Specifies the expected file name of the output library.";
    echo "    -d compiles for device arctectures (armv7, armv7s, and arm64).";
    echo "    -s compiles for simulator arctectures (x86_64, and i368).";
    echo "    -o The output folder.";
    echo "    -i The source folder.";
}

# This compiles the currently configured arctecture


LIB_NAME="libsecp256k1.a"
#need to set -miphoneos-version-min=${MIN_SDK}

## Compiler Config
# Static Configurations
CC_PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
PHONE_SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/"
SIM_SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/"
CC_FLAGS=" -Wno-error -Wno-implicit-function-declaration  -no-integrated-as"
OUTPUT_SUB_PATH="usr/local/lib/"
HEADER_PATH="/include"

# Process Input
while getopts "hvdsi:o:n:" opt; do
    case "$opt" in
        h)
            show_help
            exit 0
            ;;
        v)  verbose=$((verbose+1))
            ;;
        o)  OUTPUT_DIR=$OPTARG
            ;;
        i)  SOURCE_DIR=$OPTARG
            ;;
        n)  OUTPUT_NAME=$OPTARG
            ;;
        d)  MAKE_DEVICE=1
            ;;
        s)  MAKE_SIMULATOR=1
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done

# Validate Inputs
if [ "${SOURCE_DIR}" == "" ]; then
    echo -e "${Red}A source directory is required.${NC}";
    exit 1;
fi

if [ "${OUTPUT_DIR}" == "" ]; then
    echo -e "${Red}A output directory is required.${NC}";
    exit 1;
fi

if [ "${OUTPUT_NAME}" == "" ]; then
    echo -e "${Red}A output name is required.${NC}";
    exit 1;
fi

if [ "${MIN_SDK}" == "" ]; then
    echo -e "${Red}A min SDK version is required.${NC}";
    exit 1;
fi

# Detect Mode
if [ ${MAKE_DEVICE} -eq 0 ]; then if [ ${MAKE_SIMULATOR} -eq 0 ]; then
    # Inform the user that they should be explicit
    echo -e "${Orange}No modes specified building universal insted.${NC}";
    MAKE_DEVICE=1;
    MAKE_SIMULATOR=1;
fi
fi

# Set correct configurations
CONFIGURE_PATH="${SOURCE_DIR}/configure"
AUTOTOOL_SCRIPT_PATH="${SOURCE_DIR}/configure"

# Output Paths
INTERMEDIATE_DIR="${SOURCE_DIR}/Intermediates"
ARMV7_OUTPUT="${INTERMEDIATE_DIR}/armv7"
ARM64_OUTPUT="${INTERMEDIATE_DIR}/arm64"
SIM86_OUTPUT="${INTERMEDIATE_DIR}/x86_64"
SIM368_OUTPUT="${INTERMEDIATE_DIR}/i368"


# Enter source dir for make
echo -e "${Green}Entering source directory.${NC}"
cd "${SOURCE_DIR}"

# Check For Exsistance of configure script
if [ ! -f "${CONFIGURE_PATH}" ]; then
    echo -e "${Orange}Failed to find configure script Looking for autogen script.${NC}"
    if [ -f "${SOURCE_DIR}/autogen.sh" ]; then
        echo -e "${Green}Executing autogen script.${NC}"
        "${SOURCE_DIR}/autogen.sh"
    else
        echo -e "${Red}Failed to find configure, and autogen script aborting.${NC}"
        cd "${ORIGIN_PATH}"
        exit 1;
    fi
fi


# Perpare Intermediate Directory
if [ ! -d "${INTERMEDIATE_DIR}" ]; then
    echo -e "${Green}Making Intermediate Directory.${NC}"
    mkdir -p "${INTERMEDIATE_DIR}"
fi

# Make Device Arctectures
if [ ${MAKE_DEVICE} -eq 1 ]; then

    # Run Configuration
    echo -e "${Green}Configuring armv7, and armv7s.${NC}"
    ARCH_STRING="-arch armv7s -arch armv7"
    CC_HOST="arm-apple-darwin"
    "${CONFIGURE_PATH}" CC="${CC_PATH}" CFLAGS="-isysroot ${PHONE_SDK_PATH}${CC_FLAGS} -miphoneos-version-min=${MIN_SDK} ${ARCH_STRING}" --host="${CC_HOST}" --enable-static --disable-shared

    echo -e "${Green}Making armv7, and armv7s.${NC}"
    make

    echo -e "${Green}Installing armv7, and armv7s in Intermediates.${NC}"
    make install DESTDIR="${ARMV7_OUTPUT}"

    echo -e "${Green}Perging generated files.${NC}"
    make distclean

    # Verify Output Exsists
    echo "${ARMV7_OUTPUT}/${OUTPUT_SUB_PATH}${OUTPUT_NAME}"
    if [ -f "${ARMV7_OUTPUT}/${OUTPUT_SUB_PATH}${OUTPUT_NAME}" ]; then
        echo -e "${Green}Instalation verified.${NC}";
    else
        echo -e "${Red}Failed to verify instalation aborting.\nEnsure the entered name matches the output name.${NC}";
        cd "${ORIGIN_PATH}"
        exit 1;
    fi



    # Run Configuration arm64
    echo -e "${Green}Configuring arm64.${NC}"
    ARCH_STRING=""
    CC_HOST="none"
    "${CONFIGURE_PATH}" CC="${CC_PATH}" CFLAGS="-isysroot ${PHONE_SDK_PATH}${CC_FLAGS} -target arm64-apple-darwin -miphoneos-version-min=${MIN_SDK} ${ARCH_STRING}" --host="${CC_HOST}" --enable-static --disable-shared

    echo -e "${Green}Making arm64.${NC}"
    make #ARCH=arm64

    echo -e "${Green}Installing armv64 in Intermediates.${NC}"
    make install DESTDIR="${ARM64_OUTPUT}"

    echo -e "${Green}Perging generated files.${NC}"
    make distclean

    # Verify Output Exsists
    echo "${ARM64_OUTPUT}/${OUTPUT_SUB_PATH}${OUTPUT_NAME}"
    if [ -f "${ARM64_OUTPUT}/${OUTPUT_SUB_PATH}${OUTPUT_NAME}" ]; then
        echo -e "${Green}Instalation verified.${NC}";
    else
        echo -e "${Red}Failed to verify instalation aborting.\nEnsure the entered name matches the output name.${NC}";
        cd "${ORIGIN_PATH}"
        exit 1;
    fi
fi

if [ ${MAKE_SIMULATOR} -eq 1 ]; then
    # x86_64
    echo -e "${Green}Configuring x86_64.${NC}"
    ARCH_STRING="-arch x86_64"
    CC_HOST="x86_64-apple-darwin"
    "${CONFIGURE_PATH}" CC="${CC_PATH}" CFLAGS="-isysroot ${SIM_SDK_PATH}${CC_FLAGS} -miphoneos-version-min=${MIN_SDK} ${ARCH_STRING}" --host="${CC_HOST}" --enable-static --disable-shared

    echo -e "${Green}Making x86_64.${NC}"
    make

    echo -e "${Green}Installing x86_64 in Intermediates.${NC}"
    make install DESTDIR="${SIM86_OUTPUT}"

    echo -e "${Green}Perging generated files.${NC}"
    make distclean

    # Verify Output Exsists
    if [ -f "${SIM86_OUTPUT}/${OUTPUT_SUB_PATH}${OUTPUT_NAME}" ]; then
        echo -e "${Green}Instalation verified.${NC}";
    else
        echo -e "${Red}Failed to verify instalation aborting.\nEnsure the entered name matches the output name.${NC}";
        cd "${ORIGIN_PATH}"
        exit 1;
    fi

    # i386
    echo -e "${Green}Configuring i386.${NC}"
    ARCH_STRING="-arch i386"
    CC_HOST="x86_64-apple-darwin"
    "${CONFIGURE_PATH}" CC="${CC_PATH}" CFLAGS="-isysroot ${SIM_SDK_PATH}${CC_FLAGS} -miphoneos-version-min=${MIN_SDK} ${ARCH_STRING}" --host="${CC_HOST}" --enable-static --disable-shared

    echo -e "${Green}Making i386.${NC}"
    make ARCH=i386

    echo -e "${Green}Installing i386 in Intermediates.${NC}"
    make install DESTDIR="${SIM368_OUTPUT}"

    echo -e "${Green}Perging generated files.${NC}"
    make distclean

    # Verify Output Exsists
    if [ -f "${SIM368_OUTPUT}/${OUTPUT_SUB_PATH}${OUTPUT_NAME}" ]; then
        echo -e "${Green}Instalation verified.${NC}";
    else
        echo -e "${Red}Failed to verify instalation aborting.\nEnsure the entered name matches the output name.${NC}";
        cd "${ORIGIN_PATH}"
        exit 1;
    fi
fi


# Create Output Dirs
if [ ! -d "${OUTPUT_DIR}" ]; then
    echo -e "${Green}Creating output directory.${NC}"
    mkdir -p "${OUTPUT_DIR}/${HEADER_PATH}"

    # Verify That it was created
    if [ ! -d "${OUTPUT_DIR}/${HEADER_PATH}" ]; then
        echo -e "${Red}Failed to create output directory aborting.${NC}"
        exit 1;
    fi
fi

# Combine Built Objects
echo -e "${Green}Combining intermediates into a single fat file.${NC}"
lipo -create "${ARMV7_OUTPUT}/${OUTPUT_SUB_PATH}${OUTPUT_NAME}" "${SIM86_OUTPUT}/${OUTPUT_SUB_PATH}${OUTPUT_NAME}" "${SIM368_OUTPUT}/${OUTPUT_SUB_PATH}${OUTPUT_NAME}" "${ARM64_OUTPUT}/${OUTPUT_SUB_PATH}${OUTPUT_NAME}" -output "${OUTPUT_DIR}/${OUTPUT_NAME}"


if  [ -f "${OUTPUT_DIR}/${OUTPUT_NAME}" ]; then
    echo -e "${Green}Validated output.${NC}"
else
    echo -e "${Orange}Failed to validate output.${NC}"
fi

# Copy Headers
echo -e "${Green}Copying headers.${NC}"
cp -R "${ARMV7_OUTPUT}/${OUTPUT_SUB_PATH}..${HEADER_PATH}" "${OUTPUT_DIR}"

# Clean up intermediates
echo -e "${Green}Cleaning up intermedeats.${NC}"
rm -r "${INTERMEDIATE_DIR}"
if [ -d "${INTERMEDIATE_DIR}" ]; then
    echo -e "${Red}Failed to remove intermedate dir!${NC}";
    cd "${ORIGIN_PATH}"
    exit 1;
fi

xcrun -sdk iphoneos lipo -info "${OUTPUT_DIR}${OUTPUT_NAME}"
cd "${ORIGIN_PATH}"


