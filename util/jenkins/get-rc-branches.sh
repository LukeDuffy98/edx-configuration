#!/bin/bash

usage() {

  prog=$(basename "$0")
  cat<<EOF

  This will clone a repo and look for release
  candidate branches that will be returned as
  a sorted list in json to be 
  parsed by the dynamic choice jenkins plugin

  Usage: $prog
            -v    add verbosity (set -x)
            -n    echo what will be done
            -h    this
            -r    repo to look in
            -f    filter string for branch list

  Example: $prog -r https://github.com/edx/edx-platform -f "rc/"
EOF
}

while getopts "vnhr:f:" opt; do
  case $opt in
    v)
      set -x
      shift
      ;;
    h)
      usage
      exit 0
      ;;
    n)
      noop="echo Would have run: "
      shift
      ;;
    r)
      repo=$OPTARG
      ;;
    f)
      filter=$OPTARG
      ;;
  esac
done

if [[ -z $repo || -z $filter ]]; then
    echo  'Need to specify a filter and a repo'
    usage
    exit 1
fi

repo_basename=$(basename "$repo")
cd /var/tmp

if [[ ! -d $repo_basename ]]; then
    $noop git clone "$repo" "$repo_basename" --mirror
else
    $noop cd "/var/tmp/$repo_basename"
    $noop git fetch
fi

$noop cd "/var/tmp/$repo_basename"
if [[ -z $noop ]]; then
    git branch -a | grep "$filter" | sort -r | head | python -c 'import sys, json; print json.dumps([line.strip() for line in sys.stdin])'
else
    echo "Would have checked for branches using filter $filter"
fi
