@echo off
set cdate=%date:~4,2%-%date:~7,2%-%date:~10,4%
set ctime=%time:~0,2%:%time:~3,2%:%time:~6,2%
if not exist "C:\dev\TimeTracker\" mkdir C:\dev\TimeTracker\
if not EXIST "C:\dev\TimeTracker\userlog.csv" type nul>"C:\dev\TimeTracker\userlog.csv"
if "%1"=="li" echo %cdate%,%username%,Logged in,%ctime% >> C:\dev\TimeTracker\userlog.csv
if "%1"=="lo" echo %cdate%,%username%,Logged out,%ctime% >> C:\dev\TimeTracker\userlog.csv
if "%1"=="ls" echo %cdate%,%username%,Locked,%ctime% >> C:\dev\TimeTracker\userlog.csv
if "%1"=="us" echo %cdate%,%username%,Unlocked,%ctime% >> C:\dev\TimeTracker\userlog.csv