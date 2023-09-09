#!/bin/bash

if [ $# -lt 2 ]; then
    echo $#
    echo "usage: $0 <platform> <buildroot config file> <TbusBuild config file>"
    exit 1
fi

platform="$1"
buildroot_config_file="$2"
tbus_build_config_file="$3"
found_app_platform=false
found_driver_platform=false
found_tools_platform=false

if [ ! -f "$buildroot_config_file" ]; then
    echo "$buildroot_config_file not exist"
    exit 1
fi

if [ "${platform: 0:8}" != "platform" ] && [ "${platform: 0:3}" != "app" ] \
    && [ "${platform: 0:6}" != "driver" ] && [ "${platform: 0:5}" != "tools" ]; then
    echo "platform error"
    exit 1
fi

if [ "$platform" = "platform" ]; then
    while IFS= read -r line; do
        if [[ "$line" =~ ^APP_PLATFORM=y$ ]]; then
            found_app_platform=true
        elif [[ "$line" =~ ^DRIVER_PLATFORM=y$ ]]; then
            found_driver_platform=true
        elif [[ "$line" =~ ^TOOLS_PLATFORM=y$ ]]; then
            found_tools_platform=true
        fi
    done < "$tbus_build_config_file"
fi

make_package()
{
    local package_name="$1"
    local lowercase_package_name="${package_name,,}"
    echo "$package_name -> $lowercase_package_name"
    if [[ "${platform:(-6):6}" = "_clean" ]]; then
        make "$lowercase_package_name-dirclean"
    else
        make "$lowercase_package_name-auto"
    fi
}

while IFS= read -r line; do
    if [[ "${platform:0:3}" = "app" ]] || [[ "${platform:0:6}" = "driver" ]] || [[ "${platform:0:5}" = "tools" ]] || [[ "$platform" = "platform_all_clean" ]] || [[ "$platform" = "platform" ]]; then
        if [[ "$line" =~ ^BR2_PACKAGE_(APP|DRIVER|TOOLS)_([a-zA-Z0-9_]+)=y$ ]]; then
            package_type="${BASH_REMATCH[1]}"
            package_name="${BASH_REMATCH[2]}"

            if ([[ "$package_type" = "APP" ]] && [[ "${platform:0:3}" = "app" ]]) ||
            ([[ "$package_type" = "DRIVER" ]] && [[ "${platform:0:6}" = "driver" ]]) ||
            ([[ "$package_type" = "TOOLS" ]] && [[ "${platform:0:5}" = "tools" ]]) ||
            [ "$platform" = "platform_all_clean" ] || [ "$platform" = "platform" ]; then
                make_package "$package_name" "$platform"
            fi
        fi
    fi
done < "$buildroot_config_file"
