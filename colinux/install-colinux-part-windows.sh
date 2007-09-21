#!/bin/bash
# $Id$

INSTALL_DIR='C:\cygwin\usr\win\bin\coLinux'

if [ "$INSTALL_DIR" != $(cygpath -w "$PWD") ]; then
  echo "This script must be executed in $INSTALL_DIR"
  exit
fi

function confirm() {
  echo -n 'Ok? '
  read
}




echo ''
echo '1. Install coLinux (by wizard).'
echo 'Note that:'
echo '- Check Slirp.'
echo '- Uncheck TAP.'
echo '- Uncheck WinPcap.'
confirm




echo ''
echo '2. Create disk images.'
echo '- root.img (Debian-4.0r0-etch.ext3.1gb.bz2)'
confirm
chmod 600 root.img
echo '- swap.img'
fsutil file createnew swap.img $((256 * 1024 * 1024))
chmod 600 swap.img
echo '- home.img'
fsutil file createnew home.img $((1024 * 1024 * 1024))
chmod 600 home.img




echo ''
echo '3. Create configuration file and bat file'
cat >my.conf <<__END__
# my.conf - \$Id\$

kernel=vmlinux

cobd0="$INSTALL_DIR\\root.img"
cobd1="$INSTALL_DIR\\swap.img"
cobd2="$INSTALL_DIR\\home.img"

cofs0="C:\"

root=/dev/cobd0

ro

initrd=initrd.gz

mem=64

# Slirp for internet connection (outgoing)
# Inside running coLinux configure eth0 with this static settings:
# ipaddress 10.0.2.15   broadcast  10.0.2.255   netmask 255.255.255.0
# gateway   10.0.2.2    nameserver 10.0.2.3
eth0=slirp,,tcp:10022:22

# __END__
__END__
chmod 600 my.conf

cat >my-colinux.bat <<__END__
cd $INSTALL_DIR
.\\colinux-daemon.exe @my.conf -d
__END__
chmod 700 my-colinux.bat




echo ''
echo '4. Run coLinux.'
run my-colinux.bat
cygstart colinux-console-nt.exe




echo ''
echo '5. Configure coLinux.'
echo '- This part will be done in coLinux.'
echo '- So you have to execute install-colinux-part-colinux.sh in coLinux.'




# __END__
