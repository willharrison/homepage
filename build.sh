#!/bin/bash

markdown=$(find content -name '*.md*')
count=$(echo $markdown | tr ' ' '\n' | wc -l | xargs)

rm -rf ./dist && mkdir -p dist/{images,posts}
cp -R images/* dist/images

i=1
for md in $markdown
do
  withDist="./dist/${md#*/}"
  withHtml="${withDist%.*}.html"
  printf "test\rpandoc: $md >> $withHtml\n$i/$count"
  pandoc --standalone --template templates/default.html "$md" > "$withHtml"
  i=$((i+1))
done
printf '\n'