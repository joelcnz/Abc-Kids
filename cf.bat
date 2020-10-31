@echo off
rem src = abc5 .. doesn't work, has to be src=abc5 (no spaces)
set src=main base world media input keyhandling keys texthandling current
echo cf -r  for release version
echo cf -d  for creating html files
echo cf     default developing

if "%1"=="" (
echo ----- Doing a version for WIP ------
dmj -ofbin\Debug\abc5 *.d bin\Debug\abc.res -debug -debug=TDD -d
)

if "%1"=="-r" (
echo ------ Doing a release version that runs without a terminal ------
dmj -ofbin\Debug\abc5 bin\Debug\abc.res *.d looseterm.def
del *.obj
del *.map
)

if "%1"=="-d" (
echo ------ Doing documentation ------
echo open html folder, select all files, then right click open. Note: Firefox doesn't know what to do
dmj ..\..\*.d -c -D
move *.html html
)
