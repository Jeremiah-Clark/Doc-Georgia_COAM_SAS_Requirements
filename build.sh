#!/bin/bash
pandoc --from gfm-alerts \
       --metadata-file master.yaml \
       --template template.tex \
       --pdf-engine=xelatex \
       --lua-filter gfm-to-latex.lua \
       00-Frontmatter.md \
       01-SAS_Requirements.md \
       02-Source_Documents.md \
       -o Georgia_COAM_SAS_Requirements-Latest.pdf

echo "PDF generated"
