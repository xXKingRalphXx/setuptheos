#!/bin/bash

# Ye olde variables
THEOS="theos"
SDKS="/var/theos/sdks"
ASSETS="/var/mobile/Documents/setuptheosassets"


#Ye olde functions
error_exit() {
  echo "${0}: ${1:-"Unknown Error"}" 1>&2
  exit 1
}

theos() {
  cd /var || error_exit "$LINENO: Unable to Change Directory."
  echo
  echo "Installing theos..."
  echo
  if [ -d "theos" ]; then
    echo "Existing version of theos detected."
    echo
    echo "Removing existing version..."
    echo
    rm -rf theos
    echo "Existing versions of theos have been removed"
    echo
  fi
  echo "Installing theos..."
  # But first, let's disable SSL verification
  git config --global http.sslVerify false
  # Install theos...
  git clone --recursive https://github.com/theos/theos.git
  # Then re-enable it
  git config --global http.sslVerify true
  echo
  echo "Done"
  mv $ASSETS/writedata.h /var/theos/include/writeData.h
  echo
  echo "Configuring theos environment variable..."
  echo
  grep -q "export THEOS=/var/theos" /etc/profile || echo "export THEOS=/var/theos" >> /etc/profile
  echo
  echo "Setting permissions for theos folder..."
  chmod -R 0755 /var/theos
  chown -R nobody:nobody /var/theos
  echo "Done."
  echo
  echo "Signing Binaries..."
  find /usr/bin | ldid -S; find /usr/local/bin | ldid -S;
  echo "Binaries essential for theos functionality have been signed."
  echo
  echo "Theos has been configured..."
  sleep 3s
}

sdk() {
  echo "Installing the latest SDK..."
  echo
  cd /var/theos || error_exit "$LINENO: Unable to Change Directory. Theos is not currently installed..."
  if [ -d "$SDKS" ]; then
    rm -rf -- $SDKS
    mkdir $SDKS
  fi
  echo
  echo "Installing iOS SDK..."
  echo
  cd /var/theos/sdks/ || error_exit "$LINENO: Unable to Change Directory."
  # Tar and curl may screw over if you don't run the following command with su root -c
  su root -c "curl -ksL \"https://sdks.website/dl/iPhoneOS9.2.sdk.tbz2\" | tar -xj -C $THEOS/sdks/"
  echo "The iOS 9.2 SDK has been configured."
}

