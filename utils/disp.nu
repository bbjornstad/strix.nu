#!/usr/bin/env nu
# vim: set ft=nu:

# ╓──────────────────────────────────────────────────────────────────────╖
# ║                                                               `disp` ║
# ╙──────────────────────────────────────────────────────────────────────╜
# utilities to control attached monitors via ddcutil
# --------------------------------------------------
# This module is designed to use the `ddcutil` command line tool in order to set
# or configure various parameters available through any monitors


# ┌──────────────────────────────────────────────────────────────────────┐
#                                                 parsers support module
# └──────────────────────────────────────────────────────────────────────┘
module parsers {

    # +------------------------------------------------------+ parsers detect ++

    def detect [] {
        let display = '^Display\s+(?<display>)'
        let i2cbus = '^\s+I2CBus:\s+(?<i2cbus>)'
        let drmconnect = '^\s+DRM connector:\s+(?<drm>)'
        let edid = '\s+(?<property>.+):\s+(?<value>.+)'
        let vcp = '\s+VCP version:\s+(?<vcpver>)'

        {|input|
            ($input
            | parse --regex (
                    [$display $i2cbus $drmconnect $edid $vcp]
                    | str join
                )
            )
        }
    }


    # --------------------------------------------------------+ parsers probe ++

    def probe [] {
        let feature = '^VCP code 0x(?<vcpfeat>\w+)\s+\((?<description>).+\):\s+(?<value>.+)'

        {|input|
            ($input
            | parse --regex $feature)
        }
    }


    # +--------------------------------------------------------+ parsers from ++

    export def from [
        subcommand: string
    ]: nothing -> closure {
        match $subcommand {
        'probe' => (probe)
        'detect' => (detect)
    }
    }


    # +----------------------------------------------------+ parsers as-table ++

    export def as-table [
        --drop (-d): list<string>
        --insert (-i): table
        --headers (-r): table
    ] {
        let pipein = $in
    }
}


# ┌──────────────────────────────────────────────────────────────────────┐
#                                                            main module
# └──────────────────────────────────────────────────────────────────────┘

# entry point of `disp` cli tool for adjusting monitor specifications and
# parameters for attached monitors using `ddcutil`
#
# This doesn't do anything useful by itself, but it probably will default to a
# simple status output.
export def main [] {
    info
}

# +---------------------------------------------------------------+ disp ddc ++

# @example 'using underlying ddcutil connection to list traceable functions' {
#     disp ddc 'traceable-functions'
# } --result (^ddcutil traceable-functions)

# backend connection to the underyling `ddcutil` implementation, used to create
# wrapping commands for the most commonly used functionality desired via `disp`
export def --wrapped ddc [
    subcommand?: string='detect'
    ...args: string
]: any -> closure {
    {|...pos| ^ddcutil ...$args $subcommand ...$pos }
}

# +--------------------------------------------------------------+ disp info ++

# queries hardware to get info about any attached monitors
export def --wrapped info [
    ...args: string;
]: any -> table {
    let closure = ddc 'detect' ...$args
    let pipe = $in
    $pipe | do $closure
}

# +--------------------------------------------------------------+ disp list ++

# produces a list of attached monitors
export def --wrapped list [
    ...args: string
]: any -> table {
    let closure = ddc 'detect' --terse ...$args
    let pipe = $in

    $pipe
    | do $closure
    | select 'display' 'i2cbus' 'drm'
}

# +--------------------------------------------------------------+ disp find ++

# finds a particular parameter among the collection of availble properties
# exposed with `ddcutil`
export def --wrapped find [
    prop?: string
    ...args: string
] {}

# +-------------------------------------------------------------+ disp ifind ++

# interactively finds a particular parameter among the collection of available
# properties exposed with `ddcuit`
export def --wrapped ifind [
    ...args: string
] {}

# +-------------------------------------------------------------+ disp props ++

export def --wrapped props [
    ...args: string
] {
    let closure = ddc 'probe' ...$args
    let filter_closure = (parsers from probe)
    let pipe = $in

    $pipe
    | do $closure
}


# +-------------------------------------------------------------+ disp param ++

export def --wrapped param [
    ...args: string
] {

}
