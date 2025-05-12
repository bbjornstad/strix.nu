#!/usr/bin/env nu
# vim: set ft=nu:

export def --wrapped main [
    ...args: string
] {
    ^pkill --echo ...$args
}
