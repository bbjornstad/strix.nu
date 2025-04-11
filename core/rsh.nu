#!/usr/bin/env nu
# vim: set ft=nu:

module completes {
    export def layouts [] {
        let p = [$env.XDG_CONFIG_HOME 'zellij' 'custom' 'layouts']
        | path join
        let files = glob ([$p '*'] | path join)
        | path relative-to $p
        | str replace '.kdl' ''
    }
}

use completes

export extern zellij [
    --config (-c): path # Change where zellij looks for the configuration file [env: ZELLIJ_CONFIG_FILE=]
    --config-dir: directory # Change where zellij looks for the configuration directory [env: ZELLIJ_CONFIG_DIR=]
    --debug (-d) # Specify emitting additional debug information
    --data-dir: directory # Change where zellij looks for plugins
    --help (-h) # Print help information
    --layout (-l): string@'completes layouts' # Name of a predefined layout inside the layout directory or the path to a layout file
    --max-panes: int # Maximum panes on screen, caution: opening more panes will close old ones
    --session (-s): string # Specify name of a new session
    --version (-V) # Print version information
]

export def --wrapped main [
    ...args
] {
    ^zellij ...$args
}

export def --wrapped new [
    name?: string = r#'rsh-{{DATE}}-{{RANDOM_IDENTIFIER}}'#
    ...args: string
]: [string -> nothing nothing -> nothing] {
    let name = $in | default $name
    let dt = ^date -I
    let rndid = random chars --length 5
    let fmtname = $name
    | str replace '{{DATE}}' $dt
    | str replace '{{RANDOM_IDENTIFIER}}' $rndid

    $fmtname | ^zellij attach --create ...$args $in
}

export def id []: nothing -> list<string> {
    ^zellij ls
}

export def --wrapped list [
    ...args: string
] {
    ^zellij list-sessions ...$args
}

export def --wrapped del [
    session?: string
    ...args: string
    --kill
]: [string -> nothing nothing -> nothing] {
    let pipe = $in | default $session
    if $kill {
        ^zellij kill-session ...$args $pipe
    }
    ^zellij delete-session ...$args $pipe
}

export def --wrapped clean [
    ...args: string
    --kill
]: nothing -> nothing {
    if $kill {
        ^zellij kill-all-sessions ...$args
    }
    ^zellij delete-all-sessions ...$args
}

export def --wrapped plug [
    ...args: string
]: nothing -> nothing {
    ^zellij plugin ...$args
}

export def --wrapped run [
    ...args: string
]: nothing -> nothing {
    ^zellij run ...$args
}
