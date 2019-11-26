set batPath =%~dp0
cd %~dp0

set hour=%time:~,2%
if "%time:~,1%"==" " set hour=0%time:~1,1%
set logDate=%date:~0,4%-%date:~5,2%-%date:~8,2%

python monitor.py
python DingDing.py >> log\log_%logDate%.txt

