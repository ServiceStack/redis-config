SET redis-cli=..\..\bin\windows\x64\redis-cli

%redis-cli% -p 26380 SHUTDOWN NOSAVE
%redis-cli% -p 26381 SHUTDOWN NOSAVE
%redis-cli% -p 26382 SHUTDOWN NOSAVE
%redis-cli% -p 6380 SHUTDOWN NOSAVE
%redis-cli% -p 6381 SHUTDOWN NOSAVE
%redis-cli% -p 6382 SHUTDOWN NOSAVE
