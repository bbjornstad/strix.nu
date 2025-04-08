def cmd-signatures [cmd: string] {
    scope commands
    | where name == $cmd
    | get 0.signatures
    | values
    | first
    | where parameter_type not-in [input output]
    | enumerate
    | sort-by { $in.item.parameter_type == rest } index
    | get item
}

def append-if-not-empty [param: any, item: any] {
    if ($param | is-not-empty) { append $item } else { }
}

def "parameter encode dispatch" [] {
    let IN = $in
    match $IN.parameter_type {
        "positional" => { $IN | parameter encode positional }
        "switch" => { $IN | parameter encode switch }
        "named" => { $IN | parameter encode named }
        "rest" => { $IN | parameter encode rest }
    }
}

def "parameter encode positional" [] {
    let IN = $in
    [$'($IN.parameter_name)(if $IN.is_optional { "?" })']
    | append-if-not-empty $IN.syntax_shape (
        if ($IN.custom_completion | is-not-empty) {
            $": ($IN.syntax_shape)@\"($IN.custom_completion)\""
        } else {
            $": ($IN.syntax_shape)"
        }
    )
    | append-if-not-empty $IN.parameter_default $" = ($IN.parameter_default | to nuon)"
    | append-if-not-empty $IN.description $" # ($IN.description)"
    | str join
}

def "parameter encode switch" [] {
    let IN = $in
    [$'--($IN.parameter_name)']
    | append-if-not-empty $IN.short_flag $"\(-($IN.short_flag)\)"
    | append-if-not-empty $IN.description $" # ($IN.description)"
    | str join
}

def "parameter encode named" [] {
    let IN = $in
    [$'--($IN.parameter_name)']
    | append-if-not-empty $IN.short_flag $"\(-($IN.short_flag)\)"
    | append-if-not-empty $IN.syntax_shape (
        if ($IN.custom_completion | is-not-empty) {
            $": ($IN.syntax_shape)@\"($IN.custom_completion)\""
        } else {
            $": ($IN.syntax_shape)"
        }
    )
    | append-if-not-empty $IN.parameter_default $" = ($IN.parameter_default | to nuon)"
    | append-if-not-empty $IN.description $" # ($IN.description)"
    | str join
}

def "parameter encode rest" [] {
    let IN = $in
    [$"...($IN.parameter_name)"]
    | append-if-not-empty $IN.syntax_shape (
        if ($IN.custom_completion | is-not-empty) {
            $": ($IN.syntax_shape)@\"($IN.custom_completion)\""
        } else {
            $": ($IN.syntax_shape)"
        }
    )
    | append-if-not-empty $IN.description $" # ($IN.description)"
    | str join " "
}

export def main [name: string] {
    cmd-signatures $name
    | each { parameter encode dispatch }
    | each { "    " + $in }
    | str join (char nl)
    | [
        $"export def \"($name)\" ["
        $in
        "] {  }"
    ]
    | to text
    | metadata set --content-type "application/x-nuscript"
}
