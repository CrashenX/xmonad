cmake_minimum_required (VERSION 2.8)
cmake_policy (SET CMP0015 OLD)

set (CMAKE_BUILD_TYPE "" CACHE STRING "")

project (XMONAD)
set (XMONAD_VERSION_MAJOR 1)
set (XMONAD_VERSION_MINOR 0)

set (XMONAD_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/.xmonad/")

# Copy files with 644 permissions
install(FILES xmonad.hs
    DESTINATION ${XMONAD_INSTALL_DIR})

