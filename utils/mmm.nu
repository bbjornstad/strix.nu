#!/usr/bin/env nu
# vim: set ft=nu:

#SPDX-FileCopyrightText: 2024 Bailey Bjornstad | ursa-major <bailey@bjornstad.dev>
#SPDX-License-Identifier: MIT

#MIT License

# Copyright (c) 2024 Bailey Bjornstad | ursa-major bailey@bjornstad.dev

#Permission is hereby granted, free of charge, to any person obtaining a copy of
#this software and associated documentation files (the "Software"), to deal in
#the Software without restriction, including without limitation the rights to
#use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
#of the Software, and to permit persons to whom the Software is furnished to do
#so, subject to the following conditions:

#The above copyright notice and this permission notice (including the next
#paragraph) shall be included in all copies or substantial portions of the
#Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

#/module/ `mmm` implementation of the multi-model manager cli utility for AI
# modeling tasks
#/author/ Bailey Bjornstad | ursa-major
#/license/ MIT

# ─[ library imports ]────────────────────────────────────────────────────
# these are private submodules that the mmm command requires to function
# * `locate` contains commands used to colocate assets and models against the
#   configured root directory
# * `hf` contains huggingface-specific utilities
use utils/mmm/locate.nu
use utils/mmm/hf.nu

def defined-providers []: nothing -> list<string> {
    ['huggingface' 'ollama' 'github']
}

# ─[ completes ]──────────────────────────────────────────────────────────
# holds custom completion handlers for the `mmm` command
#
# syntax of custom completion handler for an invocation of
# `mmm ls --type=<type>`  is then `completes mmm ls types`, confer comments of
# command signatures for further examples.
module completes {
    export def 'mmm ls type' [] {
        ['gguf' 'ggml' 'exl2' 'safetensors']
    }

    export def 'mmm ls media' [] {
        ['text' 'image' 'audio' 'video']
    }

    export def 'mmm ls size' [] {
        # TODO: use nushell context passed to completion handlers to narrow the
        # filter sent to `param`
        glob ([(locate model root) '*'] | path join)
        | param
        | get 'parameters'
    }

    export def 'mmm providers' [] {
        defined-services
    }

    export def 'mmm subcommands' [] {
        hf-subcommands
    }

    export def 'mmm sparam output-as' [] {
        ["table" "lines"]
    }
}

use completes

# ─[ `mmm` - Multi-Model Manager ]────────────────────────────────────────
#  -------------------------------
# manage large models of selected modalities for a variety of clients such as
# LlamaCPP, Ollama, LM Studio, TextGeneration WebUI, etc.
#
# Requirements:
# * for models hosted on huggingface, a huggingface API key is required and can
#   be found in your account settings
# * currently no other sources are supported but this is likely to change in the
#   future.
# * TODO: future implementations:
#   * ollama model sources
#   * image model sources, e.g.
#     * chub.ai
#     * civitai

# root command for the `mmm` cli invocation; doesn't do anything on its own.
export def main [] { }

def provider-target [
    service?: string
]: [nothing -> table<service: string, cls: closure> string -> closure] {
    let maprec = {
        hf: {|...args: string| hf ...$args $in }
        github: {|...args: string| hf ...$args $in }
        ollama: {|...args: string| hf ...$args $in }
    }

    let pipe = $in | default $service
    if (not $pipe) or ($pipe | is-empty) {
        $maprec
    } else {
        $maprec | get $pipe
    }
}

export def sparam [
    --filters (-f): list<record<name: any, parameters: any, version: any, revision: any, quantization: any, type: any>>
    --output-as (-o): string@'completes mmm sparam output-as'
    --cache-dir (-d): directory
    --less-verbose (-V)
] {
    let pipe = $in
    let cache = $cache_dir | default null
    let args = (
        [
            (['--dir' $cache] | str join '=')
        ] | append
        (if not $less_verbose { '--verbose' } else { '' })
    )
    let scan_results = hf scan-cache ...$args | lines
    $scan_results | ^rg $pipe
}

