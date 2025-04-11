module completes {
    export def doas [] {
        (^users)
    }
}

use completes

export extern doas [
    command?: any # shell expression to be executed as another user
    ...cargs: any # arguments passed to `command`
    -C: path # parse and check the configuration file, then exit; if `command` is specified, `doas` will also perform command matching. In the latter case either ‘permit’, ‘permit nopass’ or ‘deny’ will be printed on standard output, depending on command matching results. No command is executed.
    -u: string@'completes doas' # execute the command under this user; defaults to `root`
    -s: path # execute via shell from `SHELL` or `/etc/passwd`
    -n # run in non-interactive mode; fails if the rule does not have `nopass` option set
    -L # clear any persisted authentications from previous `doas` invocations, then immediately exit. No command is executed
]

export def --wrapped edit [
    ...args: string
] {
    with-env {NVIM_APPNAME: $env.NIGHTSHELL_ROOT_EDITOR} { rsx nvim ...$args }
}

# thin wrapper around `doas` to allow for privilege escalation with an editor flag for convenience and compatibility with `sudo`
export def --wrapped main [
    --edit (-e) # run with editor mode
    --editor: string # editor to use, when not given uses values from the environment in the following order: `DOAS_EDITOR`,  `SUDO_EDITOR`, `EDITOR`, or `VISUAL`
    ...args: string
] {
    mut clos = {|cod| doas ...$cod }
    if $edit {
        let editor = $env.DOAS_EDITOR
        | $env.SUDO_EDITOR
        | $env.EDITOR
        | $env.VISUAL
        | null
        $clos = {|...args| doas $editor ...$args }
    }

    do $clos $args
}
