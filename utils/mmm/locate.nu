export def dpath [
    action: closure
    ...items: any
] {
        let pipe = $in | default null
        let items = $items | prepend $pipe

        $pipe | do $action ...$items
}

module model {
    export def root []: nothing -> path {
        try {
            $env | get "OWL_MODEL_LLM_ROOT"
        } catch {
            [$env.HOME "llm"] | path join
        }
    }

    export def text []: nothing -> path {
        try {
            $env | get "OWL_MODEL_LLM_TEXT"
        } catch {
            [(root) "text"] | path join
        }
    }

    export def image []: nothing -> path {
        try {
            $env | get "OWL_MODEL_LLM_IMAGE"
        } catch {
            [(root) "image"] | path join
        }
    }

    export def find [
        ...items: path
        --locate-from (-f): string='root'
    ]: [path -> list<path>, nothing -> list<path>] {
        let pipe = $in
        let root = (match $locate_from {
            "root" => { root }
            "text" => { text }
            "image" => { image }
            _ => {
                root
            }
        })

        $items
        | prepend ($pipe | default [])
        | each {|it| [$root $it] | path join }
    }
}

module assets {
    export def root []: nothing -> path {
        try {
            $env | get "OWL_ASSET_LLM_ROOT"
            [$env.HOME "lmm"]
        }
    }

    export def find [
        ...items: path
        --locate-from (-f): string='root'
    ] {

    }
}

export use model
export use assets