# parse the name of a model as it is stored locally, and return a table of
# parameters that the model represents
export def param [
    --model-regex: string = '[[:alnum:]]+'
    --parameters-regex: string = '[0-9]+[bB]'
    --version-regex: string = '[0-9._-]+'
    --quantization-regex: string = '[Qq0-9]+'
    --item-separation-regex: string = '[.-_]'
    --title-tags: record<pop: list<string>, filter: list<string>>
    --item-separation-quantifier: string = '*'
    --no-anchor-model-at-start
]: [
    string -> table<model: string, parameters: string, version: string, quantization: string, type: string> list<string> -> table<model: string, parameters: string, version: string, quantization: string, type: string>
] {
    let pipe = $in

    let sections = ['model' 'parameters' 'version' 'quantization']

    let item_separator = (
        match (
            $item_separation_regex
            | describe
            | str replace --regex '<.*' ''
        ) {
            'string' => {
                $sections | zip {
                    generate {|| $item_separation_regex }
                } | into record
            }
            'record' => { $item_separation_regex }
            _ => { $item_separation_regex }
        }
    )
    let quantifier = (
        match (
            $item_separation_quantifier
            | describe
            | str replace --regex '<.*' ''
        ) {
            'string' => {
                $sections | zip {
                    generate {|| $item_separation_quantifier }
                } | into record
            }
            'record' => { $item_separation_quantifier }
            _ => { $item_separation_quantifier }
        }
    )

    # build each portion of the final regex pattern that will parse out the
    # model parameters from the model name
    let model = r#'(?P<model>{{MODEL_REGEX}})'#
    | str replace '{{MODEL_REGEX}}' $model_regex
    let model = (
        if not $no_anchor_model_at_start {
            ['^' $model] | str join ''
        } else {
            $model
        }
    )
    let parameters = r#'(?P<parameters>{{PARAMETERS_REGEX}})'#
    | str replace '{{PARAMETERS_REGEX}}' $parameters_regex
    let version = r#'(?P<version>{{VERSION_REGEX}})'#
    | str replace '{{VERSION_REGEX}}' $version_regex
    let quantization = r#'(?P<quantization>{{QUANTIZATION_REGEX}})'#
    | str replace '{{QUANTIZATION_REGEX}}' $quantization_regex

    let pattern_content = {|x|
        (
            match $x {
                'model' => { $model }
                'parameters' => { $parameters }
                'version' => { $version }
                'quantization' => { $quantization }
                _ => { null }
            }
        )
    }

    let separator = $sections
    | each {|it|
        {|x|
            (
                [
                    ($item_separator | get $x)
                    ($quantifier | get $x)
                ] | str join ''
            )
        }
    }
    let pattern = $sections
    | each {|it|
        (
            [
                (do $pattern_content $it)
                (do $separator $it)
            ] | str join ''
        )
    } | str join ''
    $pipe | parse --regex $pattern
}

def matcher [
    matchers: record<matches: string, val: any>
]: any -> any {
    let pipe = $in | default null
    (
        match $pipe {
            $val if ($val in $matchers) => { $matchers | get $val }
            _ => { null }
        }
    )
}

export def account [
] { }

export def 'account login' [] { }

export def 'account logout' [] { }

# query the models that are available through configured model sources
export def query [
    --filter (-f)
    --type (-t): string
    --media (-m): string
    --size (-s): string
    --model-dir (-d): directory
    --cache-dir (-c): directory
]: any -> table<model: string, parameters: string, version: string, quantization: string> {
    let model_dir = $model_dir | default (locate model text)
    let absdir = $model_dir | path expand
    let modeldir = (
        match $absdir {
            $dir if ($dir == $model_dir) => {
                $dir | path expand
            }
            $dir if ($dir != $model_dir) => {
                [(locate model root) $dir] | path join | path expand
            }
            _ => { $model_dir | path expand }
        }
    )
    let cache_dir = $cache_dir
    | default ([$modeldir 'cache'] | path join)
    | path expand

    let dirs = glob ([$modeldir '*'] | path join)

    let filter = (
        match (
            $filter
            | describe
            | str replace --regex '<.*' ''
        ) {
            'closure' => {
                {|d| do $filter $d }
            }
            'string' => {
                {|d| $d | where name == $filter }
            }
            'record' => {
                {|d|
                    $filter
                    | items {|key, val|
                        $d | where $key == $val
                    } | reduce {|it, acc|
                        $it | append $acc
                    }
                }
            }
            _ => {
                {|d| $d }
            }
        }
    )
    do $filter $dirs | param
}

# list models that are locally available and can be used for inference, text
# generation, etc.
export def ls [
    --type (-t): string
    --media (-m): string
    --size (-s): string
    --model-dir (-d): directory
    --cache-dir (-c): directory
]: any -> list<string> {
    (
        query
        --type=$type
        --media=$media
        --size=$size
        --model-dir=$model_dir
        --cache-dir=$cache_dir
    )
    | get 'model' | each {|it| $it | into string }
}

export def --wrapped get [
    ...args: string
    --model (-m): string
    --filter (-f): record<type: string, name: string, parameters: string, version: string, quantization: string>
    --model-dir (-d): directory
    --cache-dir (-c): directory
]: any -> nothing {
    let pipe = $in
    let defmodeldir = $model_dir | default (locate model text)
    let model_dir = [$defmodeldir $model] | path join

    $pipe | hf download --cache-dir=$cache_dir --model-dir=$model_dir ...$args
}

# pull a model from its identifier or its URL; this updates any existing models
# that match the identifier or URL, or downloads a fresh install if the model
# doesnt exist or if specified by flag.
export def --wrapped pull [
    ...args: string
    --model-dir (-d): directory
    --cache-dir (-c): directory
]: any -> nothing {
    let pipe = $in
    $pipe | get --cache-dir=$cache_dir --model-dir=$model_dir ...$args
}

# push a local model to a repository online, such as the huggingface hub.
export def --wrapped push [
    repo: string
    ...args: string
] {
    let pipe = $in
    $pipe | hf upload $repo ...$args
}

# ╞╡ Future Implementations ╞════════════════════════════════════════════╡
#  --------------------------
# These items are a longer-term goal for a nushell module like this, in
# particular because the other subcommands that are represented are more
# crucial to having a functional version of these implementations.

# checks the status of installed models (not sure what that means yet)
export def check [] {
}

# subcommand root for the `serve` capabilities of the manager
export def serve [] {
}

# serves a language model for SillyTavern
export def 'serve st' [] {
}

# serves a language model for LlamaCPP
export def 'serve llamacpp' [] {
}
