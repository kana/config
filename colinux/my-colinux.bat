cd C:\cygwin\usr\win\bin\coLinux
REM start C:\cygwin\bin\python.exe boot-checker.py
.\colinux-daemon.exe @my.conf -d

REM IF EXIST "C:\cygwin\bin\bash.exe" (
REM   C:\cygwin\bin\run.exe C:\cygwin\bin\bash.exe --login --norc -c "/usr/bin/python /usr/win/bin/coLinux/shproxs.py"
REM ) ELSE (
REM   :FIXME: Version number is included, it is not portable.
REM   C:\cygwin\bin\run.exe C:\cygwin\usr\win\bin\Python2.5\python.exe shproxs.py
REM )
