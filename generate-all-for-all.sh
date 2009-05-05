#!/bin/bash

for f in `find grails-app/domain -name \*.groovy | sed 's/grails-app\/domain\/\(.*\)\.groovy/\1/g' | sed 's/\//./g'`; do
    grails generate-all $f
done