templates() {
  echo "Installing nic templates..."
  echo
  if [ -d "/var/theos/" ]; then
    cd $ASSETS || error_exit "$LINENO: Unable to Change Directory. Theos is not currently installed..."
    mv -f templates/iphone/*.tar /var/theos/templates/iphone/
    echo
    echo "Nic templates have been configured... (Courtesy of iOSGods.com)"
  else
    echo "ERROR: You must install theos before you can install the NIC templates"
  fi
}

packages() {
  echo "Configuring source files..."
  cd $ASSETS || error_exit "$LINENO: Unable to Change Directory. The asset folder has been (re)moved"
  chmod 0755 setuptheos*.list
  chown mobile:wheel setuptheos*.list
  mv setuptheos*.list /var/mobile/Library/Caches/com.saurik.Cydia/
  cd /var/mobile/Library/Caches/com.saurik.Cydia || error_exit "$LINENO: Unable to Change Directory."
  if grep -q "deb http://coolstar.org/publicrepo/ ./" sources.list; then
     echo "The CoolStar repo is already installed"
  else
     echo "The CoolStar repo is not installed"
     echo "Proceeding to add required sources"
     cat setuptheos-coolstar.list >> sources.list
  fi
  if grep -q "deb http://repo.insanelyi.com/ ./" sources.list; then
     echo "The insanelyi repo is already installed"
  else
     echo "The insanelyi repo is not installed"
     echo "Proceeding to add required sources"
     cat setuptheos-insanelyi.list >> sources.list
  fi
  if grep -q "deb http://cydia.angelxwind.net/ ./" sources.list; then
     echo "The pineapple repo is already installed"
  else
     echo "The pineapple repo is not installed"
     echo "Proceeding to add the pineapple repo to your sources"
     cat setuptheos-karen-tsai.list >> sources.list
  fi
  echo
  echo "Removing source files"
  echo
  rm -rf -- setuptheos*.list
  echo "Done."
  echo "Updating sources..."
  echo
  apt-get update
  echo
  echo "Configuring debian packages..."
  echo
  # Bruh...
  # I'll fix this...later...
  dpkg -l net.angelxwind.mobileterminal-applesdk | grep -q "" && echo "net.angelxwind.mobileterminal-applesdk is installed" || echo "Installing net.angelxwind.mobileterminal-applesdk..." && apt-get install net.angelxwind.mobileterminal-applesdk
  dpkg -l org.coolstar.iostoolchain | grep -q "" && echo "org.coolstar.iostoolchain is installed" || echo "Installing org.coolstar.iostoolchain..." && apt-get install org.coolstar.iostoolchain
  dpkg -l org.coolstar.llvm-clang | grep -q "" && echo "org.coolstar.llvm-clang is installed" || echo "Installing org.coolstar.llvm-clang..." && apt-get install org.coolstar.llvm-clang
  dpkg -l org.coolstar.cctools | grep -q "" && echo "org.coolstar.cctools is installed" || echo "Installing org.coolstar.cctools..." && apt-get install org.coolstar.cctools
  dpkg -l org.coolstar.ld64 | grep -q "" && echo "org.coolstar.ld64 is installed" || echo "Installing org.coolstar.ld64..." && apt-get install org.coolstar.ld64
  dpkg -l org.coolstar.perl | grep -q "" && echo "org.coolstar.perl is installed" || echo "Installing org.coolstar.perl..." && apt-get install org.coolstar.perl
  dpkg -l developer-cmds | grep -q "" && echo "developer-cmds is installed" || echo "Installing developer-cmds..." && apt-get install developer-cmds
  dpkg -l system-cmds | grep -q "" && echo "system-cmds is installed" || echo "Installing system-cmds" && apt-get install system-cmds
  dpkg -l shell-cmds | grep -q "" && echo "shell-cmds is installed" || echo "Installing shell-cmds..." && apt-get install shell-cmds
  dpkg -l class-dump | grep -q "" && echo "class-dump is installed" || echo "Installing class-dump..." && apt-get install class-dump
  dpkg -l diffultils | grep -q "" && echo "diffultils is installed" || echo "Installing diffultils..." && apt-get install diffultils
  dpkg -l ncurses | grep -q "" && echo "ncurses is installed" || echo "Installing ncurses..." && apt-get install ncurses
  dpkg -l rsync | grep -q "" && echo "rsync is installed" || echo "Installing rsync..." && apt-get install rsync
  dpkg -l lzma | grep -q "" && echo "lzma is installed" || echo "Installing lzma..." && apt-get install lzma
  dpkg -l make | grep -q "" && echo "make is installed" || echo "Installing make..." && apt-get install make
  dpkg -l less | grep -q "" && echo "less is installed" || echo "Installing less..." && apt-get install less
  dpkg -l sudo | grep -q "" && echo "sudo is installed" || echo "Installing sudo..." && apt-get install sudo
  dpkg -l gzip | grep -q "" && echo "gzip is installed" || echo "Installing gzip..." && apt-get install gzip
  dpkg -l rzip | grep -q "" && echo "rzip is installed" || echo "Installing rzip..." && apt-get install rzip
  dpkg -l wget | grep -q "" && echo "wget is installed" || echo "Installing wget..." && apt-get install wget
  echo
  echo "All essential debian dependencies have been configured."
}

# Check for root permissions
[ "$(whoami)" != "root" ] && echo "Please aquire root permissions and run this script again" && exit 1

if [ "$1" == "setupAll" ]; then
  echo "Setting up EVERYTHING! >:^D"
  sleep 3s
  theos
  sdk
  templates
  packages
else
echo "What would you like to setup?"
echo "Choose the number that matches your choice"
select OPTION in "theos" "sdk" "templates" "packages" "bugfix" "quit"; do
   case $OPTION in
        theos )
  theos
  echo
  echo
  echo
  echo "Please select a new option."
  echo "Valid Options:"
  echo " 1: theos     "
  echo " 2: sdk       "
  echo " 3: templates "
  echo " 4: packages  "
  echo " 5: bugfix    "
  echo " 6: quit      "

shift;;
        sdk )

  sdk
  echo
  echo
  echo
  echo "Please select a new option."
  echo "Valid Options:"
  echo " 1: theos     "
  echo " 2: sdk       "
  echo " 3: templates "
  echo " 4: packages  "
  echo " 5: bugfix    "
  echo " 6: quit      "

shift;;
        templates )

  templates
  echo
  echo
  echo
  echo "Please select a new option."
  echo "Valid Options:"
  echo " 1: theos     "
  echo " 2: sdk       "
  echo " 3: templates "
  echo " 4: packages  "
  echo " 5: bugfix    "
  echo " 6: quit      "

shift;;
        packages )

  packages
  echo
  echo
  echo
  echo "Please select a new option."
  echo "Valid Options:"
  echo " 1: theos     "
  echo " 2: sdk       "
  echo " 3: templates "
  echo " 4: packages  "
  echo " 5: bugfix    "
  echo " 6: quit      "

shift;;
        bugfix )
echo
echo "This is currently an experimental option that will fix the illegal instruction 4 error."
echo "This option is to be used ONLY IF you get an illegal instruction 4 error while running /var/theos/bin/nic.pl"
echo "Do not select this option if you do not have any errors."
echo
echo "Doing so could be fatal and could harm your device."
echo
sleep 4s
while true; do
   echo "Would you like to proceed?"
    read -r "ERROR"
    case $ERROR in
        [Yy] )
echo "Proceeding to fix illegal instruction 4 error..."
sleep 2s
echo
echo "What is the name of the file causing the error."
read -r LEFILE
echo "Locating cause of error... (This might take a while."
echo "How long this operation takes depends on your device.)"
updatedb
find "$LEFILE"
echo
echo "The path to the file that causing the error was just displayed, Please enter it into the prompt below."
echo "Enter NULL (in capital letters) in the prompt if you want to exit."
echo "NOTE: Please enter the absolute path to the file that causes the error."
echo "Example: /path/to/file.txt"
sleep 2s
while true; do
    echo "What is the absolute path to the file that is causing the error?"
    read -r PATHTOFILE
    case $PATHTOFILE in
        NULL )
echo
echo "Exiting illegal instruction 4 fix option..."
echo
break 1;;
        * )
sed -i 's/\x00\x30\x93\xe4/\x00\x30\x93\xe5/g;s/\x00\x30\xd3\xe4/\x00\x30\xd3\xe5/g;' "$PATHTOFILE"
echo
echo "The illegal instruction 4 error was just fixed."
echo "You're welcome  >:^)"
break 1;;
    esac
done
break 1;;
        [Nn] )
echo
echo "Exiting illegal instruction 4 fix option..."
echo
break 1;;
        * )
echo
echo "Please Choose A Valid Option... (Y/N)"
echo
shift;;
    esac
done
echo
echo
echo
echo "Please select a new option."
echo "Valid Options:"
echo " 1: theos     "
echo " 2: sdk       "
echo " 3: templates "
echo " 4: packages  "
echo " 5: bugfix    "
echo " 6: quit      "

shift;;
        quit )
echo "Exiting program..."

exit;;
        * )
echo
echo
echo
echo "You have selected an invalid option. Please select a valid option"
echo "Valid Options:"
echo " 1: theos     "
echo " 2: sdk       "
echo " 3: templates "
echo " 4: packages  "
echo " 5: bugfix    "
echo " 6: quit      "

shift;;
    esac
done
fi
echo
echo
echo
echo "Theos and essential developer assets have been configured"
echo
echo "Please wait for this program to automatically exit..."
echo
sleep 3s
exit 0
