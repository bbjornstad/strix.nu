export def main [
    ...args: any
    --predicate: closure
]: [nothing -> any list<any> -> any] {
    let pipein = $in
    let fullargs = ($args | default [])
    | prepend ($pipein | default [])

    let testargs = (
        if $predicate != null {
            $fullargs | filter $predicate
        } else {
            $fullargs
        }
    )

    let found = $testargs | filter {|it| $it != null }

    $found | first
}
