# ─[ Environment Conversion ]─────────────────────────────────────────────
# the following section defines how nushell should "translate" environment
# variables into a nushell-compatible format. Because data types are much more
# rigid in nushell than other shells, conversions can help reduce some
# boilerplate/room for human error.
#
# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands
#   (to_string)
# Note: The conversions happen *after* config.nu is loaded

$env.ENV_CONVERSIONS = (
    $env.ENV_CONVERSIONS | upsert PATH {
        from_string: {|s|
            (
                $s
                | split row (char esep)
                | path expand --no-symlink
            )
        }
        to_string: {|v|
            (
                $v
                | path expand --no-symlink
                | str join (char esep)
            )
        }
    } | upsert Path {
        from_string: {|s|
            (
                $s
                | split row (char esep)
                | path expand --no-symlink
            )
        }
        to_string: {|v|
            (
                $v
                | path expand --no-symlink
                | str join (char esep)
            )
        }
    } | upsert LS_COLORS {
        from_string: {|s|
            (
                $s
                | split row (char esep)
            )
        }
        to_string: {|s|
            (
                $s
                | str join (char esep)
            )
        }
    } | upsert ZELLIJ_AUTO_ATTACH {
        from_string: {|s| $s | into bool }
        to_string: {|s| $s | into string }
    }
)
