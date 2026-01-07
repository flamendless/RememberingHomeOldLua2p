#!/bin/bash

love_title=RememberingHome.love
dir_source=src
dir_output=output_dev
file_makelove=makelove.toml
cmd="/mnt/c/Windows/System32/cmd.exe"
path_love="C:\Program Files\LOVE"
path_game='Z:\home\flamendless\RememberingHome\release\love\'${love_title}
path_prof_viewer="Z:\home\flamendless\RememberingHome\modules\jprof"
echo $path_game

function win32()
{
	cd "$dir_output" && makelove --config ../"$file_makelove" win32
}

function win64()
{
	cd "$dir_output" && makelove --config ../"$file_makelove" win64
}

function love_only()
{
	if [ ! -d release ]; then
		mkdir -p ../release/love
	fi
	cd "$dir_output" && zip -9ru "../release/love/${love_title}" . -x "${love_title}"
}

function prof_viewer()
{
	$cmd /c "cd $path_love & lovec.exe $path_prof_viewer rememberinghome prof.mpack"
}

function run()
{
	echo "Running build_win.sh"
	# TODO change this when in RELEASE mode
	# win64
	love_only
	$cmd /c start cmd.exe /c "cd $path_love && lovec.exe $path_game & pause"
	echo "Completed build_win.sh"
}

if [ $# -eq 0 ]; then
	echo "Must pass command: win32, win64, run"
else
	"$@"
fi
