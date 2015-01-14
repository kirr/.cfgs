#/bin/bash
if [[ $# != 0 ]]; then
  merge_commit=`git rev-list --ancestry-path --merges "$1..origin/master" | tail -1`
  commit_header=`git log -1 --pretty=format:%s $merge_commit`
  echo $commit_header
  platform=`uname`
  if [[ $platform == 'Darwin' ]]; then
    open "https://stash.desktop.dev.yandex.net/projects/STARDUST/repos/browser/pull-requests/`echo $commit_header | awk '{print substr($4, 2, length($4) - 1)}'`"
  fi
fi
