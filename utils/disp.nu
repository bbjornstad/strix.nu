#!/usr/bin/env nu
# vim: set ft=nu:

# ╓──────────────────────────────────────────────────────────────────────╖
# ║                                                               `disp` ║
# ╙──────────────────────────────────────────────────────────────────────╜
# utilities to control attached monitors via ddcutil
# --------------------------------------------------
# This module is designed to use the `ddcutil` command line tool in order to set
# or configure various property available through any monitors

# ┌──────────────────────────────────────────────────────────────────────┐
#                                                 parsers support module
# └──────────────────────────────────────────────────────────────────────┘
# this module provides helper commands that can be used to piecemeal out the
# data returned by the `ddcutil` command line tool; mostly this is created using
# regex
module parsers {

    # +------------------------------------------------------+ parsers detect ++
    def detect [] {
        let display = '^Display\s+(?<display>)'
        let i2cbus = '^\s+I2CBus:\s+(?<i2cbus>)'
        let drmconnect = '^\s+DRM connector:\s+(?<drm>)'
        let edid = '^\s+(?<property>.+):\s+(?<value>.+)'
        let vcp = '^\s+VCP version:\s+(?<vcpver>)'

        {|input|
            (
                $input
                | parse --regex (
                    [$display $i2cbus $drmconnect $edid $vcp]
                    | str join
                )
            )
        }
    }

    # --------------------------------------------------------+ parsers probe ++
    def probe [] {
        let vcp = '^VCP Code 0x(?<vcpfeat>\w+)\s+'
        let desc = '\((?<description>.+)\)'
        let value = ':\s+(?<value>.+)$'

        let feature = $'($vcp)($desc)($value)'

        {|input|
            (
                $input
                | parse --regex $feature
            )
        }
    }

    def vcpinfo [] {
        let vcp = '^VCP code [\S]+/(?<vcpfeat>\w+)\s+'
        let desc = '\((?<description>.+)\):'
        let value = '\s+(?<value>.+)$'
        let feature = $'($vcp)($desc)($value)'

        {|input|
            (
                $input
                | parse --regex $feature
            )
        }
    }

    def capabilities [] {
        let feature = '^\s+Feature: (?<vcpfeat>\w+)\s+\((?<description>).+\)'
    }

    # +--------------------------------------------------------+ parsers from ++

    export def from [
        subcommand: string
    ]: nothing -> closure {
        match $subcommand {
            'probe' => (probe)
            'detect' => (detect)
            'vcpinfo' => (vcpinfo)
            'capabilities' => (capabilities)
        }
    }
}

# ┌──────────────────────────────────────────────────────────────────────┐
#                                                            main module
# └──────────────────────────────────────────────────────────────────────┘

# entry point of `disp` cli tool for adjusting monitor specifications and
# properties for attached monitors using `ddcutil`
#
# This doesn't do anything useful by itself, but it probably will default to a
# simple status output.
export def main [] {
    info
}

# +---------------------------------------------------------------+ as-table ++
# given a closure that will return the data parsed from the output of
# `ddcutil`, for example, as result from the evaluation of any of the `parsers`
# subcommands, this unwraps the closure and provides the data as a table os
# suitable shape.
def fmt-table [
    --drop (-d): list<string> # columns from parsed data to drop
    --insert (-i): table # a table of additional data onto which the evaluated data will be merged
    --headers (-r): record # a map of column names in the raw table to desired column names in the output table
]: closure -> table {
    let cls = $in

    let evalres = do $cls
}

# +---------------------------------------------------------------+ disp ddc ++
# @example 'using underlying ddcutil connection to list traceable functions' {
#     disp ddc 'traceable-functions'
# } --result (^ddcutil traceable-functions)
#
# backend connection to the underyling `ddcutil` implementation, used to create
# wrapping commands for the most commonly used functionality desired via `disp`
export def --wrapped ddc [
    subcommand?: string = 'detect'
    ...args: string # additional arguments that are passed to `ddcutil`
]: any -> closure {
    let pipe = $in
    {|...pos| $pipe | ^ddcutil ...$args $subcommand ...$pos }
}

# +--------------------------------------------------------------+ disp info ++
# queries hardware to get info about any attached monitors
export def --wrapped info [
    ...args: string # any additional arguments that are passed to `ddcutil detect`
]: any -> table {
    let closure = ddc 'detect' ...$args
    let pipe = $in
    $pipe | do $closure
}

# +--------------------------------------------------------------+ disp list ++
# produces a list of attached monitors
export def --wrapped list [
    ...args: string # any additional arguments that are passed to `ddcutil detect`
]: any -> table {
    let closure = ddc 'detect' --terse ...$args
    let pipe = $in

    $pipe
    | do $closure
    | select 'display' 'i2cbus' 'drm'
}

# +--------------------------------------------------------------+ disp find ++
# finds a particular property among the collection of availble properties
# exposed with `ddcutil`
export def --wrapped find [
    pattern?: string # the target search pattern as a regular expression
    ...args: string # additional arguments that are passed to `ddcutil probe`
] { }

# +-------------------------------------------------------------+ disp ifind ++
# interactively finds a particular property among the collection of available
# properties exposed with `ddcutil`
export def --wrapped ifind [
    ...args: string # additional arguments that are passed to `ddcutil probe`
] { }

# +------------------------------------------------------------+ disp props ++
# lists all properties that are available for the monitors attached
export def --wrapped 'props' [
    ...args: string # additional arguments that are passed to `ddcutil probe`
] {
    let closure = ddc 'probe' ...$args
    let filter_closure = parsers from probe
    let pipe = $in

    $pipe
    | do $closure
}

# +-------------------------------------------------------------+ disp prop ++
# lists all properties that are available for the monitors attached
export alias prop = props

# +---------------------------------------------------------+ disp prop get ++
# gets the value of a particular property for the attached monitors
export def --wrapped 'prop get' [
    ...args: string # additional arguments that are passed to `ddcutil getvcp`
] {
    let closure = ddc 'getvcp' ...$args
    let pipe = $in

    $pipe
    | do $closure
}

# +---------------------------------------------------------+ disp prop set ++
# sets the value of a particular property for the attached and specified monitor
export def --wrapped 'prop set' [
    ...args: string # additional arguments that are passed to `ddcutil setvcp`
] {
    let closure = ddc 'setvcp' ...$args
    let pipe = $in

    $pipe
    | do $closure
}
