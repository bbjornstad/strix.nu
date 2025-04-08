# ─[ Path Configuration ]─────────────────────────────────────────────────

#   this section updates the configuration to know where to look for external
#   libraries, binaries, or scripts. In other words, directories to search for
#   scripts when calling source or use By default,
#   <nushell-config-dir>/scripts is added
let completions = ($nu.default-config-dir | path join "completions")
let core = ($nu.default-config-dir | path join "core")
let utils = ($nu.default-config-dir | path join "utils")
let share = ($nu.default-config-dir | path join "share")
let std = ($nu.default-config-dir | path join "libstd")
let aliases = ($nu.default-config-dir | path join "aliases")
$env.NU_LIB_DIRS = [
    $nu.default-config-dir
]

# add in the specific directory that corresponds to nupm so that we can use it
$env.NU_LIB_DIRS = $env.NU_LIB_DIRS
| append (
    [$env.NUPM_HOME "modules"]
    | path join
)

# Directories to search for plugin binaries when calling register
# By default, <nushell-config-dir>/plugins is added
let plug_base = ($nu.default-config-dir | path join "plugins")
$env.NU_PLUGIN_DIRS = $env.NU_PLUGIN_DIRS
| append [$plug_base]

$env.NUPM_HOME = ($nu.default-config-dir | path join 'nupm st')

$env.NUPM_REGISTRIES = {
    core: (
        [$env.NUPM_HOME 'registry' 'registry.nuon']
        | path join
    )
}

# add in cargo binary directory to path to allow for cargo installed pkgs to
# show up in nushell correctly
let cargo_bin = [$env.HOME ".cargo" "bin"]
| path join
let coursier_bin = [$env.HOME ".local" "share" "coursier" "bin"]
| path join
let gem_bin = [$env.HOME ".local" "share" "gem" "ruby" "3.0.0" "bin"]
| path join

let script_bin = [$env.NUPM_HOME "scripts"]
| path join

# add the lms binary directory to path so that the lms cli tool can be used
# correctly.

let extra_paths = [$cargo_bin $coursier_bin $gem_bin $script_bin]

$env.PATH = ($env.PATH | split row (char esep) | prepend $extra_paths)
