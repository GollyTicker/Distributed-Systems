

@echo off

:: build.sh for Windows
for %%* in (.) do set CDIR=%%~n*

IF "%CDIR%" == "Distributed-Systems" GOTO WORK
GOTO END

:WORK
RD /S /Q log
MD log

del *.beam

erl -make

copy .nameservice.beam2 nameservice.beam >NUL

:END
