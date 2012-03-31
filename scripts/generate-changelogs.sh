#!/bin/bash

(
    cd ~/workspace-sts-2.3.3.M2/tmcpe-webapp
    git tag -l | grep '^v' | sed 's/v//g' | xargs perl -e 'my $lt = shift @ARGV; foreach my $t ( @ARGV ) { print "$t $lt \n"; system("git log --no-merges v$t ^v$lt | sed \"s|#\\([1234567890][1234567890]*\\)|[#\\1](http://tracker.ctmlabs.net/issues/\\1)|g\" | sed \"s/^commit/### commit/g\" | sed \"s/^\\(Author\\\|Date\\):/* \\1/g\" > web-app/mdown/changelog/$t.mdown"); $lt = $t;  }'
)
