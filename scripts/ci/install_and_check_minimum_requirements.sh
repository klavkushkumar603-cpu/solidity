#!/bin/bash
set -ex

# minimum boost version
BOOST_VERSION=1.83

# minimum cmake version
CMAKE_MAJOR=3
CMAKE_MINOR=21
CMAKE_PATCH=3
CMAKE_FULL_VERSION="${CMAKE_MAJOR}.${CMAKE_MINOR}.${CMAKE_PATCH}"

# minimum gcc/clang versions
GCC_VERSION=13.3.0
CLANG_VERSION=18.1.3

# which compiler version to check in this script
CHECK_GCC=false
CHECK_CLANG=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --gcc)
            CHECK_GCC=true
            shift
            ;;
        --clang)
            CHECK_CLANG=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--gcc] [--clang]"
            exit 1
            ;;
    esac
done

echo "-- Removing boost and CMake from the system"
sudo apt-get -qq remove --purge 'libboost*' -y
sudo apt-get -qq remove --purge cmake -y

echo "-- Installing Boost ${BOOST_VERSION}"
sudo apt-get -qq update -y
sudo apt-get -qq install libboost${BOOST_VERSION}-all-dev -y
INSTALLED_BOOST_VERSION=$(dpkg-query --showformat='${Version}' --show libboost${BOOST_VERSION}-all-dev 2>/dev/null || echo "none")
if [[ "$INSTALLED_BOOST_VERSION" != ${BOOST_VERSION}* ]]; then
    echo "Error: installed version of boost is $INSTALLED_BOOST_VERSION, expected $BOOST_VERSION"
    exit 1
fi

echo "-- Installing CMake ${CMAKE_FULL_VERSION}"
wget https://cmake.org/files/v${CMAKE_MAJOR}.${CMAKE_MINOR}/cmake-${CMAKE_FULL_VERSION}-linux-x86_64.tar.gz
tar -xzf cmake-${CMAKE_FULL_VERSION}-linux-x86_64.tar.gz
sudo mv cmake-${CMAKE_FULL_VERSION}-linux-x86_64 /opt/cmake-${CMAKE_FULL_VERSION}
sudo ln -s /opt/cmake-${CMAKE_FULL_VERSION}/bin/* /usr/local/bin/
echo "-- Installed $(cmake --version)"

if [[ "$CHECK_GCC" == true ]]; then
    INSTALLED_GCC_VERSION=$(gcc -dumpfullversion -dumpversion || echo "none")
    if [[ "$INSTALLED_GCC_VERSION" != "$GCC_VERSION" ]]; then
        echo "Error: installed version of gcc is $INSTALLED_GCC_VERSION, expected $GCC_VERSION"
        exit 1
    fi
    echo "-- gcc version check passed: $INSTALLED_GCC_VERSION"
fi

if [[ "$CHECK_CLANG" == true ]]; then
    INSTALLED_CLANG_VERSION=$(clang -dumpfullversion -dumpversion || echo "none")
    if [[ "$INSTALLED_CLANG_VERSION" != "$CLANG_VERSION" ]]; then
        echo "Error: installed version of clang is $INSTALLED_CLANG_VERSION, expected $CLANG_VERSION"
        exit 1
    fi
    echo "-- clang version check passed: $INSTALLED_CLANG_VERSION"
fi
