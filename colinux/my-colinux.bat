REM $Id$

cd C:\cygwin\usr\win\bin\coLinux

net start "CYGWIN sshd"
.\colinux-daemon.exe @my.conf -d
net stop "CYGWIN sshd"

REM __END__
