#!/bin/bash

#####
# Unit Tests

# Start the test server
echo "starting test server"
packages/plummbur_kruk/start.sh

echo "content_shell --dump-render-tree test/index.html"
results=`/Users/julien/Downloads/code/dart/chromium/drt-mac-full-dev-36630.0/Content\ Shell.app/Contents/MacOS/Content\ Shell --dump-render-tree test/index.html 2>&1`

echo "$results"

# Stop the server
packages/plummbur_kruk/stop.sh

# check to see if DumpRenderTree tests
# fails, since it always returns 0
if [[ "$results" == *"Some tests failed"* ]]; then
    exit 1
fi

if [[ "$results" == *"Exception: "* ]]; then
    exit 1
fi


#####
# Type Analysis

echo
echo "dartanalyzer lib/*.dart"

dartanalyzer lib/dart_gl.dart
if [[ $? != 0 ]]; then
  exit 1
fi



