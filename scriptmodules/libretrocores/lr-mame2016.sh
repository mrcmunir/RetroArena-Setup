#!/usr/bin/env bash

# This file is part of The RetroArena (TheRA)
#
# The RetroArena (TheRA) is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/Retro-Arena/RetroArena-Setup/master/LICENSE.md
#

rp_module_id="lr-mame2016"
rp_module_desc="MAME emulator - MAME 0.174 port for libretro"
rp_module_help="ROM Extension: .zip\n\nCopy your MAME roms to either $romdir/mame-libretro or\n$romdir/arcade"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame2016-libretro/master/LICENSE.md"
rp_module_section="lr"
rp_module_flags=""

function sources_lr-mame2016() {
    gitPullOrClone "$md_build" https://github.com/libretro/mame2016-libretro.git
}

function build_lr-mame2016() {
    rpSwap on 2000
    local params=($(_get_params_lr-mame) SUBTARGET=arcade)
    make -f Makefile.libretro clean
    make -f Makefile.libretro "${params[@]}" -j1
    rpSwap off
    md_ret_require="$md_build/mamearcade2016_libretro.so"
}

function install_lr-mame2016() {
    md_ret_files=(
        'mamearcade2016_libretro.so'
    )
}

function install_bin_lr-mame2016() {
    downloadAndExtract "$__gitbins_url/lr-mame2016.tar.gz" "$md_inst" 1
}

function configure_lr-mame2016() {
    local system
    for system in arcade mame-libretro daphne; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mamearcade2016_libretro.so"
        addSystem "$system"
    done
    
    setRetroArchCoreOption "${dir_name}mame2016_throttle" "enabled"
}
