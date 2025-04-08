export def --env main [fn: closure] {
    $env.deferred ++= [$fn]
}

export def with-defer [fn: closure] {
    $env.deferred = []
    let r = try { do --env $fn | {ok: $in} } catch {|e| {err: $e} }
    for d in ($env.deferred | reverse) {
        try { do --env $d }
    }
    $env.deferred = []
    match $r {
        {ok: $ok} => $ok
        {err: $err} => $err.raw
    }
}
