@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
SET DC_WORKS_DIR=%~DP0
SET SolutionDIR=%CD%

ECHO [%SolutionDIR%] DC_Universal_Build.bat started ....
ECHO.
CALL :String_Contains "%SolutionDIR%", "S17"
IF %ERRORLEVEL% == 0 ( REM S17
	ECHO [S17]
	GOTO :S17_Build
) ELSE (
	CALL :String_Contains "!SolutionDIR!", "P63"
	IF !ERRORLEVEL! == 0 ( REM P63
		ECHO [P63]
		GOTO :P63_Build
	) ELSE (
		CALL :String_Contains "!SolutionDIR!", "S11"
		IF !ERRORLEVEL! == 0 ( REM S11
			REM ECHO [S11]
			CALL :String_Contains "!SolutionDIR!", "4XX"
			IF !ERRORLEVEL! == 0 (
				ECHO [S11_4XX]
			) ELSE (
				CALL :String_Contains "!SolutionDIR!", "423"
				IF !ERRORLEVEL! == 0 (
					ECHO [S11_423]
				) ELSE (
					CALL :String_Contains "!SolutionDIR!", "5XX"
					IF !ERRORLEVEL! == 0 (
						ECHO [S11_5XX]
						GOTO :S11_5XX_Build
					) ELSE (
						CALL :String_Contains "!SolutionDIR!", "523"
						IF !ERRORLEVEL! == 0 (
							ECHO [S11_523]
							GOTO :S11_5XX_Build
						) ELSE (
							ECHO [S11_Others]
							ECHO Any other project type? Please report this to the developer.
						)
					)
				)
			)
		) ELSE (
			CALL :String_Contains "!SolutionDIR!", "S16"
			IF !ERRORLEVEL! == 0 ( REM S16
				CALL :String_Contains "!SolutionDIR!", "4XX"
				IF !ERRORLEVEL! == 0 (
					ECHO [S16_4XX]
					GOTO :S16_4XX_Build
				) ELSE (
					CALL :String_Contains "!SolutionDIR!", "423"
					IF !ERRORLEVEL! == 0 (
						ECHO [S16_423]
						GOTO :S16_4XX_Build
					) ELSE (
						CALL :String_Contains "!SolutionDIR!", "5XX"
						IF !ERRORLEVEL! == 0 (
							ECHO [S16_5XX]
							GOTO :S16_5XX_Build
						) ELSE (
							CALL :String_Contains "!SolutionDIR!", "523"
							IF !ERRORLEVEL! == 0 (
								ECHO [S16_523]
								GOTO :S16_5XX_Build
							) ELSE (
								ECHO [S16_Others]
								ECHO Any other project type? Please report this to the developer.
							)
						)
					)
				)
			) ELSE (
				ECHO [NOT P63/S16/S17]
				ECHO Any other project type? Please report this to the developer.
			)
		)
	)
)

EXIT /B 0



:String_Contains
REM String_Contains A B
REM Check whether string A contains string B

SET A=%~1
SET "C=!A:%~2=!"
IF "!C!" == "!A!" (
	REM ECHO string "%~1" does not contain string "%~2"
	EXIT /B 1
) ELSE (
	REM ECHO string "%~1" contains string "%~2"
	EXIT /B 0
)


:S16_4XX_Build
PUSHD "%SolutionDIR%\DevelopmentEnvironment\S16_423\Air780e_S16"
SET PATH=%PATH%;%DC_WORKS_DIR%\RunTime\xmake_x64
SET PROJECT_DIR=!SolutionDIR!\DevelopmentEnvironment\S16_423\Air780e_S16\Application
REM clean.bat Application

REM build.bat Application disable -v && CD /D "%DC_WORKS_DIR%Tools\luatools" & START "" Luatools_v2.exe
CALL build.bat Application -v
pslist | grep -i luatools_v2 > nul
IF %ERRORLEVEL% EQU 1 (
	CD /D "%DC_WORKS_DIR%Tools\luatools" & START "" Luatools_v2.exe
) ELSE (
	IF %ERRORLEVEL% EQU 0 A:\APPs\RBTray\64bit\RBtray.exe --restore "Luatools_2.2.8"
)
SET PROJECT_DIR=
EXIT /B 0

:S11_5XX_Build
REM ECHO PUSHD "%SolutionDIR%\DevelopmentEnvironment\S11_523\EC600U_S11"
PUSHD "%SolutionDIR%\DevelopmentEnvironment\S11_523\EC600U_S11"
REM build_app.bat new EC600UEU_AB new_proj release && START "" "%DC_WORKS_DIR%Tools\UPGRADEDOWNLOAD_R23.0.0001\Bin\UpgradeDownload.exe"
CALL build_app.bat new EC600UEU_AB new_proj release
pslist | grep -i UpgradeDownload > nul
IF %ERRORLEVEL% EQU 1 (
	START "" "%DC_WORKS_DIR%Tools\UPGRADEDOWNLOAD_R23.0.0001\Bin\UpgradeDownload.exe"
) ELSE (
	IF %ERRORLEVEL% EQU 0 A:\APPs\RBTray\64bit\RBtray.exe --restore "UpgradeDownload - R23.0.0001"
)
EXIT /B 0

:S16_5XX_Build
PUSHD "%SolutionDIR%\DevelopmentEnvironment\S16_523\EC600U_S16"
CALL build_app.bat new EC600UEU_AB new_proj release
pslist | grep -i UpgradeDownload > nul
IF %ERRORLEVEL% EQU 1 (
	START "" "%DC_WORKS_DIR%Tools\UPGRADEDOWNLOAD_R23.0.0001\Bin\UpgradeDownload.exe"
) ELSE (
	IF %ERRORLEVEL% EQU 0 A:\APPs\RBTray\64bit\RBtray.exe --restore "UpgradeDownload - R23.0.0001"
)
EXIT /B 0


:S17_Build
A:\Keil_v5\UV4\UV4.exe -b"%SolutionDIR%\App source\Project\MDK-ARM\App_Project.uvprojx" -t"APP" -j0 -o"%SolutionDIR%\App source\log.txt" & CALL TYPE "%SolutionDIR%\App source\log.txt"
EXIT /B 0

:P63_Build
REM Extract TargetName from <TargetName>APP</TargetName> of App_Project.uvproj
FOR /F %%I IN ('TYPE "%SolutionDIR%\Project\MDK-ARM(uV4)\App_Project.uvproj" ^| grep -oP "<TargetName>.+</TargetName>" ^| cut -b13- ^| cut -d"<" -f1') DO SET UV_Target=%%I&GOTO :P63_Build_Next
:P63_Build_Next
REM A:\Keil_v5\UV4\UV4.exe -b"%SolutionDIR%\Project\MDK-ARM(uV4)\App_Project.uvproj" -t"APP" -j0 -o"%SolutionDIR%\log.txt" & CALL TYPE "%SolutionDIR%\log.txt"
A:\Keil_v5\UV4\UV4.exe -b"%SolutionDIR%\Project\MDK-ARM(uV4)\App_Project.uvproj" -t"%UV_Target%" -j0 -o"%SolutionDIR%\log.txt" & CALL TYPE "%SolutionDIR%\log.txt"
EXIT /B 0


:Launch_5XX_DL_Tool
ECHO Launch_5XX_DL_Tool

EXIT /B 0
