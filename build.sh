#!/bin/bash
pandoc --from gfm-alerts \
       --metadata-file master.yaml \
       --template template.tex \
       --pdf-engine=xelatex \
       --lua-filter gfm-to-latex.lua \
       SAS_Requirements.md \
       -o Output.pdf

echo "PDF generated"
