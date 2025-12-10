#!/bin/bash
TMPDIR=${TMPDIR:-/tmp}
cd $TMPDIR
curl -LOk https://github.com/tldr-pages/tldr/archive/main.zip
unzip main.zip
mkdir -p cheats
cp -rf tldr-main/pages/linux/* cheats
cp -rf tldr-main/pages/common/* cheats
cd cheats
rename .md '' *.md
cd ..
cp -rf cheats/* ~/.cheat-tldr
rm -rf main.zip tldr-main cheats
