#!/usr/bin/env nu
# vim: set ft=nu:

export def main [
    executable: string
] {
    let fin_pat = "(\\..+)?";
    for path in $env.PATH {
        let files = try { ls $path } catch { [] } | where type == file | where name =~ $"/($executable)($fin_pat)$"
        for condidate in $files {
            echo $condidate
        }
    }
}
