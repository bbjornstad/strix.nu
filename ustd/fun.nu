#!/usr/bin/env nu
# vim: set ft=nu:

# ╒══════════════════════════════════════════════════════════════════════╕
#   `fun`
# └──────────────────────────────────────────────────────────────────────┘
# this module contains some fun/ctional tools for working with other nushell
# commands. A bit of a meta-module, if you will.

export def and-then [action: closure] {
    if ($in | is-not-empty) {
        $in | do $action
    }
}

export def err [msg: string, label: string, meta: record] {
    error make {
        msg: $msg
        label: {text: $label span: $meta.span}
    }
}

export def only []: [table -> record list -> any] {
    let pipe = {in: $in meta: (metadata $in)}
    match ($pipe.in | length) {
        ..0 => (err "expected non-empty list" "empty" $pipe.meta)
        1 => ($pipe.in | get 0)
        2.. => (err "expected list of length 1" "has more than one element" $pipe.meta)
    }
}

export def "map empty" [closure: closure]: any -> any {
    if ($in | is-empty) {
        do $closure
    } else { $in }
}

# If null do nothing, if not null, apply closure
def "map null" [c: closure] {
    let input = $in
    match $input {
        null => null
        _ => { do $c $input }
    }
}
