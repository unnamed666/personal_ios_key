#!/bin/bash
security unlock-keychain -p builder_ksmobile $HOME/Library/Keychains/login.keychain
/usr/bin/python $(pwd)/buildHologramDevelop/build_keyboard_development.py
exit $?
