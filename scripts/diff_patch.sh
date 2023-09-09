#!/bin/bash

do_diff()
{
    mkdir -p "buildroot-"$1"_org" && tar zxvf "dl/buildroot-"$1".tar.gz" -C "./buildroot-"$1"_org" --strip-components 1

    diff -urNa "buildroot-"$1"_org" "buildroot-"$1 > out.patch

    patch_file="out.patch"
    temp_dir="patches"

    mkdir -p "$temp_dir"

    while IFS= read -r line; do
        if [[ $line =~ ^diff\ -urNa ]]; then
            line_parts=($line)

            source_file=${line_parts[2]}
            target_file=${line_parts[3]}

            source_filename=$(basename "$source_file")
            target_filename=$(basename "$target_file")

            read -r line2
            read -r line3

            target_dir=$(dirname "$target_file")
            line2_modified="--- $target_dir/$target_filename${line2:0-36}"

            patch_filename="${temp_dir}/${target_filename}.patch"

            echo "$line2_modified" >> "$patch_filename"
            echo "$line3" >> "$patch_filename"
        else
            echo "$line" >> "$patch_filename"
        fi
    done < "$patch_file"

    rm -rf buildroot-"$1"_org

    rm $patch_file

    echo "Split complete."
}

do_patch()
{
    for file in `ls patches`
	do
		patch -p0 < "patches/$file"
	done
}

case $1 in
    --diff)
        do_diff $2
        ;;
    --patch)
        do_patch
        ;;
    --help | -h | *)
        echo "[Usage] ./diff_patch.sh"
        echo "--diff	build patch"
        echo "--patch	patch"
        ;;
esac