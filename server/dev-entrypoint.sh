#!/bin/bash

[ ! -d ./node_modules ] && mkdir ./node_modules
[ "$(ls -A ./node_modules)" ] && echo "node_modules exist." || npm i --quiet

tail -f /dev/null
