#!/usr/bin/env nu

# ╓──────────────────────────────────────────────────────────────────────╖
# ║                                         Gitignore.io API Integration ║
# ╙──────────────────────────────────────────────────────────────────────╜

# this module contains a rudimentary integration with gitignore.io for the
# purposes of making gitignore files as needed.

const API_ENDPOINT = 'https://www.toptal.com/developers/gitignore/api/'

module completes {
    export def gi-request [] {
        ['get' 'post' 'put' 'delete' 'head' 'patch']
    }
}

use completes

# fetches a gitignore example file for the provided format
#
# self-explanatory, simply provide a format as a positional parameter or
# alternatively use pipeline input

export def main [
    format?: string
    --request (-r): string@'completes gi-request'
    --list (-l)
]: [
    record -> any list<record> -> any nothing -> any
] {
    let request = $request | default 'get'
    let pipein = $in
    let fetchurl = (
        if $list {
            ([$API_ENDPOINT 'list'] | str join '')
        } else {
            $API_ENDPOINT
        }
    )
    let meta = $fetchurl | url parse

    let fetcher = $request
    | match $in {
        'get' => ({|u| http get $u })
        'post' => ({|u| http post $u })
        'put' => ({|u| http put $u })
        'delete' => ({|u| http delete $u })
        'head' => ({|u| http head $u })
        'patch' => ({|u| http patch $u })
    }

    mut query_params = (
        if ($format != null) {
            {format: $format}
        }
    )

    $query_params = $query_params | default {}

    $query_params = (
        if ($pipein | is-not-empty) or ($pipein != null) {
            ($query_params | merge $pipein)
        } else {
            ($query_params | into record)
        }
    )

    mut fixmeta = (
        $meta
        | upsert params (
            (
                $query_params
                | default ({} | into record)
                | transpose --ignore-titles key, value
            )
        )
    )

    $fixmeta = (
        $fixmeta
        | upsert query (
            $query_params
            | default ({} | into record)
            | url build-query
        )
    )

    $fixmeta | inspect

    let newreq = $fixmeta | url join

    $newreq | inspect

    do $fetcher $newreq
}
