#!/bin/sh

JOBS=`grep inputTikZ final-report.tex  | grep -v newcommand | sed 's/.*inputTikZ{\([^}]*\)}.*/\1/g'`
echo JOBS: $JOBS
for job in $JOBS; do
    if [ ! -e "$job-external.pdf" ]; then
        echo ============================ PROCESSING $job ===================================
	pdflatex --jobname $job-external final-report.tex
    fi
done
