::
::	БАТЧХ АПКТООЛ by BurSoft
::
@echo off
set colB=07
set colG=0A
set colR=0C
COLOR %colB%
set "dp0dir=%~dp0"
set "rootdir=%dp0dir:~0,-4%"
setLocal EnableExtensions EnableDelayedExpansion
set PATH=!dp0dir!;!dp0dir!jre\bin;!PATH!;!SystemRoot!\Sysnative;!SystemRoot!\system32;!SystemRoot!\SysWOW64
set PATHEXT=.COM;.EXE;!PATHEXT!
mode con:cols=105 lines=48
if not "%~1"=="launcher" (
	for /f "tokens=2 delims=," %%a in ('tasklist /V /FI "IMAGENAME eq cmd.exe" /FO CSV /NH ^| find /I "BAT by BurSoft"') do (
		nircmdc win activate process /%%~a
		nircmdc win flash process /%%~a 2
		goto:eof
	)
)
::	set xOS=(x64)& if %PROCESSOR_ARCHITECTURE%==x86 if not defined PROCESSOR_ARCHITEW6432 set xOS=
set title_text=BAT by BurSoft
title !title_text!
cd /d "!dp0dir!"
if not exist language\english.lng (
	COLOR !colR!
	echo ERROR^^!
	echo Batch ApkTool is not fully installed or do not have full access to the folder
	PAUSE
	goto:eof
)
if exist language\lang (
	for /F "usebackq tokens=1* delims==" %%a in ("language\lang") do set %%a=%%b
) else (
	for /f "delims=" %%a in ('chcp') DO set x=%%a
	if not !x!==!x:866=! (set language=russian) else (set language=english)
)
call :__language
set bat_version=3.4.5
set bat_title=                                     BATCH APKTOOL %bat_version% by BurSoft                                     
set bat_page=                                  http://bursoft-portable.blogspot.com
set bat_line=--------------------------------------------------------------------------------------------------------
set logR=log_recompile.txt
set logD=log_decompile.txt
set TEMP=!TEMP!\BAT_temp
set TMP=!TMP!\BAT_temp
set JAVA_TOOL_OPTIONS=
set _JAVA_OPTIONS=
set workdir=.
if exist settings.ini (
	for /f "delims=" %%a in ('inifile settings.ini [global_settings]') do %%a
)
COLOR %colB%
cd /d "%rootdir%"
if errorlevel 1 (
	COLOR !colR!
	echo !str_error!
	echo !str_startup_error1!
	PAUSE
	goto:eof
)
md write_test
if errorlevel 1 (
	COLOR !colR!
	echo !str_error!
	echo !str_startup_error2!
	PAUSE
	goto:eof
) else (
	rd write_test
)
md "!TEMP!" "!TMP!" 2>nul
if not exist bin\language\lang (
	set bindir=bin\
	call :setlanguage
)
if "%~1"=="launcher" (
	set jv=%~2
	set ju=u%~3
	if not "%~4"=="" set jx= %~4
	goto SkipJava
)
for /f "delims=" %%a in ('java -version 2^>^&1') DO (
::	for /f tokens^=1^,2^ delims^=^" %%b in ("%%a") do (	rem workaround for delims = "
	for /f "tokens=1,2,3 delims= " %%b in ("%%a") do (
		if /I "%%b %%c"=="java version" (
			for /f "tokens=1* delims=_-" %%e in ("%%~d") do (
				set ju=u%%f
				for /f "tokens=1,2 delims=." %%g in ("%%e") do (
					set jv=%%h
				)
			)
		)
	)
	set x=%%a
	if not !x!==!x:64-Bit=! (set jx= x64)
)
:SkipJava
if defined jv (
	set title_text=!title_text! (Java !jv!!ju!!jx!^)
	title !title_text!
	if !jv! LSS 7 (
		cecho {!colR!}!str_previous_java1! !jv!!ju!{# #}{\n}
		cecho {!colR!}!str_previous_java2!{# #}{\n}
		echo !str_get_java!
		PAUSE
	)
) else (
	cecho {!colR!}!str_java_notfound!{# #}{\n}
	echo !str_get_java!
	PAUSE
)
:restart3
cd /d "!rootdir!"
set apktool=apktool_2.1.1.jar
set smali=smali-2.1.2.jar
set api=23
set sign_after=ON
set open_log=MANUAL
set adb_ip=
set apk_name=*
set jar_name=*
set keepbrokenres=ON
set deldebuginfo=OFF
set expert_mode=OFF
set key_name=testkey.pk8
set bindir=bin\
set projdir=..
set framedir=_framework
if not "!workdir!"=="." (
	if exist "!workdir!" (
		cd "!workdir!"
		set bindir=..\bin\
		set projdir=..\!workdir!
	) else (
		set workdir=.
		call :saveglobal "workdir"
	)
)
md _app _framework _INPUT_APK _INPUT_JAR _OUT_APK _OUT_JAR _priv-app 2>nul
if exist batchapktool.ini (
	for /f "delims=" %%a in ('inifile batchapktool.ini [settings]') do %%a
)
if not exist "%bindir%!apktool!" (
	set apktool=apktool_2.1.1.jar
	call :savesettings "apktool" "wait"
)
if not exist "%bindir%!smali!" (
	set smali=smali-2.1.2.jar
	call :savesettings "smali" "wait"
)
:restart2
set apk_base=*
if not "!apk_name!"=="*" (
	if exist "_INPUT_APK\!apk_name!" (
		FOR %%F IN ("!apk_name!") DO set apk_base=%%~nF
	) else (
		set apk_name=*
		call :savesettings "apk_name" "wait"
	)
)
set jar_base=*
if not "!jar_name!"=="*" (
	if exist "_INPUT_JAR\!jar_name!" (
		FOR %%F IN ("!jar_name!") DO set jar_base=%%~nF
	) else (
		set jar_name=*
		call :savesettings "jar_name" "wait"
	)
)
FOR %%F IN ("!key_name!") DO set key_base=%%~nF
:restart
cls
COLOR %colB%
title !title_text!
echo.
cecho {!colG!}!bat_title!{# #}{\n}
echo !bat_page!
echo !bat_line!
echo   80  !str_project! : !workdir!
echo   81  !str_currentapk! : !apk_name!
echo   82  !str_currentjar! : !jar_name!
echo   83  SMALI                                        : !smali!
echo   84  - !str_apilevel! : %api%
echo   85  APKTOOL                                      : !apktool!
echo   86  - !str_keepbroken! : !str_%keepbrokenres%!
echo   87  - !str_buildexpert! : !str_%expert_mode%!
echo   88  !str_dontwritedebug! : !str_%deldebuginfo%!
echo   89  !str_signafter! : !str_%sign_after%!
echo   90  - !str_key! : !key_name!
echo   91  !str_openlog! : !str_%open_log%!
echo   92  !str_language! : !language!
echo !bat_line!
cecho {!colG!}SMALI:{# #}{\n}
echo   01  !str_deodexall! 04  !str_baksmaliapk!
echo   02  !str_copy_deodexed_apk! 05  !str_smaliapk!
echo   03  !str_copy_deodexed_jar! 06  !str_baksmalijar!
echo                                                    07  !str_smalijar!
echo !bat_line!
cecho {!colG!}APKTOOL:{# #}{\n}
echo   1   !str_decompile! 4   !str_signfiles!
echo   2   !str_decompile_r! 5   !str_zipalfiles!
echo   3   !str_recompile! 6   !str_viewsource!
echo                                                    7   !str_plugins!
echo !bat_line!
cecho {!colG!}!str_adbmenu!{# #}{\n}
echo   10  !str_devices! 16  !str_screenrecord!
echo   11  !str_install! 17  !str_shell!
echo   12  !str_rootremount! 18  !str_logs!
echo   13  !str_pull! 19  !str_reboot!
echo   14  !str_push! 20  !str_info!
echo   15  !str_screenshot! 21  !str_kill-server!
echo !bat_line!
cecho {!colG!}!str_servicemenu!{# #}{\n}
echo   30  !str_cleanup1! 32  !str_cleanup3!
echo   31  !str_cleanup2! 33  !str_cleanup4!
echo !bat_line!
echo.
SET INPUT=
SET /P INPUT=!str_choosetask! 
IF /I !INPUT!==bat (goto about)
IF !INPUT!==80 (goto setproject)
IF !INPUT!==81 (goto setcurrentapk)
IF !INPUT!==82 (goto setcurrentjar)
IF !INPUT!==83 (goto setsbversion)
IF !INPUT!==84 (goto setapi)
IF !INPUT!==85 (goto setapktoolversion)
IF !INPUT!==86 (goto setkeepbrokenres)
IF !INPUT!==87 (goto setexpert_mode)
IF !INPUT!==88 (goto setdeldebuginfo)
IF !INPUT!==89 (goto setsign)
IF !INPUT!==90 (goto setsignkey)
IF !INPUT!==91 (goto setlog)
IF !INPUT!==92 (call :setlanguage) & goto restart
IF !INPUT!==01 (goto deodex)
IF !INPUT!==02 (call :copy_files "_app _priv-app _framework" .apk) & goto restart
IF !INPUT!==03 (call :copy_files _framework .jar) & goto restart
IF !INPUT!==04 (goto baksmaliapk)
IF !INPUT!==05 (goto smaliapk)
IF !INPUT!==06 (goto baksmalijar)
IF !INPUT!==07 (goto smalijar)
IF !INPUT!==1 (set opt=& goto decompile)
IF !INPUT!==2 (set opt=-s& goto decompile)
IF !INPUT!==3 (goto recompile)
IF !INPUT!==4 (goto signzip)
IF !INPUT!==5 (goto zipalignoutapks)
IF !INPUT!==6 (goto javasource)
IF !INPUT!==7 (goto plugins)
IF !INPUT!==10 (goto adbdevices)
IF !INPUT!==11 (goto adbinstall)
IF !INPUT!==12 (goto adbremount)
IF !INPUT!==13 (goto adbpull)
IF !INPUT!==14 (goto adbpush)
IF !INPUT!==15 (goto adbscreenshot)
IF !INPUT!==16 (goto screenrecord)
IF !INPUT!==17 (goto adbshell)
IF !INPUT!==18 (goto adblogs)
IF !INPUT!==19 (goto adbreboot)
IF !INPUT!==20 (goto adbinfo)
IF !INPUT!==21 (goto adbexit)
IF !INPUT!==30 (call :clean "_app _priv-app _framework") & goto restart
IF !INPUT!==31 (call :clean "_INPUT_APK _INPUT_JAR") & goto restart2
IF !INPUT!==32 (call :clean "_OUT_APK _OUT_JAR") & goto restart
IF !INPUT!==33 (call :clean "_app _priv-app _framework _INPUT_APK _INPUT_JAR _OUT_APK _OUT_JAR") & goto restart2
goto restart
:: --------------------
:plugins
cecho {!colG!}  !str_selplugin!{# #}{\n}
set count=0
FOR /D %%F IN (%bindir%plugins\*) DO (
	set /A count+=1
	set name!count!=%%~nxF
	set plugin_name=%%~nxF
	if not "!language!"=="english" (
		if exist "%bindir%plugins\%%~nxF\language\!language!.lng" (
			for /F "eol=; tokens=1* delims==" %%a in ('type "%bindir%plugins\%%~nxF\language\!language!.lng"') do (
				if "%%a"=="plugin_name" set %%a=%%b
			)
		)
	)
	if "!plugin_name!"=="%%~nxF" (
		if exist "%bindir%plugins\%%~nxF\language\english.lng" (
			for /F "eol=; tokens=1* delims==" %%a in ('type "%bindir%plugins\%%~nxF\language\english.lng"') do (
				if "%%a"=="plugin_name" set %%a=%%b
			)
		)
	)
	echo    !count! = !plugin_name!
	set /A MOD=!count! %% 45
	if !MOD! equ 0 pause
)
echo.
set /A count+=1
set name!count!=select_cancel
echo    !count! = !str_cancel!
:_plugins
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT! GTR !count! (goto _plugins)
if !INPUT! LSS 1 (goto _plugins)
if !name%INPUT%!==select_cancel goto restart
set plugdir=!dp0dir!plugins\!name%INPUT%!\
if exist "!plugdir!system" (
	set system_plugin=1
) else (
	set system_plugin=0
	setLocal
)
if "!PATH!"=="!PATH:%plugdir%=!" (set PATH=!plugdir!;!PATH!)
if exist "!plugdir!language\english.lng" (
	for /F "eol=; tokens=1* delims==" %%a in ('type "!plugdir!language\english.lng"') do set str_%%a=%%b
)
if not "!language!"=="english" (
	if exist "!plugdir!language\!language!.lng" (
		for /F "eol=; tokens=1* delims==" %%a in ('type "!plugdir!language\!language!.lng"') do set str_%%a=%%b
	)
)
call "!plugdir!plugin.bat"
if !system_plugin!==0 endLocal
goto restart
:: --------------------
:install_framework
call :log_version "%~1"
if "!apktool:~8,1!"=="1" (
	del /f /q "%USERPROFILE%\apktool\framework\*.apk" 2>nul
) else (
	del /f /q "%bindir%framework\*.apk" 2>nul
)
FOR /f "delims=" %%F IN ('sfk list -hidden -quiet -quot "!framedir!" .apk 2^>nul') DO (
	cecho [*] !str_instframe! %%~nxF...
	echo [*] !str_instframe! %%~nxF>>%~1
	if "!apktool:~8,1!"=="1" (
		java -jar "%bindir%!apktool!" if "%%~F" >>%~1 2>&1
	) else (
		java -jar "%bindir%!apktool!" if -p "%bindir%framework" "%%~F" >>%~1 2>&1
	)
	if errorlevel 1 (
		set /A count+=1
		cecho {!colR!} !str_error!{# #}{\n}
		echo [*] ---^> !str_instframe_error! %%~nxF>>%~1
	) else (
		echo.
	)
)
goto:eof
:decompile
set count=0
call :install_framework "%logD%"
if %keepbrokenres%==ON (set opt=--keep-broken-res %opt%)
if %deldebuginfo%==ON (set opt=-b %opt%)
set count2=0
set count3=0
FOR %%F IN ("_INPUT_APK\!apk_base!.apk") DO (set /A count2+=1)
if %count2%==0 (
	cecho {!colR!}[*] !str_inputapk_empty!{# #}{\n}
	pause
	goto restart
)
FOR %%F IN ("_INPUT_APK\!apk_base!.apk") DO (
	set /A count3+=1
	title !title_text! [!count3!/!count2!]
	cecho [*] !str_decompiling! %%~nxF...
	echo.>>%logD%
	echo [*] !str_decompiling! %%~nxF>>%logD%
	rd /s /q "_INPUT_APK\%%~nF" 2>nul
	if "!apktool:~8,1!"=="1" (
		java -jar "%bindir%!apktool!" d -f %opt% "_INPUT_APK\%%~nxF" "_INPUT_APK\%%~nF" >>%logD% 2>&1
	) else (
		java -jar "%bindir%!apktool!" d -f %opt% -o "_INPUT_APK\%%~nF" -p "%bindir%framework" "_INPUT_APK\%%~nxF" >>%logD% 2>&1
	)
	if errorlevel 1 (
		set /A count+=1
		cecho {!colR!} !str_error!{# #}{\n}
		echo [*] ---^> !str_decompiling_error! %%~nxF>>%logD%
	) else (
		echo.
	)
	md "_INPUT_APK\%%~nF\_backup" 2>nul
	FOR %%a IN (assets lib libs original res unknown) DO (
		xcopy "_INPUT_APK\%%~nF\%%a" "_INPUT_APK\%%~nF\_backup\%%a\" /e /h /i /r /q /y >nul 2>nul
	)
	FOR %%a IN (AndroidManifest.xml apktool.yml) DO (
		copy "_INPUT_APK\%%~nF\%%a" "_INPUT_APK\%%~nF\_backup\" >nul
	)
	FOR /D %%S IN ("_INPUT_APK\%%~nF\smali*") DO (
		md "_INPUT_APK\%%~nF\_backup\%%~nxS" 2>nul
		sfk list -time -size -stat -hidden -quiet -relnames "_INPUT_APK\%%~nF\%%~nxS">"_INPUT_APK\%%~nF\_backup\%%~nxS\list.txt" 2>nul
	)
	7za x "_INPUT_APK\%%~nxF" -o"_INPUT_APK\%%~nF\_backup" *.dex -aoa >nul 2>>%logD%
	ATTRIB +H "_INPUT_APK\%%~nF\_backup" >nul
)
call :done "%logD%"
goto restart
:recompile
rd /s /q "!TMP!" 2>nul
md "!TMP!" 2>nul
set count=0
call :install_framework "%logR%"
set count2=0
set count3=0
FOR /D %%F IN ("_INPUT_APK\!apk_base!") DO (set /A count2+=1)
FOR /D %%F IN ("_INPUT_APK\!apk_base!") DO (
if not "%%~nxF"=="_RES_REPLACE" (
	set /A count3+=1
	title !title_text! [!count3!/!count2!]
	cecho [*] !str_recompiling! %%~nxF...
	echo.>>%logR%
	echo [*] !str_recompiling! %%~nxF>>%logR%
	rd /s /q "_INPUT_APK\%%~nxF\build" "_INPUT_APK\%%~nxF\dist" 2>nul
	FOR /D %%S IN ("_INPUT_APK\%%~nxF\smali*") DO (
		sfk list -time -size -stat -hidden -quiet -relnames "_INPUT_APK\%%~nxF\%%~nxS">"_INPUT_APK\%%~nxF\_backup\%%~nxS\list2.txt" 2>nul
		sfk md5 "_INPUT_APK\%%~nxF\_backup\%%~nxS\list.txt" "_INPUT_APK\%%~nxF\_backup\%%~nxS\list2.txt" >nul 2>nul
		if not errorlevel 1 (
			ren "_INPUT_APK\%%~nxF\%%~nxS" "bat_%%~nxS" 2>nul
		)
		del /f /q "_INPUT_APK\%%~nxF\_backup\%%~nxS\list2.txt" 2>nul
	)
	FOR %%S IN ("_INPUT_APK\%%~nxF\*.dex") DO (
		ren "_INPUT_APK\%%~nxF\%%~nxS" "%%~nS.bat_dex" 2>nul
	)
	if "!apktool:~8,1!"=="1" (
		call :rebuild_1 "%%~nxF"
	) else (
		if "%expert_mode%"=="ON" (call :rebuild_1 "%%~nxF") else (call :rebuild_2 "%%~nxF")
	)
	if exist "_INPUT_APK\%%~nxF\dist\%%~nxF.apk" (
		if %sign_after%==ON (
			call :sign "_INPUT_APK\%%~nxF\dist\%%~nxF.apk" "%%~nxF.apk"
		) else (
			zipalign -f 4 "_INPUT_APK\%%~nxF\dist\%%~nxF.apk" "_OUT_APK\%%~nxF.apk" 2>nul
		)
	)
	FOR /D %%S IN ("_INPUT_APK\%%~nxF\bat_*") DO (
		set REN2=%%~nxS
		ren "_INPUT_APK\%%~nxF\%%~nxS" "!REN2:~4!" 2>nul
	)
	FOR %%S IN ("_INPUT_APK\%%~nxF\*.bat_dex") DO (
		ren "_INPUT_APK\%%~nxF\%%~nxS" "%%~nS.dex" 2>nul
	)
	rd /s /q "_INPUT_APK\%%~nxF\dist" 2>nul
)
)
call :done "%logR%"
goto restart
:rebuild_1
if "!apktool:~8,6!"=="2.0.0b" (ren "_INPUT_APK\%~1\unknown" "bat_unknown" 2>nul)
ren "_INPUT_APK\%~1\assets" "bat_assets" 2>nul
ren "_INPUT_APK\%~1\lib" "bat_lib" 2>nul
ren "_INPUT_APK\%~1\libs" "bat_libs" 2>nul
pushd "!dp0dir!"
if "!apktool:~8,1!"=="1" (
	java -jar "!apktool!" b "!projdir!\_INPUT_APK\%~1" >>!projdir!\%logR% 2>&1
) else (
	java -jar "!apktool!" b -p ".\framework" "!projdir!\_INPUT_APK\%~1" >>!projdir!\%logR% 2>&1
)
if errorlevel 1 (
	popd
	set /A count+=1
	cecho {!colR!} !str_error!{# #}{\n}
	echo [*] ---^> !str_recompiling_error! "%~1">>%logR%
	goto:eof
)
popd
if not exist "_INPUT_APK\%~1.apk" (
	set /A count+=1
	cecho {!colR!} !str_orignotfound!{# #}{\n}
	echo [*] ---^> !str_orignotfound!>>%logR%
	goto:eof
)
if not exist "_INPUT_APK\%~1\_backup" (
	set /A count+=1
	cecho {!colR!} !str_backupnotfound!{# #}{\n}
	echo [*] ---^> !str_backupnotfound!>>%logR%
	goto:eof
)
echo.
FOR /D %%S IN ("_INPUT_APK\%~1\bat_*") DO (
	set REN2=%%~nxS
	ren "_INPUT_APK\%~1\%%~nxS" "!REN2:~4!" 2>nul
)
copy "_INPUT_APK\%~1.apk" "_INPUT_APK\%~1\dist\" >nul
rd /s /q "_INPUT_APK\%~1\_backup\upd" 2>nul
md "_INPUT_APK\%~1\_backup\upd" 2>nul
set COPYRES=0
FOR %%F IN (assets lib libs unknown res) DO (
	if exist "_INPUT_APK\%~1\%%F" (
		FOR /f "tokens=1* delims= " %%a IN ('sfk list -hidden -quiet -quot -relnames "_INPUT_APK\%~1\%%F" -sincedir "_INPUT_APK\%~1\_backup\%%F" 2^>nul') DO (
			call :GetParent "%%~b" "parent"
			if %%F==assets (call :copy2 "_INPUT_APK\%~1\assets\%%~b" "_INPUT_APK\%~1\_backup\upd\0\assets\!parent!\")
			if %%F==lib (call :copy2 "_INPUT_APK\%~1\lib\%%~b" "_INPUT_APK\%~1\_backup\upd\9\lib\!parent!\")
			if %%F==libs (call :copy2 "_INPUT_APK\%~1\libs\%%~b" "_INPUT_APK\%~1\_backup\upd\9\libs\!parent!\")
			if %%F==unknown (call :copy2 "_INPUT_APK\%~1\unknown\%%~b" "_INPUT_APK\%~1\_backup\upd\0\!parent!\")
			if %%F==res (
				set COPYRES=1
				call :copy2 "_INPUT_APK\%~1\build\apk\res\%%~b" "_INPUT_APK\%~1\_backup\upd\0\res\!parent!\"
			)
		)
		FOR /f "tokens=1* delims= " %%a IN ('sfk list -hidden -quiet -quot -relnames "_INPUT_APK\%~1\_backup\%%F" -sinceadd "_INPUT_APK\%~1\%%F" 2^>nul') DO (
			if %%F==assets (echo assets\%%~b>>"_INPUT_APK\%~1\_backup\upd\delete.list")
			if %%F==lib (echo lib\%%~b>>"_INPUT_APK\%~1\_backup\upd\delete.list")
			if %%F==libs (echo libs\%%~b>>"_INPUT_APK\%~1\_backup\upd\delete.list")
			if %%F==unknown (echo %%~b>>"_INPUT_APK\%~1\_backup\upd\delete.list")
			if %%F==res (
				set COPYRES=1
				echo res\%%~b>>"_INPUT_APK\%~1\_backup\upd\delete.list"
			)
		)
	)
)
if !COPYRES!==1 (
	call :copy2 "_INPUT_APK\%~1\build\apk\resources.arsc" "_INPUT_APK\%~1\_backup\upd\0\"
::	sed "s/[^^\\]*$//"	rem regular expression to get parent folder
	FOR /D %%F IN ("_INPUT_APK\%~1\build\apk\res\*") DO (
		echo res\%%~nxF\*>>"_INPUT_APK\%~1\_backup\upd\exclude.list"
	)
)
call :check_manifest "%~1"
if !COPYMANIFEST!==1 (
	call :copy2 "_INPUT_APK\%~1\build\apk\AndroidManifest.xml" "_INPUT_APK\%~1\_backup\upd\9\"
)
FOR %%S IN ("_INPUT_APK\%~1\build\apk\*.dex") DO (
	call :copy2 "_INPUT_APK\%~1\build\apk\%%~nxS" "_INPUT_APK\%~1\_backup\upd\9\"
)
if exist "_INPUT_APK\%~1\_backup\upd\exclude.list" (
	7za d "_INPUT_APK\%~1\dist\%~1.apk" res\*\ -x@"_INPUT_APK\%~1\_backup\upd\exclude.list" -scs!str_codepage! >nul 2>nul
	if errorlevel 1 (
		zip -d "_INPUT_APK\%~1\dist\%~1.apk" res\* -x@"_INPUT_APK\%~1\_backup\upd\exclude.list" >nul 2>>%logR%
	)
)
if exist "_INPUT_APK\%~1\_backup\upd\delete.list" (
	7za d "_INPUT_APK\%~1\dist\%~1.apk" @"_INPUT_APK\%~1\_backup\upd\delete.list" -scs!str_codepage! >nul 2>nul
	if errorlevel 1 (
		zip -d "_INPUT_APK\%~1\dist\%~1.apk" * -i@"_INPUT_APK\%~1\_backup\upd\delete.list" >nul 2>>%logR%
	)
)
if exist "_INPUT_APK\%~1\_backup\upd\9" (
	7za a "_INPUT_APK\%~1\dist\%~1.apk" ".\_INPUT_APK\%~1\_backup\upd\9\*" -mx7 >nul 2>nul
	if errorlevel 1 (
		pushd "_INPUT_APK\%~1\_backup\upd\9"
		zip -r -7 "..\..\..\dist\%~1.apk" * >nul 2>>..\..\..\..\..\%logR%
		popd
	)
)
if exist "_INPUT_APK\%~1\_backup\upd\0" (
	7za a "_INPUT_APK\%~1\dist\%~1.apk" ".\_INPUT_APK\%~1\_backup\upd\0\*" -mx0 >nul 2>nul
	if errorlevel 1 (
		pushd "_INPUT_APK\%~1\_backup\upd\0"
		zip -r -0 "..\..\..\dist\%~1.apk" * >nul 2>>..\..\..\..\..\%logR%
		popd
	)
)
if !COPYRES!==1 (
	7za a "_INPUT_APK\%~1\dist\%~1.apk" ".\_INPUT_APK\%~1\build\apk\res" -up1q1r2x1y1z1w1 -mx0 >nul 2>nul
	if errorlevel 1 (
		if exist "_INPUT_APK\%~1\build\apk" (
			pushd "_INPUT_APK\%~1\build\apk"
			zip -r -0 "..\..\dist\%~1.apk" res >nul 2>>..\..\..\..\%logR%
			popd
		)
	)
)
rd /s /q "_INPUT_APK\%~1\_backup\upd" 2>nul
goto:eof
:copy2
if exist "%~1" (
	md "%~2" 2>nul
	COPY "%~1" "%~2" >nul
)
goto:eof
:GetParent
set "_temp_input=%~1"
set "_temp_var=%~nx1"
set _temp_count=1
:_temp_repeat
if not defined _temp_var (
	set "%~2=!_temp_input:~0,-%_temp_count%!"
	goto:eof
)
set /a _temp_count+=1
set "_temp_var=%_temp_var:~1%"
goto _temp_repeat
goto:eof
:rebuild_2
pushd "!dp0dir!"
java -jar "!apktool!" b -p ".\framework" "!projdir!\_INPUT_APK\%~1" >>!projdir!\%logR% 2>&1
if errorlevel 1 (
	popd
	set /A count+=1
	cecho {!colR!} !str_error!{# #}{\n}
	echo [*] ---^> !str_recompiling_error! "%~1">>%logR%
	goto:eof
)
popd
if not exist "_INPUT_APK\%~1\_backup" (
	set /A count+=1
	cecho {!colR!} !str_backupnotfound!{# #}{\n}
	echo [*] ---^> !str_backupnotfound!>>%logR%
	goto:eof
)
echo.
call :check_manifest "%~1"
if !COPYMANIFEST!==1 (
	7za a "_INPUT_APK\%~1\dist\%~1.apk" ".\_INPUT_APK\%~1\original\META-INF" -mx7 >nul 2>>%logR%
) else (
	7za a "_INPUT_APK\%~1\dist\%~1.apk" ".\_INPUT_APK\%~1\original\*" -mx7 >nul 2>>%logR%
)
7za a "_INPUT_APK\%~1\dist\%~1.apk" ".\_INPUT_APK\%~1\_backup\*.dex" -up1q1r2x1y1z1w1 -mx7 >nul 2>>%logR%
goto:eof
:check_manifest
set COPYMANIFEST=0
sfk md5 "_INPUT_APK\%~1\AndroidManifest.xml" "_INPUT_APK\%~1\_backup\AndroidManifest.xml" >nul 2>nul
if errorlevel 1 (
	set COPYMANIFEST=1
	goto:eof
)
sfk md5 "_INPUT_APK\%~1\apktool.yml" "_INPUT_APK\%~1\_backup\apktool.yml" >nul 2>nul
if not errorlevel 1 (
	goto:eof
)
set yml1=0
set yml2=0
for /F "tokens=1* delims=:" %%a in ('type "_INPUT_APK\%~1\apktool.yml"') do (
	if /I "%%a"=="  minSdkVersion" (set yml1=!yml1!%%b)
	if /I "%%a"=="  targetSdkVersion" (set yml1=!yml1!%%b)
	if /I "%%a"=="  versionCode" (set yml1=!yml1!%%b)
	if /I "%%a"=="  versionName" (set yml1=!yml1!%%b)
)
for /F "tokens=1* delims=:" %%a in ('type "_INPUT_APK\%~1\_backup\apktool.yml"') do (
	if /I "%%a"=="  minSdkVersion" (set yml2=!yml2!%%b)
	if /I "%%a"=="  targetSdkVersion" (set yml2=!yml2!%%b)
	if /I "%%a"=="  versionCode" (set yml2=!yml2!%%b)
	if /I "%%a"=="  versionName" (set yml2=!yml2!%%b)
)
if not "!yml1!"=="!yml2!" (set COPYMANIFEST=1)
goto:eof
:signzip
set count=0
FOR %%F IN ("_INPUT_APK\!apk_name!") DO (
	echo [*] !str_signing! %%~nxF...
	if "%%~xF"==".apk" (
		call :sign "_INPUT_APK\%%~nxF" "%%~nxF"
	) else (
		java -jar %bindir%signapk.jar -w "%bindir%!key_base!.x509.pem" "%bindir%!key_name!" "_INPUT_APK\%%~nxF" "_OUT_APK\%%~nxF"
		if errorlevel 1 (
			set /A count+=1
			cecho {!colR!}[*] !str_signing_error! %%~nxF{# #}{\n}
		)
	)
)
if !count! GTR 0 (cecho {!colR!}%str_doneerrors%{# #}{\n}) else (cecho {!colG!}!str_done!{# #}{\n})
pause
goto restart
:sign
java -jar %bindir%signapk.jar -w "%bindir%!key_base!.x509.pem" "%bindir%!key_name!" "%~1" "_OUT_APK\%~n2.signed%~x2"
if not errorlevel 1 (
	zipalign -f 4 "_OUT_APK\%~n2.signed%~x2" "_OUT_APK\%~2" 2>nul
) else (
	set /A count+=1
	cecho {!colR!}[*] !str_signing_error! "%~2"{# #}{\n}
)
del /f /q "_OUT_APK\%~n2.signed%~x2" 2>nul
goto:eof
:zipalignoutapks
set count=0
call :log_version "%logR%"
FOR %%F IN ("_INPUT_APK\!apk_base!.apk") DO (
	echo [*] !str_zipal! %%~nxF...
	echo [*] !str_zipal! %%~nxF>>%logR%
	zipalign -f 4 "_INPUT_APK\%%~nxF" "_OUT_APK\%%~nxF" >>%logR% 2>&1
	if errorlevel 1 (
		set /A count+=1
		cecho {!colR!}[*] !str_zipal_error! %%~nxF{# #}{\n}
		echo [*] ---^> !str_zipal_error! %%~nxF>>%logR%
	)
)
call :done "%logR%"
goto restart
:javasource
cecho {!colG!}  !str_selectviewer!{# #}{\n}
echo    1 = procyon
echo    2 = jadx
echo.
echo    3 = !str_cancel!
:_javasource
set INPUT=
SET /P INPUT=!str_makechoice! 
IF !INPUT!==1 (goto javasource-jd-gui)
IF !INPUT!==2 (goto javasource-jadx)
IF !INPUT!==3 (goto restart)
goto _javasource
:javasource-jadx
set INPUT=
set /P INPUT=Jadx: !str_dragajd! 
if exist !INPUT! (
	start cmd /c %bindir%jadx\bin\jadx-gui.bat !INPUT!
) else (
	goto javasource-jadx
)
goto restart
:javasource-jd-gui
set INPUT=
set /P INPUT=Procyon: !str_dragajd! 
if exist !INPUT! (
	FOR %%F IN (!INPUT!) DO (
		echo [*] !str_genjava! %%~nxF...
		del /f /q "%bindir%dex2jar\jar\%%~nF.jar" 2>nul
		call %bindir%dex2jar\d2j-dex2jar.bat -o "%bindir%dex2jar\jar\%%~nF.jar" !INPUT! >nul 2>nul
		if exist "%bindir%dex2jar\jar\%%~nF.jar" (
			start javaw -jar %bindir%procyon\luyten.jar "%bindir%dex2jar\jar\%%~nF.jar"
		) else (
			cecho {!colR!}[*] !str_genjava_error! %%~nxF{# #}{\n}
			pause
		)
	)
) else (
	goto javasource-jd-gui
)
goto restart
:: --------------------
:log_version
echo -------------------------------------------------->%~1
echo Batch ApkTool                : !bat_version!>>%~1
echo SMALI                        : !smali!>>%~1
echo !str_apilevel_log! : !api!>>%~1
echo APKTOOL                      : !apktool!>>%~1
echo !str_buildexpert_log! : !str_%expert_mode%!>>%~1
echo !str_signafter_log! : !str_%sign_after%!>>%~1
echo -------------------------------------------------->>%~1
echo.>>%~1
goto:eof
:done
echo.>>%~1
if !count! GTR 0 (
	echo %str_doneerrors%>>%~1
) else (
	echo !str_done!>>%~1
)
::	rem	convert logfiles to UTF8
nhrplc -cp:!str_codepage!,utf8 "%~1" >nul
echo.
if !count! GTR 0 (
	cecho {!colR!}%str_doneerrors%{# #}{\n}
) else (
	cecho {!colG!}!str_done!{# #}{\n}
)
if %open_log%==ON (
	start %~1
	pause
) else (
	SET INPUT=
	SET /P INPUT=!str_press1! 
	IF !INPUT!==1 start %~1
)
goto:eof
:get_date_time
set DATE2=!DATE:/=-!
set TIME2=!TIME::=.!
set TIME2=!TIME2:~0,-3!
goto:eof
:clean
cecho  {!colR!}!str_deletedialog!{# #} %~1{\n}
cecho  {!colG!}!str_proceed!{# #}{\n}
echo    1 = !str_yes!
echo    2 = !str_cancel!
set INPUT=
set /P INPUT=!str_makechoice! 
IF !INPUT!==1 (
	rd /s /q %~1 2>nul
	rd /s /q %~1 2>nul
	md %~1 2>nul
	md %~1 2>nul
	cecho {!colG!}!str_done!{# #}{\n}
	pause
)
goto:eof
:: --------------------
:setproject
cd /d "!rootdir!"
set bindir=bin\
set count=1
cecho {!colG!}  !str_selproj!{# #}{\n}
echo    0 = !str_createnewproj!
echo    1 = !str_usedefproj!
set name1=.
FOR /D %%F IN (*) DO (
	set x=%%~F
	if not "%%~F"=="_app" (
	if !x!==!x:_framework=! (
	if not "%%~F"=="_INPUT_APK" (
	if not "%%~F"=="_INPUT_JAR" (
	if not "%%~F"=="_OUT_APK" (
	if not "%%~F"=="_OUT_JAR" (
	if not "%%~F"=="_priv-app" (
	if not "%%~F"=="bin" (
		set /A count+=1
		set name!count!=%%~nxF
		echo    !count! = %%~nxF
	)
	)
	)
	)
	)
	)
	)
	)
)
echo.
set INPUT=
set /P INPUT=!str_makechoice! 
if '!INPUT!'=='' goto setproject
if !INPUT! GTR !count! (goto setproject)
if !INPUT! LSS 0 (goto setproject)
:_project
if !INPUT!==0 (
	set name0=
	set /P name0=!str_inputprojname! 
	if '!name0!'=='' goto _project
)
set workdir=!name%INPUT%!
md "!workdir!" 2>nul
call :saveglobal "workdir"
goto restart3
:setcurrentapk
set count=0
cecho {!colG!}  !str_selectapk!{# #}{\n}
echo    0 = !str_allapks!
set name0=*
FOR %%F IN (_INPUT_APK\*.apk _INPUT_APK\*.zip) DO (
	set /A count+=1
	set name!count!=%%~nxF
	echo    !count! = %%~nxF
	set /A MOD=!count! %% 45
	if !MOD! equ 0 pause
)
echo.
set /A count+=1
set name!count!=select_cancel
echo    !count! = !str_cancel!
set INPUT=
set /P INPUT=!str_makechoice! 
if '!INPUT!'=='' goto setcurrentapk
if !INPUT! GTR !count! (goto setcurrentapk)
if !INPUT! LSS 0 (goto setcurrentapk)
if !name%INPUT%!==select_cancel goto restart
set apk_name=!name%INPUT%!
call :savesettings "apk_name"
goto restart2
:setcurrentjar
set count=0
cecho {!colG!}  !str_selectjar!{# #}{\n}
echo    0 = !str_alljars!
set name0=*
FOR %%F IN (_INPUT_JAR\*.jar) DO (
	set /A count+=1
	set name!count!=%%~nxF
	echo    !count! = %%~nxF
	set /A MOD=!count! %% 45
	if !MOD! equ 0 pause
)
echo.
set /A count+=1
set name!count!=select_cancel
echo    !count! = !str_cancel!
set INPUT=
set /P INPUT=!str_makechoice! 
if '!INPUT!'=='' goto setcurrentjar
if !INPUT! GTR !count! (goto setcurrentjar)
if !INPUT! LSS 0 (goto setcurrentjar)
if !name%INPUT%!==select_cancel goto restart
set jar_name=!name%INPUT%!
call :savesettings "jar_name"
goto restart2
:setapktoolversion
set count=0
cecho {!colG!}  !str_selectapktool!{# #}{\n}
FOR %%F IN (%bindir%apktool_*.jar) DO (
	set /A count+=1
	set name!count!=%%~nxF
	echo    !count! = %%~nxF
)
echo.
:_apktoolversion
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT! GTR !count! (goto _apktoolversion)
if !INPUT! LSS 1 (goto _apktoolversion)
set apktool=!name%INPUT%!
call :savesettings "apktool"
goto restart
:setsbversion
set count=0
cecho {!colG!}  !str_selectsmali!{# #}{\n}
FOR %%F IN (%bindir%smali-*.jar) DO (
	set /A count+=1
	set name!count!=%%~nxF
	echo    !count! = %%~nxF
)
echo.
:_sbversion
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT! GTR !count! (goto _sbversion)
if !INPUT! LSS 1 (goto _sbversion)
set smali=!name%INPUT%!
call :savesettings "smali"
goto restart
:setapi
echo !str_aversions! 2.2  2.3  4.0  4.1  4.2  4.3  4.4  5.0  5.1  6.0  7.0
cecho {!colG!}!str_apilevels!{# #}   8   10   15   16   17   18   19   21   22   23   24{\n}
echo.
:_api
set INPUT=
set /P INPUT=!str_enterapi! 
::set x=-3-4-7-8-10-11-12-13-14-15-16-17-18-19-21-
::if !x!==!x:-%INPUT%-=! (
if !INPUT! GTR 24 (
	cecho {!colR!}!str_invalidapi!{# #}{\n}
	goto _api
)
if !INPUT! LSS 1 (
	cecho {!colR!}!str_invalidapi!{# #}{\n}
	goto _api
)
set api=!INPUT!
call :savesettings "api"
goto restart
:setsignkey
set count=0
cecho {!colG!}  !str_selectkey!{# #}{\n}
FOR %%F IN (%bindir%*.pk8) DO (
	set /A count+=1
	set name!count!=%%~nxF
	echo    !count! = %%~nxF
)
echo.
:_signkey
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT! GTR !count! (goto _signkey)
if !INPUT! LSS 1 (goto _signkey)
set key_name=!name%INPUT%!
call :savesettings "key_name"
goto restart2
:setlanguage
set count=0
cecho {!colG!}!str_selectlang!{# #}{\n}
FOR %%F IN (%bindir%language\*.lng) DO (
	set /A count+=1
	set name!count!=%%~nF
	echo   !count! = %%~nF
)
:_language
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT! GTR !count! (goto _language)
if !INPUT! LSS 1 (goto _language)
set language=!name%INPUT%!
echo language=!language!>%bindir%language\lang
:__language
chcp 1252>nul
for /F "eol=; tokens=1* delims==" %%a in ('type "%bindir%language\english.lng"') do set str_%%a=%%b
if "!language!"=="english" goto:eof
for /F "eol=; tokens=1* delims==" %%a in ('type "%bindir%language\!language!.lng"') do (
	if "%%a"=="codepage" chcp %%b>nul
)
for /F "eol=; tokens=1* delims==" %%a in ('type "%bindir%language\!language!.lng"') do set str_%%a=%%b
goto:eof
:setkeepbrokenres
if %keepbrokenres%==ON (set keepbrokenres=OFF) else (set keepbrokenres=ON)
call :savesettings "keepbrokenres"
goto restart
:setdeldebuginfo
if %deldebuginfo%==ON (set deldebuginfo=OFF) else (set deldebuginfo=ON)
call :savesettings "deldebuginfo"
goto restart
:setsign
if %sign_after%==ON (set sign_after=OFF) else (set sign_after=ON)
call :savesettings "sign_after"
goto restart
:setlog
if %open_log%==ON (set open_log=MANUAL) else (set open_log=ON)
call :savesettings "open_log"
goto restart
:setexpert_mode
if %expert_mode%==ON (set expert_mode=OFF) else (set expert_mode=ON)
call :savesettings "expert_mode"
goto restart
:savesettings
if not exist batchapktool.ini type nul >batchapktool.ini
if "%~2"=="wait" (
	inifile batchapktool.ini [settings] "%~1=!%~1!"
) else (
	start /B inifile batchapktool.ini [settings] "%~1=!%~1!"
)
goto:eof
:saveglobal
if not exist "%bindir%settings.ini" type nul >"%bindir%settings.ini"
start /B inifile "%bindir%settings.ini" [global_settings] "%~1=!%~1!"
goto:eof
:: --------------------
:deodex
set count=0
call :log_version "%logD%"
if %api% GEQ 21 (goto deodex_lolly)
FOR %%F IN (_framework\*.*) DO set /A count+=1
if %count% LSS 5 (
	cecho {!colR!}[*] !str_framework_empty!{# #}{\n}
	pause
)
set count=0
set opt_d=
if exist "%bindir%inline.txt" (set opt_d=-T %bindir%inline.txt)
set count2=0
set count3=0
FOR %%F IN ("_app\*.apk" "_priv-app\*.apk" "_framework\*.apk" "_framework\*.jar") DO (set /A count2+=1)
FOR %%a IN (_app _priv-app _framework) DO (
	FOR %%F IN ("%%a\*.apk") DO (
		set /A count3+=1
		title !title_text! [!count3!/!count2!]
		cecho [*] !str_deodexing! %%~nxF... 
		echo [*] !str_deodexing! %%~nxF...>>%logD%
		if exist "%%a\%%~nF.odex" (
			call :deodex_1 "%%~F" "%%a"
		) else (
			cecho {!colG!}!str_notodexed!{# #}{\n}
			echo [*] !str_notodexed!>>%logD%
		)
	)
)
FOR %%F IN ("_framework\*.jar") DO (
	set /A count3+=1
	title !title_text! [!count3!/!count2!]
	cecho [*] !str_deodexing! %%~nxF... 
	echo [*] !str_deodexing! %%~nxF...>>%logD%
	if exist "_framework\%%~nF.odex" (
		call :deodex_1 "%%~F" "_framework"
	) else (
		cecho {!colG!}!str_notodexed!{# #}{\n}
		echo [*] !str_notodexed!>>%logD%
	)
)
call :done "%logD%"
goto restart
:deodex_1 file folder
rd /s /q "%~2\%~n1" 2>nul
java -Xmx512m -jar "%bindir%bak!smali!" -a %api% -d _framework -o "%~2\%~n1\smali" %opt_d% -x "%~2\%~n1.odex" >>%logD% 2>&1
if not errorlevel 1 (
	java -Xmx512m -jar "%bindir%!smali!" -a %api% -o "%~2\%~n1\classes.dex" "%~2\%~n1\smali" >>%logD% 2>&1
	if not errorlevel 1 (
		echo.
		if "%~x1"==".jar" (
			7za a "%~2\%~nx1" ".\%~2\%~n1\classes.dex" -up1q1r2x1y1z1w1 -mx7 >nul 2>nul
			if errorlevel 1 (
				zip -j -7 "%~2\%~nx1" "%~2\%~n1\classes.dex" >nul 2>>%logD%
			)
		) else (
			COPY "%~2\%~nx1" "%~2\%~n1\" >nul
			7za a "%~2\%~n1\%~nx1" ".\%~2\%~n1\classes.dex" -up1q1r2x1y1z1w1 -mx7 >nul 2>nul
			if errorlevel 1 (
				zip -j -7 "%~2\%~n1\%~nx1" "%~2\%~n1\classes.dex" >nul 2>>%logD%
			)
			zipalign -f 4 "%~2\%~n1\%~nx1" "%~2\%~nx1" 2>nul
		)
		del /f /q "%~2\%~n1.odex" 2>nul
	) else (
		set /A count+=1
		cecho {!colR!} !str_error!{# #}{\n}
		echo [*] ---^> !str_deodexing_error! "%~nx1">>%logD%
	)
) else (
	set /A count+=1
	cecho {!colR!} !str_error!{# #}{\n}
	echo [*] ---^> !str_deodexing_error! "%~nx1">>%logD%
)
rd /s /q "%~2\%~n1" 2>nul
goto:eof
:deodex_lolly
set count_boot=0
FOR /D %%F IN (_framework\*) DO (
	if exist "%%~F\boot.oat" (
		set /A count_boot+=1
		set FARCH!count_boot!=%%~nxF
	)
)
if !count_boot!==0 (
	set /A count+=1
	cecho {!colR!}[*] !str_bootnotfound!{# #}{\n}
	echo [*] ---^> !str_bootnotfound!>>%logD%
	call :done "%logD%"
	goto restart
)
if !count_boot!==1 (goto arch_ready)
cecho {!colG!}  !str_selectarch!{# #}{\n}
FOR /L %%a IN (1,1,!count_boot!) DO (
	echo    %%a = !FARCH%%a!
)
echo.
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT! GTR !count_boot! (goto deodex_lolly)
if !INPUT! LSS 1 (goto deodex_lolly)
set FARCH1=!FARCH%INPUT%!
set count_boot=1
FOR /D %%F IN (_framework\*) DO (
	if exist "%%~F\boot.oat" (
		if not "%%~nxF"=="!FARCH1!" (
			set /A count_boot+=1
			set FARCH!count_boot!=%%~nxF
		)
	)
)
cecho [*] !str_selectedarch! {!colG!}!FARCH1!{# #}{\n}
echo [*] !str_selectedarch! !FARCH1!>>%logD%
:arch_ready
cecho [*] !str_extractboot! 
echo [*] !str_extractboot!>>%logD%
if %api%==23 (goto deodex_m)
if %api% GEQ 23 (
	set oat_dir=\oat
) else (
	set oat_dir=
)
rd /s /q "_framework\!FARCH1!-dex" "_framework\!FARCH1!-odex" 2>nul
java -Xmx1024m -jar "%bindir%oat2dex.jar" boot "_framework\!FARCH1!" >>%logD% 2>&1
set odex_count=0
FOR %%F IN ("_framework\!FARCH1!-odex\*") DO (set /A odex_count+=1)
if "%odex_count%"=="0" (
	set /A count+=1
	cecho {!colR!} !str_error!{# #}{\n}
	echo [*] ---^> !str_extractboot_error! (!FARCH1!^)>>%logD%
	call :done "%logD%"
	goto restart
)
FOR %%F IN ("_framework\!FARCH1!-dex\*") DO (set /A odex_count-=1)
if not "%odex_count%"=="0" (
	set /A count+=1
	cecho {!colR!} !str_error!{# #}
	echo [*] ---^> !str_extractboot_error! (!FARCH1!^)>>%logD%
)
FOR /L %%a IN (2,1,!count_boot!) DO (
	rd /s /q "_framework\!FARCH%%a!-dex" "_framework\!FARCH%%a!-odex" 2>nul
	md "_framework\!FARCH%%a!-odex" 2>nul
	java -Xmx1024m -jar "%bindir%oat2dex.jar" -o "_framework\!FARCH%%a!-odex" odex "_framework\!FARCH%%a!" >>%logD% 2>&1
	set odex_count=0
	FOR %%F IN ("_framework\!FARCH%%a!-odex\*") DO (set /A odex_count+=1)
::	>nul 2>nul dir /a-d "_framework\!FARCH%%a!-odex\*" || (
	if "!odex_count!"=="0" (
		set /A count+=1
		cecho {!colR!} !str_error!{# #}
		echo [*] ---^> !str_extractboot_error! (!FARCH%%a!^)>>%logD%
	)
)
echo.
set count2=0
set count3=0
FOR /f "delims=" %%a IN ('sfk list -hidden -quiet -quot -dir _app _priv-app _framework -file .apk 2^>nul') DO (set /A count2+=1)
FOR %%F IN ("_framework\*.jar") DO (set /A count2+=1)
FOR /f "delims=" %%a IN ('sfk list -hidden -quiet -quot -dir _app _priv-app _framework -file .apk 2^>nul') DO (
	call :GetParent "%%~a" "parent"
	set /A count3+=1
	title !title_text! [!count3!/!count2!]
	cecho [*] !str_deodexing! %%~nxa... 
	echo [*] !str_deodexing! %%~nxa...>>%logD%
	set file_deodexed=0
	FOR /L %%b IN (1,1,!count_boot!) DO (
		if !file_deodexed!==0 (
			call :deodex_2 "%%~nxa" "!parent!" "!FARCH%%b!"
		)
	)
	if !file_deodexed!==0 (
		cecho {!colG!}!str_notodexed!{# #}{\n}
		echo [*] !str_notodexed!>>%logD%
	)
	if !file_deodexed!==1 (
		FOR /L %%b IN (1,1,!count_boot!) DO (
			del /f /q "!parent!!oat_dir!\!FARCH%%b!\%%~na.odex*" 2>nul
			rd "!parent!!oat_dir!\!FARCH%%b!" 2>nul
		)
		if %api% GEQ 23 (rd "!parent!\oat" 2>nul)
	)
)
FOR %%F IN ("_framework\*.jar") DO (
	set /A count3+=1
	title !title_text! [!count3!/!count2!]
	cecho [*] !str_deodexing! %%~nxF... 
	echo [*] !str_deodexing! %%~nxF...>>%logD%
	set file_deodexed=0
	call :deodex_2 "%%~nxF" "_framework" "!FARCH1!"
	if !file_deodexed!==0 (
		if exist "_framework\!FARCH1!-dex\%%~nF.dex" (
			echo.
			del /f /q "_framework\!FARCH1!-dex\classes*.dex" 2>nul
			ren "_framework\!FARCH1!-dex\%%~nF.dex" "classes.dex" 2>nul
			FOR %%S IN ("_framework\!FARCH1!-dex\%%~nF-classes*.dex") DO (
				set REN2=%%~nxS
				ren "%%~S" "!REN2:%%~nF-=!" 2>nul
			)
			7za a "%%~F" ".\_framework\!FARCH1!-dex\classes*.dex" -up1q1r2x1y1z1w1 -mx7 >nul 2>nul
			if errorlevel 1 (
				zip -j -7 "%%~F" "_framework\!FARCH1!-dex\classes*.dex" >nul 2>>%logD%
			)
			del /f /q "_framework\!FARCH1!-dex\classes*.dex" 2>nul
		) else (
			cecho {!colG!}!str_notodexed!{# #}{\n}
			echo [*] !str_notodexed!>>%logD%
		)
	)
	if !file_deodexed!==1 (
		FOR /L %%b IN (1,1,!count_boot!) DO (
			del /f /q "_framework!oat_dir!\!FARCH%%b!\%%~nF.odex*" 2>nul
		)
	)
)
if %count%==0 (
	FOR /L %%a IN (1,1,!count_boot!) DO (
		del /f /q "_framework\!FARCH%%a!\boot.oat" "_framework\!FARCH%%a!\boot.art" 2>nul
		rd "_framework\!FARCH%%a!" 2>nul
	)
)
FOR /L %%a IN (1,1,!count_boot!) DO (
	rd /s /q "_framework\!FARCH%%a!-dex" "_framework\!FARCH%%a!-odex" 2>nul
	rd "_framework!oat_dir!\!FARCH%%a!" 2>nul
)
if %api% GEQ 23 (rd "_framework\oat" 2>nul)
call :symlinks_search
call :done "%logD%"
goto restart
:deodex_2 file folder arch
if not exist "%~2!oat_dir!\%~3\%~n1.odex" (
	set pack_odex=
	if exist "%~2!oat_dir!\%~3\%~n1.odex.xz" (set pack_odex=xz)
	if exist "%~2!oat_dir!\%~3\%~n1.odex.gz" (set pack_odex=gz)
	if defined pack_odex (
		7za x "%~2!oat_dir!\%~3\%~n1.odex.!pack_odex!" -o"%~2!oat_dir!\%~3" -aoa >nul 2>>%logD%
		if not exist "%~2!oat_dir!\%~3\%~n1.odex" (
			set /A count+=1
			cecho {!colR!} !str_errorunp! %~n1.odex.!pack_odex!{# #}{\n}
			echo [*] ---^> !str_errorunp! %~n1.odex.!pack_odex!>>%logD%
			set file_deodexed=2
			goto:eof
		)
	) else (
		goto:eof
	)
)
del /f /q "%~2!oat_dir!\%~3\*.dex" 2>nul
java -Xmx1024m -jar "%bindir%oat2dex.jar" "%~2!oat_dir!\%~3\%~n1.odex" "_framework\%~3-odex" >>%logD% 2>&1
if not exist "%~2!oat_dir!\%~3\%~n1.dex" (
	set /A count+=1
	cecho {!colR!} !str_error!{# #}{\n}
	echo [*] ---^> !str_deodexing_error! "%~nx1">>%logD%
	set file_deodexed=2
	goto:eof
)
echo.
set file_deodexed=1
ren "%~2!oat_dir!\%~3\%~n1.dex" "classes.dex" 2>nul
FOR %%S IN ("%~2!oat_dir!\%~3\%~n1-classes*.dex") DO (
	set REN2=%%~nxS
	ren "%%~S" "!REN2:%~n1-=!" 2>nul
)
if "%~x1"==".jar" (
	7za a "%~2\%~nx1" ".\%~2!oat_dir!\%~3\classes*.dex" -up1q1r2x1y1z1w1 -mx7 >nul 2>nul
	if errorlevel 1 (
		zip -j -7 "%~2\%~nx1" "%~2!oat_dir!\%~3\classes*.dex" >nul 2>>%logD%
	)
) else (
	COPY "%~2\%~nx1" "%~2!oat_dir!\%~3\" >nul
	7za a "%~2!oat_dir!\%~3\%~nx1" ".\%~2!oat_dir!\%~3\classes*.dex" -up1q1r2x1y1z1w1 -mx7 >nul 2>nul
	if errorlevel 1 (
		zip -j -7 "%~2!oat_dir!\%~3\%~nx1" "%~2!oat_dir!\%~3\classes*.dex" >nul 2>>%logD%
	)
	zipalign -f 4 "%~2!oat_dir!\%~3\%~nx1" "%~2\%~nx1" 2>nul
	del /f /q "%~2!oat_dir!\%~3\%~nx1" 2>nul
)
del /f /q "%~2!oat_dir!\%~3\*.dex" 2>nul
goto:eof
:symlinks_search
set first_time=1
FOR %%F IN (app priv-app framework) DO (
	for /f "skip=1 delims=" %%a in ('findstr /s /i /m /D:"_%%F" "^^^!<symlink>" * 2^>nul') do (
		if !first_time!==1 (
			echo.>>%logD%
			echo [*] !str_symlinks!:>>%logD%
			set first_time=0
		)
		ATTRIB -S -H "_%%F\%%a" >nul
		COPY "_%%F\%%a" "_%%F\%%a.txt" >nul
		nhrplc -spt:"^!^<symlink^>" -i -t:"" -cp:ansi "_%%F\%%a.txt" >nul
		set REN2=%%a
		for /F "delims=" %%b in ('type "_%%F\%%a.txt"') do (
			echo symlink("%%b", "/system/%%F/!REN2:\=/!"^);>>%logD%
		)
		del /f /q "_%%F\%%a.txt" 2>nul
	)
)
goto:eof
:deodex_m
rd /s /q "_framework\!FARCH1!\dex" 2>nul
set odex_count=0
FOR /f "delims=" %%a IN ('java -Xmx512m -jar "%bindir%bak!smali!" "_framework\!FARCH1!\boot.oat" 2^>^&1') DO (
	set x=%%a
	if not !x!==!x:/system/=! (
		if !odex_count!==0 echo.
		set /A odex_count+=1
		set x=%%~na
		set x=!x:.jar:=-!
		cecho     - %%~nxa... 
		echo  - %%~nxa...>>%logD%
		java -Xmx512m -jar "%bindir%bak!smali!" -x -c boot.oat -d "_framework\!FARCH1!" -e "%%a" "_framework\!FARCH1!\boot.oat" -o "_framework\!FARCH1!\dex\!x!" >>%logD% 2>&1
		if not errorlevel 1 (
			java -Xmx512m -jar "%bindir%!smali!" -a %api% -o "_framework\!FARCH1!\dex\!x!.dex" "_framework\!FARCH1!\dex\!x!" >>%logD% 2>&1
			if not errorlevel 1 (
				echo.
			) else (
				set /A count+=1
				cecho {!colR!} !str_error!{# #}{\n}
				echo [*] ---^> !str_deodexing_error! "%%~nxa">>%logD%
			)
		) else (
			set /A count+=1
			cecho {!colR!} !str_error!{# #}{\n}
			echo [*] ---^> !str_deodexing_error! "%%~nxa">>%logD%
		)
		rd /s /q "_framework\!FARCH1!\dex\!x!" 2>nul
	)
)
if "%odex_count%"=="0" (
	set /A count+=1
	cecho {!colR!} !str_error!{# #}{\n}
	echo [*] ---^> !str_extractboot_error!>>%logD%
	call :done "%logD%"
	goto restart
)
set count2=0
set count3=0
FOR /f "delims=" %%a IN ('sfk list -hidden -quiet -quot -dir _app _priv-app _framework -file .apk 2^>nul') DO (set /A count2+=1)
FOR %%F IN ("_framework\*.jar") DO (set /A count2+=1)
FOR /f "delims=" %%a IN ('sfk list -hidden -quiet -quot -dir _app _priv-app _framework -file .apk 2^>nul') DO (
	call :GetParent "%%~a" "parent"
	set /A count3+=1
	title !title_text! [!count3!/!count2!]
	cecho [*] !str_deodexing! %%~nxa... 
	echo [*] !str_deodexing! %%~nxa...>>%logD%
	set file_deodexed=0
	FOR /L %%b IN (1,1,!count_boot!) DO (
		if !file_deodexed!==0 (
			call :deodex_3 "%%~nxa" "!parent!" "!FARCH%%b!"
		)
	)
	if !file_deodexed!==0 (
		cecho {!colG!}!str_notodexed!{# #}{\n}
		echo [*] !str_notodexed!>>%logD%
	)
	if !file_deodexed!==1 (
		FOR /L %%b IN (1,1,!count_boot!) DO (
			del /f /q "!parent!\oat\!FARCH%%b!\%%~na.odex*" 2>nul
			rd "!parent!\oat\!FARCH%%b!" 2>nul
		)
		rd "!parent!\oat" 2>nul
	)
)
FOR %%F IN ("_framework\*.jar") DO (
	set /A count3+=1
	title !title_text! [!count3!/!count2!]
	cecho [*] !str_deodexing! %%~nxF... 
	echo [*] !str_deodexing! %%~nxF...>>%logD%
	set file_deodexed=0
	call :deodex_3 "%%~nxF" "_framework" "!FARCH1!"
	if !file_deodexed!==0 (
		if exist "_framework\!FARCH1!\dex\%%~nF.dex" (
			echo.
			del /f /q "_framework\!FARCH1!\dex\classes*.dex" 2>nul
			ren "_framework\!FARCH1!\dex\%%~nF.dex" "classes.dex" 2>nul
			FOR %%S IN ("_framework\!FARCH1!\dex\%%~nF-classes*.dex") DO (
				set REN2=%%~nxS
				ren "%%~S" "!REN2:%%~nF-=!" 2>nul
			)
			7za a "%%~F" ".\_framework\!FARCH1!\dex\classes*.dex" -up1q1r2x1y1z1w1 -mx7 >nul 2>nul
			if errorlevel 1 (
				zip -j -7 "%%~F" "_framework\!FARCH1!\dex\classes*.dex" >nul 2>>%logD%
			)
			del /f /q "_framework\!FARCH1!\dex\classes*.dex" 2>nul
		) else (
			cecho {!colG!}!str_notodexed!{# #}{\n}
			echo [*] !str_notodexed!>>%logD%
		)
	)
	if !file_deodexed!==1 (
		FOR /L %%b IN (1,1,!count_boot!) DO (
			del /f /q "_framework\oat\!FARCH%%b!\%%~nF.odex*" 2>nul
		)
	)
)
FOR /L %%a IN (1,1,!count_boot!) DO (
	rd /s /q "_framework\!FARCH%%a!\dex" 2>nul
	rd "_framework\oat\!FARCH%%a!" 2>nul
)
rd "_framework\oat" 2>nul
if %count%==0 (
	FOR /L %%a IN (1,1,!count_boot!) DO (
		del /f /q "_framework\!FARCH%%a!\boot.oat" "_framework\!FARCH%%a!\boot.art" 2>nul
		rd "_framework\!FARCH%%a!" 2>nul
	)
)
call :symlinks_search
call :done "%logD%"
goto restart
:deodex_3 file folder arch
if not exist "%~2\oat\%~3\%~n1.odex" (
	set pack_odex=
	if exist "%~2\oat\%~3\%~n1.odex.xz" (set pack_odex=xz)
	if exist "%~2\oat\%~3\%~n1.odex.gz" (set pack_odex=gz)
	if defined pack_odex (
		7za x "%~2\oat\%~3\%~n1.odex.!pack_odex!" -o"%~2\oat\%~3" -aoa >nul 2>>%logD%
		if not exist "%~2\oat\%~3\%~n1.odex" (
			set /A count+=1
			cecho {!colR!} !str_errorunp! %~n1.odex.!pack_odex!{# #}{\n}
			echo [*] ---^> !str_errorunp! %~n1.odex.!pack_odex!>>%logD%
			set file_deodexed=2
			goto:eof
		)
	) else (
		goto:eof
	)
)
rd /s /q "%~2\oat\%~3\%~n1" 2>nul
set error_count=!count!
set odex_count=0
FOR /f "delims=" %%a IN ('java -Xmx512m -jar "%bindir%bak!smali!" "%~2\oat\%~3\%~n1.odex" -o "%~2\oat\%~3\%~n1\temp" 2^>^&1') DO (
	set x=%%a
	if not !x!==!x:/system/=! (
		if !odex_count!==0 echo.
		set /A odex_count+=1
		if "%%~nxa"=="%~nx1" (
			set x=classes
		) else (
			set x=%%~na
			set x=!x:%~nx1:=!
		)
		cecho     - !x!.dex... 
		echo  - !x!.dex...>>%logD%
		java -Xmx512m -jar "%bindir%bak!smali!" -x -c "boot.oat:%~n1.odex" -d "_framework\%~3" -d "%~2\oat\%~3" -e "%%a" "%~2\oat\%~3\%~n1.odex" -o "%~2\oat\%~3\%~n1\!x!" >>%logD% 2>&1
		if not errorlevel 1 (
			java -Xmx512m -jar "%bindir%!smali!" -a %api% -o "%~2\oat\%~3\%~n1\!x!.dex" "%~2\oat\%~3\%~n1\!x!" >>%logD% 2>&1
			if not errorlevel 1 (
				echo.
			) else (
				set /A count+=1
				cecho {!colR!} !str_error!{# #}{\n}
				echo [*] ---^> !str_deodexing_error! "%%~nxa">>%logD%
			)
		) else (
			set /A count+=1
			cecho {!colR!} !str_error!{# #}{\n}
			echo [*] ---^> !str_deodexing_error! "%%~nxa">>%logD%
		)
		rd /s /q "%~2\oat\%~3\%~n1\!x!" 2>nul
	)
)
if "%odex_count%"=="0" (
	java -Xmx512m -jar "%bindir%bak!smali!" -x -c boot.oat -d "_framework\%~3" "%~2\oat\%~3\%~n1.odex" -o "%~2\oat\%~3\%~n1\smali" >>%logD% 2>&1
	if not errorlevel 1 (
		java -Xmx512m -jar "%bindir%!smali!" -a %api% -o "%~2\oat\%~3\%~n1\classes.dex" "%~2\oat\%~3\%~n1\smali" >>%logD% 2>&1
		if not errorlevel 1 (
			echo.
		) else (
			set /A count+=1
			cecho {!colR!} !str_error!{# #}{\n}
			echo [*] ---^> !str_deodexing_error! "%~nx1">>%logD%
		)
	) else (
		set /A count+=1
		cecho {!colR!} !str_error!{# #}{\n}
		echo [*] ---^> !str_deodexing_error! "%~nx1">>%logD%
	)
)
if !error_count!==!count! (
	set file_deodexed=1
	if "%~x1"==".jar" (
		7za a "%~2\%~nx1" ".\%~2\oat\%~3\%~n1\classes*.dex" -up1q1r2x1y1z1w1 -mx7 >nul 2>nul
		if errorlevel 1 (
			zip -j -7 "%~2\%~nx1" "%~2\oat\%~3\%~n1\classes*.dex" >nul 2>>%logD%
		)
	) else (
		COPY "%~2\%~nx1" "%~2\oat\%~3\%~n1\" >nul
		7za a "%~2\oat\%~3\%~n1\%~nx1" ".\%~2\oat\%~3\%~n1\classes*.dex" -up1q1r2x1y1z1w1 -mx7 >nul 2>nul
		if errorlevel 1 (
			zip -j -7 "%~2\oat\%~3\%~n1\%~nx1" "%~2\oat\%~3\%~n1\classes*.dex" >nul 2>>%logD%
		)
		zipalign -f 4 "%~2\oat\%~3\%~n1\%~nx1" "%~2\%~nx1" 2>nul
	)
) else (
	set file_deodexed=2
)
rd /s /q "%~2\oat\%~3\%~n1" 2>nul
goto:eof
:copy_files
set count2=0
set count3=0
set progressbar=0
FOR /f "delims=" %%F IN ('sfk list -hidden -quiet -quot -dir %~1 -file %~2 2^>nul') DO (set /A count2+=1)
FOR /f "delims=" %%F IN ('sfk list -hidden -quiet -quot -dir %~1 -file %~2 2^>nul') DO (
	if !count3!==0 (cecho {!colG!}[#)
	if "%~2"==".apk" (
		COPY "%%~F" "_INPUT_APK\" >nul
	) else (
		COPY "%%~F" "_INPUT_JAR\" >nul
	)
	set /A count3+=1
	set /A percent=!count3!*100/!count2!
	set /A diff=!percent!-!progressbar!
	if not diff==0 (
		set hash_sign=
		FOR /L %%a IN (1,1,!diff!) DO set hash_sign=!hash_sign!#
		cecho {!colG!}!hash_sign!
		set progressbar=!percent!
	)
	if !percent!==100 (cecho #]{!colB!}{\n})
)
echo [*] !str_copied_files! !count3!
pause
goto:eof
:baksmaliapk
set count=0
call :log_version "%logD%"
set opt=-l -s
if %deldebuginfo%==ON (set opt=-b %opt%)
FOR %%F IN ("_INPUT_APK\!apk_base!.apk") DO (
	echo [*] !str_baksmaling! %%~nxF...
	echo [*] !str_baksmaling! %%~nxF...>>%logD%
	call :baksmali "%%~nxF" "_INPUT_APK"
)
call :done "%logD%"
goto restart
:baksmalijar
set count=0
call :log_version "%logD%"
set opt=
if %deldebuginfo%==ON (set opt=-b)
FOR %%F IN ("_INPUT_JAR\!jar_base!.jar") DO (
	echo [*] !str_baksmaling! %%~nxF...
	echo [*] !str_baksmaling! %%~nxF...>>%logD%
	call :baksmali "%%~nxF" "_INPUT_JAR"
)
call :done "%logD%"
goto restart
:smaliapk
set count=0
call :log_version "%logR%"
FOR /D %%F IN ("_INPUT_APK\!apk_base!") DO (
	if not "%%~nxF"=="_RES_REPLACE" (
		echo [*] !str_smaling! %%~nxF...
		echo [*] !str_smaling! %%~nxF...>>%logR%
		call :smali "%%~nxF.apk" "_INPUT_APK"
	)
)
call :done "%logR%"
goto restart
:smalijar
set count=0
call :log_version "%logR%"
FOR /D %%F IN ("_INPUT_JAR\!jar_base!") DO (
	echo [*] !str_smaling! %%~nxF...
	echo [*] !str_smaling! %%~nxF...>>%logR%
	call :smali "%%~nxF.jar" "_INPUT_JAR"
)
call :done "%logR%"
goto restart
:baksmali
rd /s /q "%~2\%~n1" 2>nul
7za x "%~2\%~nx1" -o"%~2\%~n1" *.dex -aoa >nul 2>>%logD%
FOR %%F IN ("%~2\%~n1\*.dex") DO (
	if "%%~nF"=="classes" (set REN2=smali) else (set REN2=smali_%%~nF)
	java -Xmx512m -jar "%bindir%bak!smali!" -a %api% %opt% -o "%~2\%~n1\!REN2!" "%%~F" >>%logD% 2>&1
	if errorlevel 1 (
		set /A count+=1
		cecho {!colR!}[*] !str_bsmerror! "%~nx1:%%~nxF"{# #}{\n}
		echo [*] ---^> !str_bsmerror! "%~nx1:%%~nxF">>%logD%
	)
)
del /f /q "%~2\%~n1\*.dex" 2>nul
goto:eof
:smali
FOR /D %%F IN ("%~2\%~n1\smali*") DO (
	set REN2=%%~nxF
	if "%%~nxF"=="smali" (set REN2=classes) else (set REN2=!REN2:smali_=!)
	java -Xmx512m -jar "%bindir%!smali!" -a %api% -o "%~2\%~n1\!REN2!.dex" "%%~F" >>%logR% 2>&1
	if errorlevel 1 (
		set /A count+=1
		cecho {!colR!}[*] !str_smerror! "%~n1"{# #}{\n}
		echo [*] ---^> !str_smerror! "%~n1">>%logR%
		goto:eof
	)
)
if not exist "%~2\%~nx1" (
	set /A count+=1
	cecho {!colR!}[*] !str_orignotfound!{# #}{\n}
	echo [*] ---^> !str_orignotfound!>>%logR%
	goto:eof
)
if "%~2"=="_INPUT_JAR" (
	COPY "%~2\%~nx1" "_OUT_JAR\" >nul
	7za a "_OUT_JAR\%~nx1" ".\%~2\%~n1\*.dex" -mx7 >nul 2>nul
	if errorlevel 1 (
		zip -j -7 "_OUT_JAR\%~nx1" "%~2\%~n1\*.dex" >nul 2>>%logR%
	)
)
if "%~2"=="_INPUT_APK" (
	COPY "%~2\%~nx1" "_OUT_APK\%~n1.temp.apk" >nul
	7za a "_OUT_APK\%~n1.temp.apk" ".\%~2\%~n1\*.dex" -mx7 >nul 2>nul
	if errorlevel 1 (
		zip -j -7 "_OUT_APK\%~n1.temp.apk" "%~2\%~n1\*.dex" >nul 2>>%logR%
	)
	if %sign_after%==ON (
		call :sign "_OUT_APK\%~n1.temp.apk" "%~nx1"
	) else (
		zipalign -f 4 "_OUT_APK\%~n1.temp.apk" "_OUT_APK\%~nx1" 2>nul
	)
	del /f /q "_OUT_APK\%~n1.temp.apk" 2>nul
)
goto:eof
:: --------------------
:adbdevices
cecho {!colG!}  !str_connection_type!{# #}{\n}
echo    1 = USB
echo    2 = Wi-Fi
echo.
echo    3 = !str_cancel!
:_adbdevices
set INPUT=
SET /P INPUT=!str_makechoice! 
IF !INPUT!==1 (goto adbusb)
IF !INPUT!==2 (goto adbwifi)
IF !INPUT!==3 (goto restart)
goto _adbdevices
:adbusb
set adb_wireless=off
adb devices
pause
goto restart
:adbwifi
set INPUT=
if '!adb_ip!'=='' (
	SET /P INPUT=[*] !str_input_ip! 
	if '!INPUT!'=='' (
		goto adbwifi
	) else (
		set adb_ip=!INPUT!
		call :savesettings "adb_ip"
	)
) else (
	SET /P INPUT=[*] !str_input_ip2! !adb_ip!: 
	if not '!INPUT!'=='' (
		set adb_ip=!INPUT!
		call :savesettings "adb_ip"
	)
)
set adb_wireless=on
adb connect !adb_ip!
pause
goto restart
:adbinstall
cecho {!colG!}  !str_installtodef!{# #}{\n}
echo    1 = !str_singlefile!
echo    2 = !str_allfrom! _OUT_APK
cecho {!colG!}  !str_installtosd!{# #}{\n}
echo    3 = !str_singlefile!
echo    4 = !str_allfrom! _OUT_APK
echo.
echo    5 = !str_cancel!
:_adbinstall
set INPUT=
SET /P INPUT=!str_makechoice! 
IF !INPUT!==1 (goto adbinstall2)
IF !INPUT!==2 (goto adbinstall2-b)
IF !INPUT!==3 (goto adbinstall2sd)
IF !INPUT!==4 (goto adbinstall2sd-b)
IF !INPUT!==5 (goto restart)
goto _adbinstall
:adbinstall2
set INPUT=
set /P INPUT=!str_dragtoinstall! 
if exist !INPUT! (
	adb install -rtd !INPUT!
	pause
	goto restart
)
goto adbinstall2
:adbinstall2-b
FOR %%F IN (_OUT_APK\*.apk) DO (
	echo [*] !str_installing! %%~nxF...
	adb install -rtd "%%~F"
)
pause
goto restart
:adbinstall2sd
set INPUT=
set /P INPUT=!str_dragtoinstall! 
if exist !INPUT! (
	adb install -rtsd !INPUT!
	pause
	goto restart
)
goto adbinstall2sd
:adbinstall2sd-b
FOR %%F IN (_OUT_APK\*.apk) DO (
	echo [*] !str_installing! %%~nxF...
	adb install -rtsd "%%~F"
)
pause
goto restart
:adbremount
adb root
if '%adb_wireless%'=='on' (
	adb connect !adb_ip!
)
adb wait-for-device
adb remount
pause
goto restart
:adbpull
cecho {!colG!}  !str_pull2!{# #}{\n}
echo    1 = !str_allfrom! /system/app
echo    2 = !str_allfrom! /system/priv-app
echo    3 = !str_allfrom! /system/framework
echo    4 = !str_allfrom! /system/app, /system/priv-app, /system/framework
echo.
echo    5 = !str_cancel!
:_adbpull
set INPUT=
SET /P INPUT=!str_makechoice! 
IF !INPUT!==1 (
	adb pull -a /system/app _app
	pause
	goto restart
)
IF !INPUT!==2 (
	adb pull -a /system/priv-app _priv-app
	pause
	goto restart
)
IF !INPUT!==3 (
	adb pull -a /system/framework _framework
	pause
	goto restart
)
IF !INPUT!==4 (
	adb pull -a /system/framework _framework
	adb pull -a /system/app _app
	adb pull -a /system/priv-app _priv-app
	pause
	goto restart
)
IF !INPUT!==5 (goto restart)
goto _adbpull
:adbpush
cecho {!colG!}  !str_pushto! /system/app:{# #}{\n}
echo    1 = !str_singlefile!
echo    2 = !str_allfrom! _OUT_APK
cecho {!colG!}  !str_pushto! /system/priv-app:{# #}{\n}
echo    3 = !str_singlefile!
echo    4 = !str_allfrom! _OUT_APK
cecho {!colG!}  !str_pushto! /system/framework:{# #}{\n}
echo    5 = !str_singlefile!
echo    6 = !str_allfrom! _OUT_APK
echo    7 = !str_allfrom! _OUT_JAR
cecho {!colG!}  !str_pushto! /sdcard/BAT:{# #}{\n}
echo    8 = !str_singlefile!
echo    9 = !str_allfrom! _OUT_APK
echo.
echo    10 = !str_cancel!
:_adbpush
set INPUT=
SET /P INPUT=!str_makechoice! 
IF !INPUT!==1 (call :adbpush3 /system/app) & goto restart
IF !INPUT!==2 (call :adbpush4 _OUT_APK /system/app) & goto restart
IF !INPUT!==3 (call :adbpush3 /system/priv-app) & goto restart
IF !INPUT!==4 (call :adbpush4 _OUT_APK /system/priv-app) & goto restart
IF !INPUT!==5 (call :adbpush3 /system/framework) & goto restart
IF !INPUT!==6 (call :adbpush4 _OUT_APK /system/framework) & goto restart
IF !INPUT!==7 (call :adbpush4 _OUT_JAR /system/framework) & goto restart
IF !INPUT!==8 (call :adbpush2 /sdcard/BAT) & goto restart
IF !INPUT!==9 (adb push _OUT_APK /sdcard/BAT) & pause & goto restart
IF !INPUT!==10 (goto restart)
goto _adbpush
:adbpush2
set INPUT=
set /P INPUT=!str_dragtopush! 
if exist !INPUT! (
	adb shell mkdir -p %~1
	adb push !INPUT! %~1
) else (
	goto adbpush2
)
pause
goto:eof
:adbpush3
set INPUT=
set /P INPUT=!str_dragtopush! 
if exist !INPUT! (
	FOR %%F IN (!INPUT!) DO (
		adb push !INPUT! %~1
		if not errorlevel 1 (adb shell chmod 644 '%~1/%%~nxF')
	)
) else (
	goto adbpush3
)
pause
goto:eof
:adbpush4
::<nul set /p =.	rem echo without new line
adb push %~1 %~2
if not errorlevel 1 (
	FOR /f "delims=" %%a IN ('sfk list -hidden -quiet -quot -relnames %~1 2^>nul') DO (
		set REN2=%%~a
		adb shell chmod 644 '%~2/!REN2:\=/!'
	)
)
pause
goto:eof
:adbscreenshot
adb shell screencap -p /sdcard/screenshot.png
nircmdc wait 1000
adb pull /sdcard/screenshot.png
if exist screenshot.png (
	adb shell rm /sdcard/screenshot.png
	call :get_date_time
	ren "screenshot.png" "screenshot_!DATE2!_!TIME2!.png" 2>nul
	echo [*] !str_screensavedto! "screenshot_!DATE2!_!TIME2!.png"
) else (
	cecho {!colR!}!str_error!{# #}{\n}
)
pause
goto restart
:screenrecord
echo n|start /max /wait cmd /c "mode 80,25& echo [*] !str_closetostop!& adb shell screenrecord --verbose /sdcard/screenrecord.mp4"
nircmdc wait 3000
adb pull /sdcard/screenrecord.mp4
if exist screenrecord.mp4 (
	adb shell rm /sdcard/screenrecord.mp4
	call :get_date_time
	ren "screenrecord.mp4" "screenrecord_!DATE2!_!TIME2!.mp4" 2>nul
	echo [*] !str_scrrecsavedto! "screenrecord_!DATE2!_!TIME2!.mp4"
) else (
	cecho {!colR!}!str_error!{# #}{\n}
)
pause
goto restart
:adbshell
start /max cmd /c "mode 120,9999& adb shell"
goto restart
:adblogs
cecho {!colG!}  Logcat:{# #} !str_toscreen!{\n}
echo    1 = Logcat
echo    2 = Logcat (!str_logcatr!)
echo    3 = Logcat (!str_logcate!)
cecho {!colG!}  Dmesg:{# #}{\n}
echo    4 = !str_tofile!
cecho {!colG!}  !str_bugreport!{# #}{\n}
echo    5 = !str_tofile!
cecho {!colG!}  !str_inlinetable!{# #}{\n}
echo    6 = !str_tofile!
echo.
echo    7 = !str_cancel!
:_adblogs
set INPUT=
SET /P INPUT=!str_makechoice! 
IF !INPUT!==1 (goto adblogcat)
IF !INPUT!==2 (goto adblogcatr)
IF !INPUT!==3 (goto adblogcate)
IF !INPUT!==4 (goto adbdmesg)
IF !INPUT!==5 (goto adbbug)
IF !INPUT!==6 (goto adbinline)
IF !INPUT!==7 (goto restart)
goto _adblogs
:adblogcat
call :get_date_time
:: sed "s/[^^^A-Z]*//" rem regular expression to cut datetime in logcat
start /max cmd /c "mode 120,9999& adb logcat -v time | wtee "logcat_!DATE2!_!TIME2!.txt" | coloredlogcat"
echo !str_saved_to_file! "logcat_!DATE2!_!TIME2!.txt"
pause
goto restart
:adblogcatr
call :get_date_time
start /max cmd /c "mode 120,9999& adb logcat -b radio -v time | wtee "logcat_radio_!DATE2!_!TIME2!.txt" | coloredlogcat"
echo !str_saved_to_file! "logcat_radio_!DATE2!_!TIME2!.txt"
pause
goto restart
:adblogcate
call :get_date_time
start /max cmd /c "mode 120,9999& adb logcat -b events -v time | wtee "logcat_events_!DATE2!_!TIME2!.txt" | coloredlogcat"
echo !str_saved_to_file! "logcat_events_!DATE2!_!TIME2!.txt"
pause
goto restart
:adbdmesg
call :get_date_time
adb shell dmesg >"dmesg_!DATE2!_!TIME2!.txt"
nhrplc -sre:"\r(?=\r\n)" -t:"" "dmesg_!DATE2!_!TIME2!.txt" >nul
echo !str_saved_to_file! "dmesg_!DATE2!_!TIME2!.txt"
pause
goto restart
:adbbug
call :get_date_time
adb bugreport >"bugreport_!DATE2!_!TIME2!.txt"
nhrplc -sre:"\r(?=\r\n)" -t:"" "bugreport_!DATE2!_!TIME2!.txt" >nul
echo !str_saved_to_file! "bugreport_!DATE2!_!TIME2!.txt"
pause
goto restart
:adbinline
adb push %bindir%deodexerant /sdcard/
adb shell su -c 'cp -f /sdcard/deodexerant /data/'
adb shell su -c 'chmod 755 /data/deodexerant'
adb shell /data/deodexerant > inline.txt
adb shell rm /sdcard/deodexerant
adb shell su -c 'rm /data/deodexerant'
nhrplc -sre:"\r(?=\r\n)" -t:"" "inline.txt" >nul
echo !str_saved_to_file! "inline.txt"
pause
goto restart
:adbinfo
echo.
FOR /f "tokens=1* delims=:" %%a IN ('adb shell getprop ^| sort') DO (
	if /I "%%a"=="[ro.build.version.release]" (echo !str_android_version!%%b)
	if /I "%%a"=="[ro.product.brand]" (echo !str_brand!%%b)
	if /I "%%a"=="[ro.product.model]" (echo !str_model!%%b)
)
echo.
adb shell df
echo.
pause
goto restart
:adbreboot
cecho {!colG!}  !str_reboot2!{# #}{\n}
echo    1 = !str_reboot3!
echo    2 = !str_rebootto! recovery
echo    3 = !str_rebootto! bootloader
echo.
echo    4 = !str_cancel!
:_adbreboot
set INPUT=
SET /P INPUT=!str_makechoice! 
IF !INPUT!==1 (goto rebootnormal)
IF !INPUT!==2 (goto rebootrecovery)
IF !INPUT!==3 (goto rebootbootloader)
IF !INPUT!==4 (goto restart)
goto _adbreboot
:rebootrecovery
echo !str_rebootto! recovery...
adb reboot recovery
goto restart
:rebootbootloader
echo !str_rebootto! bootloader...
adb reboot bootloader
goto restart
:rebootnormal
echo !str_reboot3!...
adb reboot
goto restart
:adbexit
adb kill-server
cecho {!colG!}!str_done!{# #}{\n}
pause
goto restart
:about
cls
COLOR 07
call :empty_line 21
cecho               {0A}####{#}    #   ##### #   # #   #        {0A}#{#}   ##### #   # {0A}#####{#}  ###   ###  #####{\n}
cecho                {09}#{#}     # #    #   #   #  # #        {09}# #{#}  #   # #  #    {09}#{#}   #   # #   #  #  #{\n}
cecho                {0E}####{#} #####   #    ####   #        {0E}#####{#} #   # ###     {0E}#{#}   #   # #   #  #  #{\n}
cecho                {0B}#  #{#} #   #   #       #  # #       {0B}#   #{#} #   # #  #    {0B}#{#}   #   # #   #  #  #{\n}
cecho               {0D}#####{#} #   #   #       # #   #      {0D}#   #{#} #   # #   #   {0D}#{#}    ###   ###  #   #{\n}
call :empty_line 21
start /B nircmdc speak text "Batch ApkTool"
pause
COLOR %colB%
goto restart
:empty_line
FOR /L %%a IN (1,1,%~1) DO echo.
goto:eof
