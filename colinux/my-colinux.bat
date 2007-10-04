REM $Id$

cd C:\cygwin\usr\win\bin\coLinux

REM start C:\cygwin\bin\python.exe boot-checker.py

IF EXIST "C:\cygwin\bin\bash.exe" (
  C:\cygwin\bin\run.exe C:\cygwin\bin\bash.exe --login --norc -c "/usr/bin/python /usr/win/bin/coLinux/shproxs.py"
) ELSE (
  REM FIXME: Version number is included, it is not portable.
  C:\cygwin\bin\run.exe C:\cygwin\usr\win\bin\Python2.5\python.exe shproxs.py
)

.\colinux-daemon.exe @my.conf -d

REM __END__
