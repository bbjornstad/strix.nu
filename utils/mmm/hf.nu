use utils/mmm/locate.nu

def subcommands []: nothing -> list<string> {
    ^huggingface-cli -h
    | parse --regex r#'{(?P<subcommand>.*)}'#
    | get subcommand
    | each {|it| $it | into string }
    | split row --regex ','
}

# an "alias" for the huggingface-cli invocation; we want to use a command
# definition here so that we can match on the subcommand in order to inject
# necessary flags and parameterizations where they are appropriate for the
# user interface of this tooling here.
#
# this makes the usage of this wrapped command similar to the original
# invocation of the `huggingface-cli` tool,
# e.g. `huggingface-cli download <args>` becomes
# `hf download <args>`
export def --wrapped main [
    subcommand?: string@'subcommands' # a subcommand of `huggingface-cli`
    ...args: string # arguments that should be passed to the tool's invocation
    --model-dir (-d): directory # override root location of model files
    --cache-dir (-c): directory # override location of cache where files are staged
]: any -> any {
    let model_dir = $model_dir | default (locate model root)
    let args = $args
    | prepend (
        match $subcommand {
            'download' => {
                [
                    $'--local-dir=($model_dir)'
                    $'--cache-dir=($model_dir)'
                ]
            }
            'scan-cache' => {
                $'--dir=($model_dir)'
            }
            'delete-cache' => {
                $'--dir=($model_dir)'
            }
            _ => { }
        }
    )
    $in | ^huggingface-cli $subcommand ...$args
}

export def --wrapped 'logout' [
    ...args: string
] {
    hf logout ...$args
}

export def --wrapped 'login' [
    ...args: string
] {
    hf login ...$args
}

export def --wrapped 'status' [
    ...args: string
] {
    hf whoami ...$args
}
