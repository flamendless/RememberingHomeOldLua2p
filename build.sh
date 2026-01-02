#!/bin/bash

lua=luajit
os=$(uname)
lpp_path=./libs/LPP/preprocess-cl.lua
gv=$(git log -1 --format='v%cd.%h' --date=short 2>/dev/null)
data=dev
handler=handler.lua
padding=4

dir_modules=modules
dir_res=res
dir_output=output_dev
dir_source=src

dir_sub=(assemblages components shaders states systems)
appdata=~/.local/share/love/goinghomerevisited

meta_exclude_modules=(
	spec docs example test love-sdf-text-testing rockspecs main.lua .travis
	.git examples .travis.yml changelog.txt README.md MakeSingle.mak bench
	CHANGELOG.md *.rockspec config.ld performance_test.lua USAGE.md img
)
exclude_modules=()
for e in "${meta_exclude_modules[@]}"; do
	exclude_modules+=("--exclude=$e")
done

function create_output_dir()
{
	if [ ! -d "$dir_output" ]; then
		echo "creating $dir_output..."
		mkdir $dir_output && echo "created $dir_output"
	fi
}

function process_src()
{
	for file in "$1"/*; do
		if [ -d "$file" ]; then
			local subd=$(echo "$file" | rev | cut -d'/' -f-1 | rev)
			if [ ! -d "$dir_output"/"$subd" ]; then
				mkdir "$dir_output"/"$subd"
			fi
			process_src "$file" "$subd"
		elif [ -f "$file" ]; then
			process_file "$file" "$2"
		fi
	done
}

function process_file()
{
	local filename="${1##*/}"
	local file=$(basename "$filename" .lua2p)
	local ext="${filename##*.}"
	local out=$dir_output/$2/$file

	if [ "$ext" == "lua2p" ]; then
		$lua "$lpp_path" --handler="$handler" --data="$data $gv $padding" --outputpaths "$1" "$out".lua --silent;
		if [ $? -ne 0 ]; then
			echo "error in $1"
			exit;
		fi
	else
		cp "$1" "$out"
	fi
}

function check()
{
	# https://luacheck.readthedocs.io/en/stable/cli.html
	local file="$dir_output"
	if [ $# -eq 2 ]; then
		if [[ $2 == src* ]]; then
			file="${file}/${2:4}"
		else
			file="${file}/$2"
		fi
	fi
	luacheck $file -q \
		--exclude-files "output_dev/modules/**/*.lua" \
		--std luajit \
		--globals love stringx mathx tablex pretty intersect timer \
		--no-max-line-length \
		--ignore 611 \
		--jobs 2
}

function create_atlas()
{
	eta_path=./libs/ExportTextureAtlas/
	output_path=./res/images/atlases
	source_path=./res/exported
	exported_dirs=(intro kitchen living_room outside storage_room utility_room)
	input_dirs=()
	output_dirs=()
	data_dirs=()
	ignores=()

	for cur_dir in "${exported_dirs[@]}"; do
		in_dir=$source_path/$cur_dir/
		out_dir=$output_path/$cur_dir.png
		data_dir=./src/atlases/atlas_$cur_dir.lua
		ignore=$source_path/$cur_dir/$cur_dir.png
		input_dirs+=($in_dir)
		output_dirs+=($out_dir)
		data_dirs+=($data_dir)
		ignores+=($ignore)
		echo "gen atlas: '$in_dir' -> '$out_dir' + '$data_dir' !'$ignore'"
	done

	love $eta_path \
		-input "${input_dirs[@]}" \
		-output "${output_dirs[@]}" \
		-dataOutput "${data_dirs[@]}" \
		-ignore "${ignores[@]}" \
		-removeFileExtension \
		-padding $padding \
		-template "./scripts/atlas_template.lua"
}

function copy_modules()
{
	echo "copying modules..."
	rsync -a "$dir_modules" "$dir_output" "${exclude_modules[@]}" && echo "copied modules"
}

function copy_res()
{
	echo "copying resources..."
	rsync -a "$dir_res" "$dir_output" && echo "copied resources"
	rsync -a "slab.style" "$dir_output" && echo "copied slab.style"
}

function clean()
{
	echo "cleaning $dir_output..."
	rm -rf $dir_output/* && echo "cleaned $dir_output"
}

function clean_logs()
{
	echo "cleaning $appdata..."
	rm $appdata/* && echo "removed $appdata"
}

function init()
{
	create_output_dir
	process_src "$dir_source"
	create_atlas
	copy_modules
	copy_res
}

function rebuild()
{
	clean
	init
	cp slab.style $dir_output
}

function run()
{
	echo "Running build.sh"
	process_src "$dir_source"
	if [ $(uname -r | sed -n 's/.*\( *Microsoft *\).*/\1/ip') ]; then
		echo "This is Windows WSL!"
		./build_win.sh run
	else
		echo "This is Linux"
		love "$dir_output"
	fi
	echo "Completed build.sh"
}

function profile()
{
	data=prof
	dir_output=output_dev
	run && prof_viewer
}

function prof_viewer()
{
	if [ $(uname -r | sed -n 's/.*\( *Microsoft *\).*/\1/ip') ]; then
		echo "This is Windows WSL!"
		./build_win.sh prof_viewer
	else
		echo "This is Linux"
		love modules/jprof goinghomerevisited prof.mpack
	fi
}

if [ $# -eq 0 ]; then
	echo "Must pass command: init, rebuild, clean, run, create_atlas"
else
	"$@"
fi
