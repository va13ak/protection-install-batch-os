CLS
echo on
rem CHCP 1251

SET /P LOGIN= < login
SET /P PASSWORD= < password

SET /P LOGINREP= < login
SET /P PASSWORDREP= < passwordrep


SET FILE4LOG= "scriptlog.log"

REM -- ������ ��� ����᪠����� 䠩�� �।�����
REM SET ONECFILE="C:\Program Files (x86)\1cv82\common\1cestart.exe"
SET ONECFILE="C:\Program Files (x86)\1cv82\8.2.19.130\bin\1cv8.exe"

REM -- ��ࠬ���� ������祭�� � ���� ���䨣��樨
SET BASE=/S"localhost\st13" /N"%LOGIN%" /P"%PASSWORD%"

REM -- ��ࠬ���� ������祭�� � ९������ �࠭���� ���䨣��樨
SET REPOS=/ConfigurationRepositoryF"tcp://10.10.10.2\st_devel" /ConfigurationRepositoryN"%LOGINREP%" /ConfigurationRepositoryP"%PASSWORDREP%"

SET FOLDER4BKUP=E:\Bases1c8\st_devel\
SET FOLDER4DISTR=\\smartlab\ftp_va13ak\st\distribution\1.4.1.6\
SET FOLDER4SETTINGS=C:\Documents and Settings\va13ak\����稩 �⮫\st_distr\

SET FILE4SETTINGS=%FOLDER4SETTINGS%protection-install.properties
SET FILE4RESULT=%FOLDER4SETTINGS%protection-install.result

IF "%time:~0,1%" LSS "1" (
   SET FNAMEDT=%date:~6,4%%date:~3,2%%date:~0,2%-0%time:~1,1%%time:~3,2%
) ELSE (
   SET FNAMEDT=%date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%
)

REM -- ������ ��� ᮧ��������� 䠩�� ������ ���䨣��樨
SET FNAMECONF="%FOLDER4BKUP%bkup_st_%FNAMEDT%.cf"

REM -- ������ ��� ᮧ��������� 䠩�� ������ ���䨣��樨 ����
SET FNAMEDBCONF="%FOLDER4BKUP%bkup_st_%FNAMEDT%_db.cf"

REM -- ������ ��� ᮧ��������� 䠩�� ���⠢�� ���䨣��樨
SET FNAMEDISTR="%FOLDER4DISTR%1Cv8.cf"

SET USER=ww
SET DELEY=300
SET DELEYPINGB=60
SET DELEYPINGF=30
SET DATETIME=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2% %TIME:~0,2%:%TIME:~3,2%:%TIME:~6,2%

echo -------------------------------------------------------------- >>%FILE4LOG%
echo %DATETIME% ����᫠��.. >>%FILE4LOG%
echo %FNAMECONF%


REM -- ���࠭塞 ⥪���� ���䨣���� ��...
echo %DATETIME% ���࠭塞 ⥪���� ���䨣���� ��... >>%FILE4LOG%
%ONECFILE% DESIGNER %BASE% /DumpDBCfg%FNAMEDBCONF% >>%FILE4LOG%

REM -- ���࠭塞 ⥪���� ���䨣����...
echo %DATETIME% ���࠭塞 ⥪���� ���䨣����... >>%FILE4LOG%
%ONECFILE% DESIGNER %BASE% %REPOS% /DumpCfg%FNAMECONF% >>%FILE4LOG%

REM -- ������塞 ⥪���� ���䨣���� �� �࠭���� � ������塞 ���䨣���� ��...
echo %DATETIME% ������塞 ⥪���� ���䨣���� �� �࠭���� � ������塞 ���䨣���� ��... >>%FILE4LOG%
%ONECFILE% DESIGNER %BASE% %REPOS% /ConfigurationRepositoryUpdateCfg -revised -force /UpdateDBCfg >>%FILE4LOG%

REM -- ������� 䠩� ���⠢��...
echo %DATETIME% ������� 䠩� ���⠢��... >>%FILE4LOG%
%ONECFILE% DESIGNER %BASE% %REPOS% /CreateDistributionFiles -cffile%FNAMEDISTR% >>%FILE4LOG%

REM -- ��⠭�������� �����...
echo %DATETIME% ��⠭�������� �����... >>%FILE4LOG%
%ONECFILE% ENTERPRISE /FD:\bases8\WiseAdvise /C"%FILE4SETTINGS%" /OUT"%FILE4RESULT%" >>%FILE4LOG%

REM -- �����㥬 䠩� ���⠢��...
echo %DATETIME% �����㥬 䠩� ���⠢��... >>%FILE4LOG%
%ONECFILE% ENTERPRISE /FD:\bases8\WiseAdvise /C"%FILE4SETTINGS%;%FILE4RESULT%" >>%FILE4LOG%
