# Rebuild analysis/wf_viewer.exe from wf_viewer.py.
#
# The exe is a PyInstaller one-file bundle, so it goes stale the moment
# wf_viewer.py changes -- rerun this after editing the viewer.
#
# Built from a throwaway venv rather than the conda base env on purpose: conda's
# numpy drags in MKL, which makes the bundle 256 MB and slow to start. The pip
# (OpenBLAS) wheels give 42 MB and a ~3 s cold start.
#
#   powershell -ExecutionPolicy Bypass -File analysis\build_wf_viewer.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$work = Join-Path $env:TEMP 'wf_viewer_build'
$venv = Join-Path $work 'venv'
$py   = Join-Path $venv 'Scripts\python.exe'

if (-not (Test-Path $py)) {
    Write-Host "Creating build venv in $venv ..."
    python -m venv $venv
    & $py -m pip install --upgrade pip
    & $py -m pip install numpy h5py matplotlib pyinstaller
}

& $py -m PyInstaller --noconfirm --onefile --windowed --name wf_viewer `
    --distpath $root\analysis --workpath $work\build --specpath $work\build `
    --exclude-module PyQt5 --exclude-module PyQt6 `
    --exclude-module PySide2 --exclude-module PySide6 `
    --exclude-module IPython --exclude-module pandas --exclude-module scipy `
    $root\analysis\wf_viewer.py

Write-Host "Built $root\analysis\wf_viewer.exe"
