#!/usr/bin/env python3

import os
import sys
import shutil
from time import sleep
import inspect
import platform
from getpass import getuser

# Source directory of setuptheos script
ASSETS = os.path.dirname(os.path.realpath(sys.argv[0]))
# Whoami
current_user = getuser()
# run as non root
r_a_n_r = "su " + current_user + " -c"
# Use homebrew to check for package
brew_config = "brew list -1 | grep -q "
# Return the current line as a string
lineno = lambda:inspect.currentframe().f_back.f_lineno
brew_pkgs = ['"bash"','"brew-cask"','"cmake"',
             '"dpkg"','"findutils"','"gawk"',
             '"git"','"grep"','"gzip"','"lzip"',
             '"ldid"','"mysql"','"openssh"',
             '"openssl"','"rsync"','"rzip"','"wget"']

# Simple error handling function
def error_exit(error):
    if error != "":
        print("Error on line:", lineno(), "\n", error, "\n")
        print("Aborting Process...\n\n")
    elif error == "":
        print("Undefined Error...\n"
              "Aborting Process...\n\n")
    else:
        print("Malformed error type...\n"
              "Aborting Process...\n\n")
    sys.exit(1)

# Test to see if this script has root permissions
if os.getuid() != 0:
    print(
        "\nRelaunch this script with sudo.\n")
    sys.exit(1)
print("Setuptheos has root permissions...\n")
sleep(1)

# Check the python executable version
if sys.version_info[0] < 3:
    print("Use python version 3 or later\n")
    sleep(2)
    sys.exit(1)
print("Running on Python 3\n")
sleep(1)

# Checks if device is running OS X (for obvious reasons)
if not platform.system() == "Darwin" and os.name == "posix":
    print("\n\nThis script cannot be run on any Operating System that is not OS X.\n"
          "Run this script on a device running Mac OS X.\n\n")
    error_exit("Unsupported OS...")
print("System OS is OS X\n")
sleep(1)

# Check for Xcode (theos requires it)
print("Checking to see if Xcode is installed...")
if not os.path.isdir("/Applications/Xcode.app"): # or os.path.isdir("~"):
    print("\nTheos requires Xcode, so go and get it\n")
    sys.exit(1)
print("Xcode is installed...\n")
sleep(1)

# Check for, and install Xcode command line tools if not installed
print("Checking to see if Xcode command line tools are installed...")
sleep(2)
os.system('if (xcode-select -p) | grep -q "/Applications/Xcode.app/Contents/Developer" '
          '|| (xcode-select -p) | grep -q "/Library/Developer/CommandLineTools"; '
          'then echo "Xcode Command line tools are installed."; '
          'else xcode-select --install; echo "Xcode Command line tools are installed."; fi')
sleep(1)

# All clear
print("\nAll checks have been completed...")
sleep(2)

# Clear the screen
os.system("clear;clear")

# Configure theos
try:
    os.chdir("/opt")
except Exception as protocol:
    print("Unable to Change directory.")
    error_exit(protocol)
print("\nInstalling theos...\n")
if os.path.isdir("theos"):
    print("Existing version of theos detected.\n")
    print("Removing existing version...\n")
    shutil.rmtree("theos")
    print("Existing versions of theos have been removed")
os.system("git clone --recursive https://github.com/theos/theos.git")
print("\nConfiguring theos environment variable...\n")
os.system('grep -q "export THEOS=/opt/theos" /etc/profile || echo "export THEOS=/opt/theos" >> /etc/profile')
os.system('grep -q "export THEOS=/opt/theos" /etc/bashrc || echo "export THEOS=/opt/theos" >> /etc/bashrc')
print("Configuring additional iOS headers")
shutil.copy(ASSETS + "/writeData.h", "/opt/theos/include/writeData.h")
print("\nSetting Permissions for theos Directory...\n")
os.system("chmod -R 0755 theos")
os.system("chown -R nobody:nobody theos")
print("Configuring NIC templates...")
if not os.path.isdir("/opt/theos/templates/iOSGods"):
    os.mkdir("/opt/theos/templates/iOSGods")
    os.system("cp -f " + ASSETS + "/templates/*.tar /opt/theos/templates/iOSGods/")
    print("\nNic templates have been configured... (Courtesy of iOSGods.com)")
print("\nThe Latest Version of Theos Has Been Successfuly Configured\n")
sleep(2)
# Homebrew utilities configuration
if not os.path.isfile("/usr/local/bin/brew"):
    print("\n\nInstalling homebrew...\n\n")
    sleep(2)
    os.system(r_a_n_r + ' "ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)""')
    print("\n\nHomebrew is now installed.\n")
print("Configuring homebrew packages...\n")
# Iterate through the brew_pkg list, and query the installation status
for pkg in brew_pkgs:
    # Bash will whine if you screw up the quotation syntax below...
    os.system(r_a_n_r + ' "' + brew_config + pkg + ' || brew install ' + pkg + '"')
print("Homebrew packages have been configured...\n")
sleep(2)

# We're all done
print("Theos and friends have been configured\n"
      "Why not thank the author, (KingRalph) with a donation.\n")
sleep(1)

print("\nOperation(s) Completed...\n")
print("Exiting...\n")
sys.exit(0)
