#!/bin/bash

mkdir -p output

for md_file in $(find site -name "*.md"); do
	html_file="output/$(basename ${md_file%.md}.html)"
	echo Generating $html_file from $md_file...
	sed 's/\.md/\.html/g' "$md_file" | pandoc --from markdown+raw_html -s -o "$html_file" --metadata title="Fareed R Digital Profile"
done

echo Copying directories...
find site -mindepth 1 -type d -exec cp -vr {} output/ \;
echo Done
