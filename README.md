# strix.nu

This is a configuration for [nushell](https://nushell.sh), a pipeline-oriented
shell with top-notch data manipulation, support for data structures for shell
IO, and excellent scripting capabilities.

I use `nushell` as my default login shell, although this style is a modicum of
additional work to setup and completely disregards POSIX compliancy. If these
features are important to your setup working with command-line shells, nushell
can still be used ad-hoc or without being a login shell.

## Why `Nushell`?

We are living in the golden-era of alternative shells (among other things).
Besides the standard `sh`, `bash`, `zsh`, and `fish` options that most UNIX
users are exposed to, I can think of several additional shells off the top of my
head: `dash`, `xonsh`, `elvish`, `oil`, `ion`, and the [list goes
on](https://wiki.archlinux.org/title/Command-line_shell)...

`nushell`, situated against the rest of the pack, offers a few positives.

### Pipelines

`nushell` has excellent support for pipelines. The syntax is clean and easy to
use, as in the following example, which sets up `direnv` at the appropriate time
during shell init:

```nu
direnv export json | from json | default {} | load-env
```

or equivalently given:

```nu
(
    direnv export json
    | from json
    | default {}
    | load-env
)
```

It is also straightforward to debug or otherwise inspect pipelines as there are
a number of commands for such introspections that come out of the box:

```nu
(
    direnv export json
    | from json
    | default {}
    | inspect
    | load-env
)
```

Other nice introspection commands include: `describe`, `explain`, and
`metadata`; a complete list is available via [nushell's command
reference](https://nushell.sh/commands/categories/debug.html)

### Data Typing

`nushell` is also pleasant to work with as it generally supports data structures
in various forms as command and pipeline input/output values, and does not rely
on any sort of conversion of data types unless you are sending or receiving from
an external (i.e. non-nushell) program (in this case conversion is required
simply because the external doesn't know what to do with non-string values)

The support for stronger typing means that custom commands have a broader
ability to self-document and provide nice language features that come with
such typing. As such, I find it more efficient and cleaner to script in nushell
than other shells.

Examine, for instance, the following custom command definition for a
`coalesce` implementation:

```nu
def coalesce [
    ...args: any
    --predicate: closure
]: [nothing -> any list<any> -> any] {
    # store pipeline input
    let pipein = $in

    # put pipeline input before passed positional args, if any
    let fullargs = ($pipein | default [])
    | append ($args | default [])

    # filter the given arguments by the optional predicate closure
    let testargs = (
        if $predicate != null {
            $fullargs | filter $predicate
        } else {
            $fullargs
        }
    )

    # exclude null elements
    let found = $testargs | filter {|it| $it != null }

    # get first non-null
    $found | first
}
```

With this definition, when this command is invoked, it will check the data types
for positional arguments (e.g. `...args`), flags (e.g. `--predicate`), and
pipeline inputs (e.g. data sent into the `coalesce` command via `|`), and will
fail with a descriptive error in cases where the expected types are not
received.

### A Solid Community

The `nushell` community is generally quite helpful, friendly, and larger than
some of the other shell options. There have been several versions of `nushell`
released throughout the years, and there is lots of active development
happening; this seems coordinated mostly through `nushell`'s discord channel.

## `strix.nu`

This configuration is relatively straightforward, but offers the ability to
extend with customizations that are modular and composable. It does so by using
`nushell`'s autoload directories. This provides a convenient way to include both
vendor-provided implementations for integrating with `nushell` (e.g.
`starship`, `zoxide`) as well as user provided customizations which are
ultimately evaluated via _extension binning_ that is present in the
user-autoload directory (e.g. the `autoload` subdirectory of the nushell
configuration directory). The rough directory structure is as follows:

- `aliases`: represents simple command aliases
- `external`: represents simple wrappers around external commands that are used
  frequently
- `hooks`: (__not sourced via autoload__) represents stub implementations for
  certain behaviors that occur if aware of `nushell`'s hooks
- `overlays`: contains moudles that are designed to be used as overlays, which
  is to say in a more ad-hoc fashion.
- `ustd`: the _user std_ lib; contains core ubiquitous command implementations
  of the user's design. Not to be confused with the `nushell` builtin `std` module
- `utils`: a hodgepodge bin of commands that are maybe used in some places but
  don't qualify for `ustd`; also include WIP candidates for `ustd`

### Using `strix.nu`

If you want to use this configuration or otherwise contribute here, note that I
am experimenting with the use of `jj` as a git alternative, so far to promising
results. I don't know exactly if you will also need `jj` to work with this repo,
but I'm guessing not.
