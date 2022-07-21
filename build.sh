#!/bin/sh

set -e

root=$(dirname -- "$(readlink -f -- "$0")")
input="$root/src/Main.elm"
uncompressed="$root/public/app.js"
compressed="$root/public/app.min.js"

function make {
    elm make --optimize --output="$uncompressed" "$input";
}

function uglify {
    uglifyjs "$uncompressed" --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output "$compressed";
}

function compile {
    make
    uglify

    echo "Compiled size: $(wc -c <"$uncompressed") bytes  ($uncompressed)";
    echo "Minified size: $(wc -c <"$compressed") bytes  ($compressed)";
    echo "Gzipped size: $(gzip -c "$compressed" | wc -c) bytes";
}

compile