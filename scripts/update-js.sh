#!/bin/bash

# do a sanity check to make sure we're in the tmcpe root dir
grep -i ^app.name=tmcpe$ application.properties
if [ $? -gt 0 ]; then
    echo "Doesn't look like you're in the tmcpe root directory" 
    exit 1
fi

STAGEDIR=`pwd`/stage

rm -rf $STAGEDIR
mkdir -p $STAGEDIR

# jquery_pagination
JQUERY_PAGINATION_SRCDIR=`pwd`/src/js/jquery_pagination
JQUERY_PAGINATION_STAGEDIR=`pwd`/stage/js
( (cd $JQUERY_PAGINATION_SRCDIR && ant ) \
    && (mkdir -p $JQUERY_PAGINATION_STAGEDIR && cd $JQUERY_PAGINATION_STAGEDIR && unzip $JQUERY_PAGINATION_SRCDIR/build/jquery.pagination.zip -x demo/* -x README.rst) \
    && (mkdir -p $STAGEDIR/css && cd $STAGEDIR/css && mv ../js/pagination.css . ) )
if [ $? -gt 0 ]; then
    echo "FAILED @ JQUERY PAGINATION"
    exit 1
fi

# datatables
DATATABLES_SRCDIR=`pwd`/src/js/DataTables
DATATABLES_STAGEDIR=`pwd`/stage/js
( (cd $DATATABLES_SRCDIR/media && rsync -avz js/ $DATATABLES_STAGEDIR) \
    && (cd $DATATABLES_SRCDIR/media && rsync -avz --exclude favicon.ico images/ $STAGEDIR/images ) )
if [ $? -gt 0 ]; then
    echo "FAILED @ DATATABLES"
    exit 1
fi



# jquery 
JQUERY_STAGEDIR=`pwd`/stage
JQUERY_VERSION=1.6.1
( mkdir -p $JQUERY_STAGEDIR/js && cd $JQUERY_STAGEDIR/js && \
    wget http://code.jquery.com/jquery-$JQUERY_VERSION.js && \
    wget http://code.jquery.com/jquery-$JQUERY_VERSION.min.js )
if [ $? -gt 0 ]; then
    echo "FAILED @ JQUERY"
    exit 1
fi


# jquery-format
JQUERYF_SRCDIR=`pwd`/src/js/jquery-format
JQUERYF_STAGEDIR=`pwd`/stage/js
( (cd $JQUERYF_SRCDIR && ant) \
    && (rsync -avz $JQUERYF_SRCDIR/dist/* $JQUERYF_STAGEDIR ) )
if [ $? -gt 0 ]; then
    echo "FAILED @ JQUERY FORMAT"
    exit 1
fi

# jquery-ui
# JQUERYUI_SRCDIR=`pwd`/src/js
# JQUERYUI_STAGEDIR=`pwd`/stage
# JQUERYUI_VERSION=1.8.13
# ( ( mkdir -p $JQUERYUI_STAGEDIR && cd $JQUERYUI_STAGEDIR && \
#     unzip $JQUERYUI_SRCDIR/jquery-ui-$JQUERYUI_VERSION.custom.zip -x development-bundle/* -x index.html ) ) 
# if [ $? -gt 0 ]; then
#     echo "FAILED @ JQUERYUI"
#     exit 1
# fi

# polymaps
POLYMAPS_SRCDIR=`pwd`/src/js/polymaps
POLYMAPS_STAGEDIR=`pwd`/stage/js
( mkdir -p $POLYMAPS_STAGEDIR && cd $POLYMAPS_SRCDIR && \
    make && rsync -avz polymaps*.js $POLYMAPS_STAGEDIR )
if [ $? -gt 0 ]; then
    echo "FAILED @ POLYMAPS"
    exit 1
fi

# protovis
PROTOVIS_SRCDIR=`pwd`/src/js/protovis
PROTOVIS_STAGEDIR=`pwd`/stage/js
( mkdir -p $PROTOVIS_STAGEDIR && cd $PROTOVIS_SRCDIR && \
    make && rsync -avz protovis*.js $PROTOVIS_STAGEDIR )
if [ $? -gt 0 ]; then
    echo "FAILED @ PROTOVIS"
    exit 1
fi

# # tipsy
# PROTOVIS_SRCDIR=`pwd`/src/js/tipsy
# PROTOVIS_STAGEDIR=`pwd`/stage
# ( mkdir -p $PROTOVIS_STAGEDIR && cd $PROTOVIS_SRCDIR && \
#     rsync -avz src/javascripts/* $PROTOVIS_STAGEDIR/js && \
#     rsync -avz src/stylesheets/* $PROTOVIS_STAGEDIR/css \
#     )
# if [ $? -gt 0 ]; then
#     echo "FAILED @ PROTOVIS"
#     exit 1
# fi

# d3
D3_SRCDIR=`pwd`/src/js/d3
D3_STAGEDIR=`pwd`/stage
( mkdir -p $D3_STAGEDIR && \
    rsync -avz $D3_SRCDIR/*.js $D3_STAGEDIR/js )
if [ $? -gt 0 ]; then
    echo "FAILED @ D3"
    exit 1
fi

# jquery-svg
JQUERY_SVG_SRCDIR=`pwd`/src/js/jquery-svg
JQUERY_SVG_STAGEDIR=`pwd`/stage
( mkdir -p $JQUERY_SVG_STAGEDIR/js && mkdir -p $JQUERY_SVG_STAGEDIR/css && \
    rsync -avz $JQUERY_SVG_SRCDIR/*.js $JQUERY_STAGEDIR/js && \
    rsync -avz $JQUERY_SVG_SRCDIR/*.css $JQUERY_STAGEDIR/css )
if [ $? -gt 0 ]; then
    echo "FAILED @ JQUERY-SVG"
    exit 1
fi

# jquery-dateFormat
JQUERY_DATEFORMAT_SRCDIR=`pwd`/src/js/jquery-dateFormat
JQUERY_DATEFORMAT_STAGEDIR=`pwd`/stage
( mkdir -p $JQUERY_DATEFORMAT_STAGEDIR/js  && \
    rsync -avz $JQUERY_DATEFORMAT_SRCDIR/*.js $JQUERY_DATEFORMAT_STAGEDIR/js )
if [ $? -gt 0 ]; then
    echo "FAILED @ JQUERY-DATEFORMAT"
    exit 1
fi

# polymaps-cluster
POLYMAPS_CLUSTER_SRCDIR=`pwd`/src/js/polymaps-cluster
POLYMAPS_CLUSTER_STAGEDIR=`pwd`/stage
( mkdir -p $POLYMAPS_CLUSTER_STAGEDIR/js  && \
    rsync -avz $POLYMAPS_CLUSTER_SRCDIR/*.js $POLYMAPS_CLUSTER_STAGEDIR/js )
if [ $? -gt 0 ]; then
    echo "FAILED @ POLYMAPS_CLUSTER"
    exit 1
fi

# underscore
UNDERSCORE_SRCDIR=`pwd`/src/js/underscore
UNDERSCORE_STAGEDIR=`pwd`/stage
( mkdir -p $UNDERSCORE_STAGEDIR/js  && \
    rsync -avz $UNDERSCORE_SRCDIR/under*.js $UNDERSCORE_STAGEDIR/js )
if [ $? -gt 0 ]; then
    echo "FAILED @ UNDERSCORE"
    exit 1
fi

    
rsync -avz `pwd`/stage/ `pwd`/web-app

