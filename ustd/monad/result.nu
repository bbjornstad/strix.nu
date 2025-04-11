#!/usr/bin/env nu
# vim: set ft=nu:

export def ok [] {
    {
        ok: true
        value: $in
    }
}
export def err [] {
    {
        ok: false
        error: $in
    }
}

export def map [f: closure] {
    if $in.ok {
        (do $f $in.value) | ok
    } else {
        $in
    }
}

export def and_then [f: closure] {
    if $in.ok {
        (do $f $in.value)
    } else {
        $in
    }
}
export def is_err [] {
    $in.ok == false
}
export def is_ok [] {
    $in.ok == true
}
export def unwrap [] {
    if $in.ok {
        $in.value
    } else {
        print $"unwrap error: ($in.error)"
        error make {msg: 'Cannot get value from Err result'}
    }
}
export def add_context [ctx: string] {
    let res = $in
    if ($res | is_ok) {
        $res
    } else {
        [$ctx ": " ($res.error | into string)] | str join | err
    }
}
