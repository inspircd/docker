#!/bin/sh
echo "
         ######################################
         ###       Spellcheck test           ##
         ######################################
"


# Make sure tests fails if a command exits with non-zero
set -e

# Run spellcheck for all Markdown files
# https://www.npmjs.com/package/markdown-spellcheck
docker run --rm -v "$(pwd):/workdir" tmaier/markdown-spellcheck:latest --report --ignore-numbers --ignore-acronyms ./**/*.md
