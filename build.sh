#!/bin/bash

set -e

root=$(dirname -- "$(readlink -f -- "$0")")
input="$root/src/Main.elm"
uncompressed="$root/public/app.js"
compressed="$root/public/app.min.js"

if
	! command -v uglifyjs >/dev/null 2>&1
then
	echo "Error: You need to have 'uglifyjs' available on your PATH."
	echo "You can run 'npm install --global uglify-js' to get it."
	exit 1
fi

if
	! command -v elm >/dev/null 2>&1 || [ "$(elm --version)" != "0.19.1" ]
then
	echo "Error: You need version 0.19.1 of the 'elm' binary available on your PATH."
	echo "Option 1: Install the binary from the official website: https://guide.elm-lang.org/install/elm.html."
	echo "Option 2: Install it via 'brew' by running 'brew install elm'."
	exit 1
fi

rm -rf elm-stuff

echo "======== DEPENDENCIES ====================="
cat elm.json

echo ""
echo "======== COMPILE TIME ====================="
time elm make --optimize --output="$uncompressed" "$input"

echo ""
echo "======== ASSET SIZE ======================="
uglifyjs "$uncompressed" --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output "$compressed"

echo "Compiled size: $(wc -c <"$uncompressed") bytes  ($uncompressed)"
echo "Minified size: $(wc -c <"$compressed") bytes  ($compressed)"
echo "Gzipped size: $(gzip -c "$compressed" | wc -c) bytes"

echo ""
echo "======== PROJECT SIZE ====================="
echo "Lines of code: "
find "$root" -type f -name "*.elm" -print0 | while IFS= read -rd '' file; do
	wc -l "$file"
done

rm "$uncompressed"
