export alias zah = zoxide add .

export alias zap = zoxide add ..

export def za [] {
    glob */** --no-file | ^fzf --multi --preview 'zoxide add {1}'
}

export alias ze = zoxide edit

export alias zrh = zoxide remove .

export alias zrp = zoxide remove ..

export def zr [] {
    glob */** --no-file | ^fzf --multi --preivew 'zoxide remove {1}'
}
