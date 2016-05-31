:: ColorPicker v1.0.1
:: Автор: bursoft
:: Плагин позволяет настроить цвета основных элементов интерфейса Batch ApkTool
if "%bat_version%"=="" goto:eof

bg cursor 0
set colB0=%colB:~0,1%
set colB1=%colB:~1,1%
set colR1=%colR:~1,1%
set colG1=%colG:~1,1%

:begin
cls
COLOR %colB0%%colB1%
cecho {\n}{%colB0%%colG1%}%bat_title%{# #}{\n}%bat_page%{\n}%bat_line%{\n}{\n}%str_title%{\n}{\n}  %str_sampleB1% ^| {00}    {10}    {20}    {30}    {40}    {50}    {60}    {70}    {80}    {90}    {A0}    {B0}    {C0}    {D0}    {E0}    {F0}    {# #} ^|{\n}                                   ^| {00}    {10}    {20}    {30}    {40}    {50}    {60}    {70}    {80}    {90}    {A0}    {B0}    {C0}    {D0}    {E0}    {F0}    {# #} ^|{\n}{\n}  {%colB0%%colR1%}%str_sampleR1%{# #} ^| {00}    {10}    {20}    {30}    {40}    {50}    {60}    {70}    {80}    {90}    {A0}    {B0}    {C0}    {D0}    {E0}    {F0}    {# #} ^|{\n}                                   ^| {00}    {10}    {20}    {30}    {40}    {50}    {60}    {70}    {80}    {90}    {A0}    {B0}    {C0}    {D0}    {E0}    {F0}    {# #} ^|{\n}{\n}  {%colB0%%colG1%}%str_sampleG1%{# #} ^| {00}    {10}    {20}    {30}    {40}    {50}    {60}    {70}    {80}    {90}    {A0}    {B0}    {C0}    {D0}    {E0}    {F0}    {# #} ^|{\n}                                   ^| {00}    {10}    {20}    {30}    {40}    {50}    {60}    {70}    {80}    {90}    {A0}    {B0}    {C0}    {D0}    {E0}    {F0}    {# #} ^|{\n}{\n}  %str_sampleB0% ^| {00}    {10}    {20}    {30}    {40}    {50}    {60}    {70}    {80}    {90}    {A0}    {B0}    {C0}    {D0}    {E0}    {F0}    {# #} ^|{\n}                                   ^| {00}    {10}    {20}    {30}    {40}    {50}    {60}    {70}    {80}    {90}    {A0}    {B0}    {C0}    {D0}    {E0}    {F0}    {# #} ^|{\n}{\n}{\n}                   {F0}       OK       {# #}         {F0}%str_buttonD%{# #}         {F0}%str_buttonC%{# #}

:read
bg mouse >nul 2>nul
set "input=%ErrorLevel%"
set /A "mouseRow=input >> 0x10, mouseCol=input & 0xFFFF"
::bg print "%mouseRow%-%mouseCol% "

If %mouseRow%==21 (
	if %mouseCol% GEQ 20 (if %mouseCol% LEQ 35 (
		set colB=%colB0%%colB1%
		set colG=%colB0%%colG1%
		set colR=%colB0%%colR1%
		if not exist "%bindir%settings.ini" type nul >"%bindir%settings.ini"
		inifile "%bindir%settings.ini" [global_settings] "colB=!colB!"
		inifile "%bindir%settings.ini" [global_settings] "colG=!colG!"
		inifile "%bindir%settings.ini" [global_settings] "colR=!colR!"
		bg cursor 1
		goto:eof
	))
	if %mouseCol% GEQ 45 (if %mouseCol% LEQ 60 (
		if %colB0%%colB1%%colR1%%colG1%==07CA (goto read)
		set colB0=0
		set colB1=7
		set colR1=C
		set colG1=A
		goto begin
	))
	if %mouseCol% GEQ 70 (if %mouseCol% LEQ 85 (
		bg cursor 1
		goto:eof
	))
)

if %mouseRow% GEQ 8 (if %mouseRow% LEQ 9 (
	set _code=B1
	goto select_color
))
if %mouseRow% GEQ 11 (if %mouseRow% LEQ 12 (
	set _code=R1
	goto select_color
))
if %mouseRow% GEQ 14 (if %mouseRow% LEQ 15 (
	set _code=G1
	goto select_color
))
if %mouseRow% GEQ 17 (if %mouseRow% LEQ 18 (
	set _code=B0
	goto select_color
))
goto :read

:select_color
if %mouseCol% GEQ 38 (if %mouseCol% LEQ 41 (
	set _color=0
	goto set_color
))
if %mouseCol% GEQ 42 (if %mouseCol% LEQ 45 (
	set _color=1
	goto set_color
))
if %mouseCol% GEQ 46 (if %mouseCol% LEQ 49 (
	set _color=2
	goto set_color
))
if %mouseCol% GEQ 50 (if %mouseCol% LEQ 53 (
	set _color=3
	goto set_color
))
if %mouseCol% GEQ 54 (if %mouseCol% LEQ 57 (
	set _color=4
	goto set_color
))
if %mouseCol% GEQ 58 (if %mouseCol% LEQ 61 (
	set _color=5
	goto set_color
))
if %mouseCol% GEQ 62 (if %mouseCol% LEQ 65 (
	set _color=6
	goto set_color
))
if %mouseCol% GEQ 66 (if %mouseCol% LEQ 69 (
	set _color=7
	goto set_color
))
if %mouseCol% GEQ 70 (if %mouseCol% LEQ 73 (
	set _color=8
	goto set_color
))
if %mouseCol% GEQ 74 (if %mouseCol% LEQ 77 (
	set _color=9
	goto set_color
))
if %mouseCol% GEQ 78 (if %mouseCol% LEQ 81 (
	set _color=A
	goto set_color
))
if %mouseCol% GEQ 82 (if %mouseCol% LEQ 85 (
	set _color=B
	goto set_color
))
if %mouseCol% GEQ 86 (if %mouseCol% LEQ 89 (
	set _color=C
	goto set_color
))
if %mouseCol% GEQ 90 (if %mouseCol% LEQ 93 (
	set _color=D
	goto set_color
))
if %mouseCol% GEQ 94 (if %mouseCol% LEQ 97 (
	set _color=E
	goto set_color
))
if %mouseCol% GEQ 98 (if %mouseCol% LEQ 101 (
	set _color=F
	goto set_color
))
goto :read

:set_color
if %_code%==B0 (if %_color%==%colB1% (goto read))
if %_code%==B1 (if %_color%==%colB0% (goto read))
if !col%_code%!==%_color% (goto read)
set col%_code%=%_color%
goto begin
