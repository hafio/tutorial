@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
  echo Usage: %~nx0 input_video [output_video]
  exit /b 1
)

set "input=%~1"

if "%~2"=="" (
  for %%F in ("%input%") do (
    set "filename=%%~nF"
    set "extension=%%~xF"
  )
  set "output=!filename!_output!extension!"
) else (
  set "output=%~2"
)

ffmpeg -i "%input%" -c:v libx265 -crf 28 -preset medium "!output!"