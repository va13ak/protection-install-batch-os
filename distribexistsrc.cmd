CLS
echo on
rem CHCP 1251

REM %cd% refers to the current working directory (variable)
REM %~dp0 refers to the full path to the batch file's directory (static)
REM %~dpnx0 refers to the full path to the batch directory and file name (static).
REM ECHO %cd% - the current working directory (variable)
REM ECHO %~dp0% - the full path to the batch file's directory (static)
REM ECHO %~dpnx0% - the full path to the batch directory and file name (static)


SET SETTINGSFILE=distrib.settings
FOR /F "eol=# delims== tokens=1,2" %%i IN (%SETTINGSFILE%) DO (
	REM В переменной i - ключ
	REM В переменной j - значение
	REM Мы транслируем это в переменные окружения
	SET %%i=%%j
)


SET FILE4LOG= "scriptlog.log"
SET FILE4DSGLOG="tempdsg.log"

REM -- enterptise executable filename full path
REM SET ONECFILE="C:\Program Files (x86)\1cv82\common\1cestart.exe"
SET ONECFILEENC="C:\Program Files (x86)\1cv82\8.2.19.130\bin\1cv8.exe"
SET ONECFILE="C:\Program Files (x86)\1cv8\8.3.10.2252\bin\1cv8.exe"

REM -- infobase connection parameters
REM SET BASE=/S"localhost\st_devel" /N"%LOGIN%" /P"%PASSWORD%"
SET BASE=/F"E:\v13\st4distr\base" /N"%LOGIN%" /P"%PASSWORD%"

REM -- repository connection parameters
SET REPOS=/ConfigurationRepositoryF"tcp://127.0.0.1:1742\st_devel" /ConfigurationRepositoryN"%LOGINREP%" /ConfigurationRepositoryP"%PASSWORDREP%"

SET SRCFILE="E:\v13\st4distr\source\1Cv8.cf"

SET FOLDER4BKUP=E:\v13\st_devel\
SET FOLDER4DISTR=D:\FTP\va13ak\st\distribution\1.4.1.6\
SET FOLDER4SETTINGS=%~dp0%

SET FILE4SETTINGS=%FOLDER4SETTINGS%protection-install.properties
SET FILE4RESULT=%FOLDER4SETTINGS%protection-install.result

IF "%time:~0,1%" LSS "1" (
   SET FNAMEDT=%date:~6,4%%date:~3,2%%date:~0,2%-0%time:~1,1%%time:~3,2%
) ELSE (
   SET FNAMEDT=%date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%
)

REM -- bkup configuration filename full path
SET FNAMECONF="%FOLDER4BKUP%bkup_st_%FNAMEDT%.cf"

REM -- bkup infobase configuration filename full path
SET FNAMEDBCONF="%FOLDER4BKUP%bkup_st_%FNAMEDT%_db.cf"

REM -- congiguration delivery filename full path
SET FNAMEDISTR="%FOLDER4DISTR%1Cv8.cf"

SET USER=ww
SET DELEY=300
SET DELEYPINGB=60
SET DELEYPINGF=30
SET DATETIME=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2% %TIME:~0,2%:%TIME:~3,2%:%TIME:~6,2%

echo -------------------------------------------------------------- >>%FILE4LOG%
echo %DATETIME% Понеслась.. >>%FILE4LOG%
echo %FNAMECONF%


REM -- updating current configuration from repository and updating infobase configuration...
echo %DATETIME% Обновляем текущую конфигурацию из файла и обновляем конфигурацию БД... >>%FILE4LOG%
%ONECFILE% DESIGNER %BASE% /LoadCfg%SRCFILE% /UpdateDBCfg /DumpResult%FILE4DSGLOG% >>%FILE4LOG%
type %FILE4DSGLOG% >>%FILE4LOG%
echo %DATETIME% %ERRORLEVEL% >>%FILE4LOG%

REM -- deleting old distribution file...
echo %DATETIME% Удаляем старый файл поставки... >>%FILE4LOG%
del /Q %FNAMEDISTR%

REM -- creating distribution file...
echo %DATETIME% Создаем файл поставки... >>%FILE4LOG%
%ONECFILE% DESIGNER %BASE% /CreateDistributionFiles -cffile%FNAMEDISTR% /DumpResult%FILE4DSGLOG% >>%FILE4LOG%
type %FILE4DSGLOG% >>%FILE4LOG%
echo %DATETIME% %ERRORLEVEL% >>%FILE4LOG%


REM -- protecting distribution file...
echo %DATETIME% Устанавливаем защиту... >>%FILE4LOG%
%ONECFILEENC% ENTERPRISE /FE:\v13\WiseAdvise /C"%FILE4SETTINGS%" /OUT"%FILE4RESULT%" >>%FILE4LOG%

REM -- copying distribution file...
echo %DATETIME% Копируем файл поставки... >>%FILE4LOG%
%ONECFILEENC% ENTERPRISE /FE:\v13\WiseAdvise /C"%FILE4SETTINGS%;%FILE4RESULT%" >>%FILE4LOG%
