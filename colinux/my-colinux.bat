REM $Id$

cd C:\cygwin\usr\win\bin\coLinux

REM net start "CYGWIN sshd"
C:\cygwin\bin\run.exe colinux-daemon.exe @my.conf -d
REM net stop "CYGWIN sshd"

REM __END__
