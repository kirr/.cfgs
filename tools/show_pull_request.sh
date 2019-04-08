#/bin/bash
if [[ $# != 0 ]]; then
  base_brunch='master'
  if [[ $# == 2 ]]; then
    base_brunch=$2
  fi
  merge_commit=`git rev-list --ancestry-path --merges "$1..origin/$base_brunch" | tail -1`
  commit_header=`git log -1 --pretty=format:%s $merge_commit`
  echo $commit_header
  remote_path=`git remote -v | tail -n 1 | awk '{print $2}'`
  repo_name=`basename -s .git $remote_path`
  platform=`uname`
  if [[ $platform == 'Darwin' ]]; then
    open "https://bitbucket.browser.yandex-team.ru/projects/STARDUST/repos/`echo $repo_name`/pull-requests/`echo $commit_header | awk '{print substr($4, 2, length($4) - 1)}'`"
  else
    xdg-open "https://bitbucket.browser.yandex-team.ru/projects/STARDUST/repos/`echo $repo_name`/pull-requests/`echo $commit_header | awk '{print substr($4, 2, length($4) - 1)}'`"
  fi
fi
