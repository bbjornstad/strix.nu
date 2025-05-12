#!/usr/bin/env nu
# vim: set ft=nu:

# +-------------------------------------------------------------+ LS Aliases ++

# Simply defines a few aliases that I use to query directories in a more
# specific fashion.
export alias lsd = ls --long
export alias lsa = ls --long
export alias ald = ls --long --all
export alias aldt = ls --long --all
export alias lsl = ls --long

# +------------------------------------------------------------+ exa aliases ++

export alias esd = exa --long
export alias esa = exa --long --all
export alias eld = exa --long --all --tree
export alias eldt = exa --long --all --tree --recurse
