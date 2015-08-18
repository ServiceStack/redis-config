@echo off
SET redis-server=..\..\bin\windows\x64\redis-server
SET redis-cli=..\..\bin\windows\x64\redis-cli

start %redis-server% server-6380\redis.conf
start %redis-server% server-6380\sentinel.conf --sentinel

start %redis-server% server-6381\redis.conf
start %redis-server% server-6381\sentinel.conf --sentinel

start %redis-server% server-6382\redis.conf
start %redis-server% server-6382\sentinel.conf --sentinel

echo Press enter to see sentinel info on masters and slaves...
pause

%redis-cli% -p 26380 sentinel master mymaster 
%redis-cli% -p 26381 sentinel slaves mymaster

echo Press enter again to close this window
pause


