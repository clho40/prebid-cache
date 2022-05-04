#!/bin/bash

set -e

AUTOFMT=true
VET=true

while true; do
  case "$1" in
     --nofmt ) AUTOFMT=false; shift ;;
     --novet ) VET=false; shift ;;
     * ) break ;;
  esac
done

die() { echo -e "$@" 1>&2 ; exit 1;  }

# Build a list of all the top-level directories in the project.
for DIRECTORY in */ ; do
  GOGLOB="$GOGLOB ${DIRECTORY%/}"
done

# Check that there are no formatting issues
GOFMT_LINES=`gofmt -s -l $GOGLOB | tr '\\\\' '/' | wc -l | xargs`
if $AUTOFMT; then
  # if there are files with formatting issues, they will be automatically corrected using the gofmt -w <file> command
  if [[ $GOFMT_LINES -ne 0 ]]; then
    FMT_FILES=`gofmt -s -l $GOGLOB | tr '\\\\' '/' | xargs`
    for FILE in $FMT_FILES; do
        echo "Running: gofmt -s -w $FILE"
        `gofmt -s -w $FILE`
    done
  fi
else
  test $GOFMT_LINES -eq 0 || die "gofmt needs to be run, ${GOFMT_LINES} files have issues.  Below is a list of files to review:\n`gofmt -s -l $GOGLOB`"
fi

# Run the tests.
go test -timeout 120s $(go list ./... | grep -v /vendor/)

if $VET; then
  COMMAND="go vet"
  echo "Running: $COMMAND"
  `$COMMAND`
fi