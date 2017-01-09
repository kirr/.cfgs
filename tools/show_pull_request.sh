#/bin/bash
if [[ $# != 0 ]]; then
  base_brunch='master'
  if [[ $# == 2 ]]; then
    base_brunch=$2
  fi
  merge_commit=`git rev-list --ancestry-path --merges "$1..origin/$base_brunch" | tail -1`
  commit_header=`git log -1 --pretty=format:%s $merge_commit`
  echo $commit_header
  platform=`uname`
  if [[ $platform == 'Darwin' ]]; then
    open "https://bitbucket.browser.yandex-team.ru/projects/STARDUST/repos/browser/pull-requests/`echo $commit_header | awk '{print substr($4, 2, length($4) - 1)}'`"
  else
    xdg-open "https://bitbucket.browser.yandex-team.ru/projects/STARDUST/repos/browser/pull-requests/`echo $commit_header | awk '{print substr($4, 2, length($4) - 1)}'`"
  fi
fi
