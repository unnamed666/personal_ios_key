#!/bin/bash
security unlock-keychain -p builder_ksmobile $HOME/Library/Keychains/login.keychain
/usr/bin/python $(pwd)/build_keyboard_Enterprise.py
exit $?
