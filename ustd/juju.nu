def to-group-name [] {
    str replace -ra "[()'\":,;|]" "" | str replace -ra '[\.\-\s]' "_"
}

# get `jj log` as a nushell table
@example "juju log" { juju log }
export def log [
    --revset (-r): string
    ...columns: string
] {
    let columns = $columns | each {
        match $in {
            "description" => "description.lines().join(',')"
            _ => $in
        }
    }
    let parser = $columns
    | each { $"{($in | to-group-name)}" }
    | str join (char rs)

    (
        jj log ...(if $revset != null { [-r $revset] } else { [] })
        --no-graph
        -T $"($columns | str join $"++'(char rs)'++") ++ '\n'"
    ) | parse $parser
}
