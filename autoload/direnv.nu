# +-----------------------------------------------------------------+ direnv ++
# as of a recentish update to nushell, it seems as though the proper hook into
# the direnv package is supposed to be set up this way instead. Note that we
# able to auto-update this when needed.

$env.DIRENV_LOG_FORMAT = ""
$env.config.hooks.env_change.PWD = (
    $env.config.hooks.env_change.PWD
    | append ( source hooks/direnv.nu)
)
