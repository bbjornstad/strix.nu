# +--------------------------------------------------------------+ ls-colors ++
$env.config.hooks.env_change = (
    $env.config.hooks.env_change | upsert LS_COLORS (
        [
            (
                source hooks/vivid.nu
            )
        ]
    )
)

# +-------------------------------------------------------+ engaged overlays ++
$env.config.hooks.pre_prompt = (
    $env.config.hooks.pre_prompt
    | append (
        source hooks/overlays.nu
    )
)
