:: ReplaceRes v1.0.1
:: Автор: bursoft
:: Плагин предназначен для замены ресурсов в APK без рекомпиляции, то есть он просто добавляет файлы в APK (без сжатия).
:: Ниже указаны некоторые переменные, которые используются при работе плагина:
:: Текущий каталог - папка текущего проекта
:: !plugdir! - каталог плагина\
:: !bindir! - каталог bin\
:: !apk_name! - выбранный APK-файл
:: !sign_after! - состояние опции "Подписать результирующий APK" (ON\OFF)
:: Эти и другие переменные можно найти в BATCHAPKTOOL.bat и в файлах локализации (!bindir!language\*.lng и !plugdir!language\*.lng).
if "%bat_version%"=="" goto:eof
cls
echo.
cecho {!colG!}!bat_title!{# #}{\n}
echo !bat_page!
echo !bat_line!
echo.
echo !str_plugin_name!.
echo.
set count=0
md "_INPUT_APK\_RES_REPLACE" 2>nul
FOR %%F IN ("_INPUT_APK\!apk_name!") DO (
if exist "_INPUT_APK\_RES_REPLACE\%%~nF\" (
	echo [*] !str_replacing! %%~nxF...
	copy "_INPUT_APK\%%~nxF" "_OUT_APK\%%~nF.temp%%~xF" >nul
	7za a "_OUT_APK\%%~nF.temp%%~xF" ".\_INPUT_APK\_RES_REPLACE\%%~nF\*" -mx0 >nul
	if not errorlevel 1 (
		if !sign_after!==ON (
			java -jar "!bindir!signapk.jar" "!bindir!!key_base!.x509.pem" "!bindir!!key_name!" "_OUT_APK\%%~nF.temp%%~xF" "_OUT_APK\%%~nF.signed%%~xF"
			if not errorlevel 1 (
				zipalign -f 4 "_OUT_APK\%%~nF.signed%%~xF" "_OUT_APK\%%~nxF" 2>nul
			) else (
				set /A count+=1
				cecho {!colR!}[*] !str_signing_error! %%~nxF{# #}{\n}
			)
			del /f /q "_OUT_APK\%%~nF.signed%%~xF" 2>nul
		) else (
			zipalign -f 4 "_OUT_APK\%%~nF.temp%%~xF" "_OUT_APK\%%~nxF" 2>nul
		)
	) else (
		set /A count+=1
		cecho {!colR!}[*] !str_replacing_error! %%~nxF{# #}{\n}
	)
	del /f /q "_OUT_APK\%%~nF.temp%%~xF" 2>nul
)
)
echo.
if !count! GTR 0 (cecho {!colR!}%str_doneerrors%{# #}{\n}) else (cecho {!colG!}!str_done!{# #}{\n})
pause
