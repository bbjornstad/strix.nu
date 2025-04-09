module shizuku-completes {
}

use shizuku-completes

export def main [
    --script-path (-s): path
]: nothing -> nothing {
    let script_path = $script_path | default '/storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh'
    let cmdargs = ['shell' 'sh' $script_path]

    ^adb ...$cmdargs
}
