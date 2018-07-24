#!/usr/bin/env bash

# Ensure we are failing on all errors
set -e

export HELM_VERSION="2.9.1"
export HELM_BIN="$(pwd)/.semaphore-cache/helm-$HELM_VERSION"
export HELM_HOME="$(pwd)/.semaphore-cache/.helm"
export HELM_PLUGIN_DIR="$(pwd)/.semaphore-cache/.helmplugins"

if [ "$BRANCH_NAME" != "master" ]; then
  echo "Only master branch supports releases"
  exit 1
fi

# Setup tools
if [ ! -f $HELM_BIN ]; then
  curl https://storage.googleapis.com/kubernetes-helm/helm-v$HELM_VERSION-linux-amd64.tar.gz | tar -xz linux-amd64/helm && mv linux-amd64/helm $HELM_BIN
fi

# Configure Helm
sudo cp $HELM_BIN /usr/local/bin/helm
mkdir -p $HELM_HOME $HELM_PLUGIN_DIR
$HELM_BIN init --client-only
$HELM_BIN plugin install https://github.com/mbenabda/helm-local-chart-version || true
$HELM_BIN repo add safesoftware https://safesoftware.github.io/helm-charts/

# Git credentials to push to Github
git config --global user.email "semaphoreci@example.com"
git config --global user.name "Semaphore CI"

function get_chart_name() {
  local chart_name=''
  local chart_dir=$1
  if [[ $chart_dir =~ ^chart-source/(.+)/$ ]] ; then
    chart_name=${BASH_REMATCH[1]}
  fi
  echo $chart_name
}

function build_chart() {
  local chart_dir=$1
  local chart_version=`get_local_chart_version $chart_dir`
  local chart_name=`get_chart_name $chart_dir`
  local chart_package_name="$chart_name-$chart_version"

  echo "Building chart version $chart_package_name"
  $HELM_BIN package $chart_dir
  mv $chart_package_name.tgz docs/$chart_package_name.tgz
  $HELM_BIN repo index docs --url https://safesoftware.github.io/helm-charts
  git tag $chart_package_name
}

function get_local_chart_version() {
  local chart_dir=$1
  echo `$HELM_BIN local-chart-version get -c $chart_dir`
}

function get_remote_chart_version() {
  local chart_name=$1
  [[ "$($HELM_BIN inspect safesoftware/$chart_name)" =~ version:[[:space:]]([0-9\.]+)[[:space:]] ]] && echo ${BASH_REMATCH[1]}
}

available_repos=`$HELM_BIN search safesoftware/`

for chart_dir in chart-source/*/ ; do
  chart_name=`get_chart_name $chart_dir`
  local_chart_version=`get_local_chart_version $chart_dir`

  if echo $available_repos | grep -q "safesoftware/$chart_name " ; then
    remote_chart_version=`get_remote_chart_version $chart_name`
    echo "Existing helm chart $chart_name with version $remote_chart_version found"
    # Check if something changed in comparison to latest released version
    if git diff --raw $chart_name-$remote_chart_version | grep -q $chart_dir ; then
      echo "Changes detected in Chart $chart_name since last release - releasing new version"
      if [ "$remote_chart_version" = "$local_chart_version" ] ; then
        $HELM_BIN local-chart-version bump -c $chart_dir -s patch
      fi
      build_chart $chart_dir
    else
      echo "No changes detected for Chart $chart_name"
    fi
  else
    echo "Chart $chart_name not found, assuming it is a new chart"
    build_chart $chart_dir
  fi
done

git add chart-source/
git add docs/

git commit -m "[ci skip] Release latest Helm charts"

git push origin --tags
git push origin master