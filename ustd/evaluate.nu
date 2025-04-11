#!/usr/bin/env nu
# vim: set ft=nu:

export def eval [code: string] {
    ^$nu.current-exe --no-config-file -c $"($code) | to nuon" | from nuon
}
