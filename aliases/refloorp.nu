#!/usr/bin/env nu
# vim: set ft=nu:

use ustd/pk.nu *

# kills all instances of a floorp browser session of a particular user and then
# spawns a new one; this is useful because the floorp browser likes to randomly
# crash out under no particularly strenuous circumstances
export def --wrapped main [
    --browser-args (-b): list<record> # any additional arguments that are passed to the browser during cli launch
    ...args: string # any additional additional arguments that are passed to the underlying pkill call
]: nothing -> number {
    pk ...$args floorp
    let browser_args = (
        ($browser_args | default [])
        | each {|x|
            $x | items {|k, v| $"($k)=($v)" }
        }
    )

    with-env {MOZ_ENABLE_WAYLAND: 1} {
        let closer = {|| ^floorp --class='floorp %u' ...$browser_args }

        job spawn $closer
    }
}
