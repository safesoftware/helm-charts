#!/usr/bin/env bash

# Ensure we are failing on all errors
set -e

export HELM_VERSION="2.9.1"
export HELM_BIN=.semaphore-cache/helm-$HELM_VERSION

function run_tests() {
  echo "Running test for chart $1"
  # Set build number if it is beta Chart
  if [[ $1 =~ beta ]]; then
    $HELM_BIN lint --set fmeserver.buildNr=19999 $1
  else
    $HELM_BIN lint $1
  fi
}

# Setup tools
if [ ! -f $HELM_BIN ]; then
  curl https://storage.googleapis.com/kubernetes-helm/helm-v$HELM_VERSION-linux-amd64.tar.gz | tar -xz linux-amd64/helm && mv linux-amd64/helm $HELM_BIN
fi

# Run tests
for chart_dir in chart-source/*/ ; do
  if [ "$BRANCH_NAME" = "master" ]; then
    echo "Master branch detected, running tests for all charts"
    run_tests $chart_dir $helm_params
  else
    # Check if something changed in Chart against master
    if git diff --raw origin/master | grep -q $chart_dir ; then
      run_tests $chart_dir $helm_params
    fi
  fi
done


