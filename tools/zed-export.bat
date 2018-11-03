@echo off

cd %~dp0
cd C:\Program Files (x86)\ZED SDK\samples\bin

echo ...............................................
echo 0 - H.264 AVI, left + right
echo 1 - H.264 AVI, left + depth
echo 2 - 8bpc PNG sequence, left + right
echo 3 - 8bpc PNG sequence, left + depth
echo 4 - 16bpc PNG sequence, left + depth
echo ...............................................

SET /P M=Type 0, 1, 2, 3, or 4 and press ENTER:
IF %M%==0 GOTO DO_0
IF %M%==1 GOTO DO_1
IF %M%==2 GOTO DO_2
IF %M%==3 GOTO DO_3
IF %M%==4 GOTO DO_4

:DO_0
ZED_SVO_Export %1 %1.avi 0
goto END

:DO_1
ZED_SVO_Export %1 %1.avi 1
goto END

:DO_2
mkdir %~p1\frames
ZED_SVO_Export %1 %~p1\frames\ 2
goto END

:DO_3
mkdir %~p1\frames
ZED_SVO_Export %1 %~p1\frames\ 3
goto END

:DO_4
mkdir %~p1\frames
ZED_SVO_Export %1 %~p1\frames\ 4
goto END

:END
@pause