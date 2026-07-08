@echo off
REM Launches Forge Code in a Windows Terminal window, running inside WSL Ubuntu
REM with cwd mapped to this folder via /mnt/c/. Forge runs as a native Linux ELF
REM under a real Linux pty, so arrow/backspace/delete keys work and there is no
REM MSYS pty wrapping layer to corrupt input after the first prompt.
REM
REM History:
REM   v1: cmd  -> forge                              (blank window, no TUI render)
REM   v2: mintty -> bash -> forge                    (arrows/backspace/delete dead)
REM   v3: wt -> bash -> forge + MSYS=enable_pcon     (input freezes after 1 prompt)
REM   v4: wt -> pwsh -> forge.exe                    (still broke after 1 prompt)
REM   v5: wt -> wsl -> bash -> forge (linux ELF)     (this file)
REM
REM Real launch logic lives in .forge-launch.sh next to this file. The .sh runs
REM inside WSL, so it uses Linux paths (HERE will be /mnt/c/AudioL2 etc).

setlocal

set "WT=%LocalAppData%\Microsoft\WindowsApps\wt.exe"
if not exist "%WT%" set "WT=wt.exe"

REM %~dp0 ends with a trailing backslash; strip it so the closing quote in
REM --cd "..." isn't interpreted as an escaped quote by cmd.
set "HERE=%~dp0"
set "HERE=%HERE:~0,-1%"

set "LAUNCHER=%HERE%\.forge-launch.sh"
if not exist "%LAUNCHER%" (
    echo ERROR: Launcher script not found at "%LAUNCHER%".
    pause
    exit /b 1
)

REM Confirm WSL Ubuntu exists. If not, bail with a helpful message.
wsl.exe -d Ubuntu -- true >nul 2>&1
if errorlevel 1 (
    echo ERROR: WSL distro "Ubuntu" is not available.
    echo Run: wsl --install -d Ubuntu
    pause
    exit /b 1
)

REM -w new            => always open a fresh Windows Terminal window
REM nt                => new-tab subcommand
REM --title Forge     => set tab title
REM wsl.exe -d Ubuntu => run inside the Ubuntu distro
REM --cd "%HERE%"     => set cwd via Windows path (Linux /mnt/c/... form gets
REM                      mangled by MSYS path conversion when called from bash,
REM                      but this is cmd.exe so a Windows path is correct)
REM --                => everything after this is the literal command line
REM bash -l ./.forge-launch.sh
REM                   => login bash runs the launcher script in the cwd
start "" "%WT%" -w new nt --title Forge wsl.exe -d Ubuntu --cd "%HERE%" -- bash -l ./.forge-launch.sh

endlocal
