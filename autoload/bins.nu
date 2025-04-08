# +---------------------------------------------------------+ extension bins ++
# this sets up some custom directories that are used to hold things like
# downloaded scripts, custom completions, externs, etc. Each bin that we wish to
# set up must have its own line in the following section, requiring explicit
# user configuration as opposed to some sort of automatic methods.

export use ustd *
export use core *
export use completions *
export use utils *
export use aliases *

# +-----------------------------------------------------------+ overlay bins ++

export use overlays *
