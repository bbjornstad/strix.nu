#!/usr/bin/env nu
# vim: set ft=nu:

def --wrapped wrap-systemctl [
    cmd: string?
    ...args: string
]: string -> closure {
    let piped = $in

    {|inp| ^systemctl $args $cmd $in $inp }
}

def --wrapped wrap-journalctl [
    cmd: string
    ...args: string
] {
    let piped = $in

    {|inp| ^journalctl $args $cmd $in $inp }
}

export def --wrapped main [
    ...args: string
] {
    syst stat ...$args
}

export def --wrapped sysj [
    ...args: string
] {
    let clsr = wrap-journalctl 'journalctl' ...$args

    do $clsr
}

export def --wrapped 'syst stat' [
    ...args: string
] {
    let clsr = wrap-systemctl 'status' ...$args

    do $clsr
}
