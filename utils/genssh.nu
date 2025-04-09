#!/usr/bin/env nu

module completes {
    export def complete-genkey-ssh [] {
    }
    export def genkey-complete-type [] {
        ["ed25519-sk" "ed25519" "rsa"]
    }
    export def genkey-complete-type-yubikey [] {
        ["ed25519-sk" "ecdsa-sk"]
    }
    export def genkey-complete-host [] { }

    export def genkey-complete-username [] {
        ^users | split row " "
    }
}

use completes

export def --env "yubikey" [
    --type (-t): string@'completes genkey-complete-type-yubikey'
    --host (-H): string@'completes genkey-complete-host'
    --username (-u): string@'completes genkey-complete-username'
    --comment (-C): string
    --filename_override (-f): path
    --pin-verify (-p)
    --touch-verify (-T)
    --use-resident (-r)
    --yubikey-env-mapping (-Y): string = ''
] {
    let yubikey_mapper = {
        "22522649": "ybkyA-primary"
        "19330188": "ybkyC-MASTER"
    }
    let yubikeys = (
        ykman list
        | lines -s
        | parse '{keydesc} Serial: {serial}'
        | inspect
        | select serial
        | insert YubikeyName yubikey_mapper.(get serial)
        | inspect
    )

    let appstr = $"-O application=ssh:id_($username).($type).($host)-($env.HOSTNAME)"
    let appusr = $"-O user=($username)"
    let gencmd = $"-t ($type) -O resident ($appusr) ($appstr) -C ($comment)"

    ^ssh-keygen $gencmd
}
