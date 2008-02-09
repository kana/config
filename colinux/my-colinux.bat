REM $Id$
REM Assumption: CYGWIN sshd is automatically started.
REM Without Cygwin "run" command, the cmd.exe process to execute this bat file
REM will remain until colinux-daemon.exe quits.

cd C:\cygwin\usr\win\bin\coLinux
C:\cygwin\bin\run.exe colinux-daemon.exe @my.conf -d

REM __END__
