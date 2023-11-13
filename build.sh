#!/bin/bash
# Program:
#       This program to build a jekyII project.
# Maintainer:
#       Hotshot824
# History:
# 2023/11/04	Hotshot824	0.1.1

function main() {
  while getopts ":bph" opt; do
    case ${opt} in
    b)
      build
      ;;
    p)
      push
      ;;
    h)
      echo "Usage: build.sh [-b] [-p]"
      echo "  -b  build the jekyll project"
      echo "  -p  force push to github"
      exit 0
    ;;
    \?)
      echo "Invalid Option: -$OPTARG" 1>&2
      ;;
    esac
  done
  shift $((OPTIND - 1))
}

function build() {
  if [[ "$(docker images -q jekyll/jekyll 2>/dev/null)" == "" ]]; then
    docker pull jekyll/jekyll:stable
  fi

  # export JEKYLL_VERSION=3.8
  docker run \
    -v $WD:/srv/jekyll:z \
    -e "TZ=${TZ}" \
    -p 4000:4000 \
    --name jekyll \
    -it jekyll/jekyll \
    jekyll serve 2>/dev/null ||
    docker start jekyll && docker attach jekyll
}

function push() {
  LAST_COMMIT_MSG=$(git log -1 --pretty=%B)
  git add .
  git commit --amend -m "$LAST_COMMIT_MSG"
  git push origin master -f
}

(
  WD=$(dirname $(readlink -f $0))
  TZ=$(cat /etc/timezone)
  cd $WD
  main "$@"
)
