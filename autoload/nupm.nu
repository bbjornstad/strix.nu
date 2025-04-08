## +-------------------------------------------------------------------+ nupm ++
# this sets up nushell's package manager for installing nushell plugins from the
# github repository

# ─[ Nushell Package Manager ]────────────────────────────────────────────
# defines the location that nupm should take
$env.NUPM_HOME = ([$nu.default-config-dir "pkg/"] | path join)

overlay use nupm/nupm --prefix
