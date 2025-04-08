# ─[ `dotcandyd` ]────────────────────────────────────────────────────────

# the dotcandyd systems home folder here. this is used in the nushell by default
# and for those who use this program, I would recommend it strongly.
# configuration definition of the candy cli
$env.DOTCANDYD_USER_HOME = ($env.HOME | path join ".candy.d")
