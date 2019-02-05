#!/usr/bin/env bash

# This file is part of The RetroArena (TheRA)
#
# The RetroArena (TheRA) is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/Retro-Arena/RetroArena-Setup/master/LICENSE.md
#

rp_module_id="advmame"
rp_module_desc="AdvanceMAME v3.9"
rp_module_help="ROM Extension: .zip\n\nCopy your AdvanceMAME roms to either $romdir/mame-advmame or\n$romdir/arcade"
rp_module_licence="GPL2 https://raw.githubusercontent.com/amadvance/advancemame/master/COPYING"
rp_module_section="sa"
rp_module_flags=" !kms"

function _update_hook_advmame() {
    # if the non split advmame is installed, make directories for 0.94 / 1.4 so they will be updated
    # when doing update all packages
    if [[ -d "$md_inst/0.94.0" ]]; then
        mkdir -p "$rootdir/emulators/advmame-"{0.94,1.4}
        printMsgs "dialog" "The advmame package has now been split into the following packages.\n\nadvmame-0.94\nadvmame-1.4\nadvmame\n\nIf you have chosen just to update the RetroArena-Setup script, you will need to update all the advmame packages for them to work correctly.\n\nNote that advmame-0.94.0.rc will be renamed to advmame-0.94.rc and the config for the main advmame will be advmame.rc.\n\nThe advmame package will be the latest version of the software."
    fi
}

function depends_advmame() {
    local depends=(libsdl1.2-dev autoconf automake)
    isPlatform "mali" && depends+=(libsdl2-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_advmame() {
    gitPullOrClone "$md_build" https://github.com/amadvance/advancemame v3.9
}

function build_advmame() {
    ./autogen.sh
    ./configure CFLAGS="$CFLAGS -fno-stack-protector" --enable-sdl --disable-sdl2 --prefix="$md_inst"
    make clean
    make
    md_ret_require="$md_build/advmame"
}

function install_advmame() {
    make install
}

function install_bin_advmame() {
    downloadAndExtract "$__gitbins_url/advmame.tar.gz" "$md_inst" 1
}

function configure_advmame() {
    mkRomDir "arcade"
    mkRomDir "arcade/advmame"
    mkRomDir "mame-advmame"
    mkRomDir "arcadia"
    mkRomDir "astrocade"
    mkRomDir "bbcmicro"
    mkRomDir "channelf"
    mkRomDir "electron"
    mkRomDir "supervision"

    moveConfigDir "$home/.advance" "$md_conf_root/mame-advmame"

    # move any old named configs (with 3.2 taking priority)
    local ver
    for ver in 3.1 3.2; do
        if [[ -f "$md_conf_root/mame-advmame/advmame-$ver.rc" ]]; then
            mv "$md_conf_root/mame-advmame/advmame-$ver.rc" "$md_conf_root/mame-advmame/advmame.rc"
        fi

        # remove any old emulator.cfg entries
        delEmulator advmame-$ver mame-advmame
        delEmulator advmame-$ver arcade
    done

    if [[ "$md_mode" == "install" ]]; then
        local mame_sub_dir
        for mame_sub_dir in artwork diff hi inp memcard nvram sample snap sta; do
            mkRomDir "mame-advmame/$mame_sub_dir"
            ln -sf "$romdir/mame-advmame/$mame_sub_dir" "$romdir/arcade/advmame"
            # fix for older broken symlink generation
            rm -f "$romdir/mame-advmame/$mame_sub_dir/$mame_sub_dir"
        done
    fi

    if [[ "$md_mode" == "install" && ! -f "$md_conf_root/mame-advmame/$md_id.rc" ]]; then

        su "$user" -c "$md_inst/bin/advmame --default"

        iniConfig " " "" "$md_conf_root/mame-advmame/$md_id.rc"

        iniSet "misc_quiet" "yes"
        iniSet "dir_rom" "$romdir/mame-advmame:$romdir/arcade"
        iniSet "dir_artwork" "$romdir/mame-advmame/artwork"
        iniSet "dir_sample" "$romdir/mame-advmame/samples"
        iniSet "dir_diff" "$romdir/mame-advmame/diff"
        iniSet "dir_hi" "$romdir/mame-advmame/hi"
        iniSet "dir_image" "$romdir/mame-advmame"
        iniSet "dir_inp" "$romdir/mame-advmame/inp"
        iniSet "dir_memcard" "$romdir/mame-advmame/memcard"
        iniSet "dir_nvram" "$romdir/mame-advmame/nvram"
        iniSet "dir_snap" "$romdir/mame-advmame/snap"
        iniSet "dir_sta" "$romdir/mame-advmame/nvram"

        if isPlatform "mali"; then
            iniSet "device_video" "sdl"
            iniSet "device_video_cursor" "off"
            iniSet "device_keyboard" "sdl"
            iniSet "device_sound" "alsa"
            iniSet "display_vsync" "no"
            iniSet "sound_normalize" "no"
            iniSet "display_resizeeffect" "none"
            iniSet "display_resize" "fractional"
            iniSet "display_magnify" "1"
            iniSet "device_video_output" "fullscreen"
            iniset "display_mode sdl_1920x1080"
            iniSet "display_aspectx" 16
            iniSet "display_aspecty" 9
        fi

        if isPlatform "armv6"; then
            iniSet "sound_samplerate" "22050"
            iniSet "sound_latency" "0.2"
        else
            iniSet "sound_samplerate" "44100"
        fi
    fi

    addEmulator 1 "$md_id" "arcade" "$md_inst/bin/advmame %BASENAME%"
    addEmulator 1 "$md_id" "mame-advmame" "$md_inst/bin/advmame %BASENAME%"
    addEmulator 1 "$md_id" "arcadia" "$md_inst/bin/advmess -cfg $md_conf_root/arcadia/advmess.rc -cart %ROM%"
    addEmulator 1 "$md_id" "astrocade" "$md_inst/bin/advmess -cfg $md_conf_root/astrocade/advmess.rc -cart %ROM%"
    addEmulator 1 "$md_id" "bbcmicro" "$md_inst/bin/advmess -cfg $md_conf_root/bbcmicro/advmess.rc -floppy %ROM%"
    addEmulator 1 "$md_id" "channelf" "$md_inst/bin/advmess -cfg $md_conf_root/channelf/advmess.rc -cart %ROM%"
    addEmulator 1 "$md_id" "electron" "$md_inst/bin/advmess -cfg $md_conf_root/electron/advmess.rc -cass %ROM%"
    addEmulator 1 "$md_id" "supervision" "$md_inst/bin/advmess -cfg $md_conf_root/supervision/advmess.rc -cart %ROM%"
    
    addSystem "arcade"
    addSystem "mame-advmame"
    addSystem "arcadia"
    addSystem "astrocade"
    addSystem "bbcmicro"
    addSystem "channelf"
    addSystem "electron"
    addSystem "supervision"
    cp "$scriptdir/configs/mame-advmame/advmess.rc" "$md_conf_root/arcadia/"
    cp "$scriptdir/configs/mame-advmame/advmess.rc" "$md_conf_root/astrocade/"
    cp "$scriptdir/configs/mame-advmame/advmess.rc" "$md_conf_root/bbcmicro/"
    cp "$scriptdir/configs/mame-advmame/advmess.rc" "$md_conf_root/channelf/"
    cp "$scriptdir/configs/mame-advmame/advmess.rc" "$md_conf_root/electron/"
    cp "$scriptdir/configs/mame-advmame/advmess.rc" "$md_conf_root/supervision/"
}
