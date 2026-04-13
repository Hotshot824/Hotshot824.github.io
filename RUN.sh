#!/bin/bash
# Program:
#       This program to build a jekyII project.
# Maintainer:
#       Hotshot824
# History:
# 2024/06/09	Hotshot824	0.1.3

function main() {
  build_flag=true

  while getopts ":bph" opt; do
    case ${opt} in
    b)
      ;;
    h)
      echo "Usage: build.sh [-b]"
      echo "  -b  build the jekyll project (Default)"
      exit 0
      ;;
    \?)
      echo "Invalid Option: -$OPTARG" 1>&2
      exit 0
      ;;
    esac
  done
  
  shift $((OPTIND - 1))

  if [ "$build_flag" = true ]; then
    build
  fi
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

(
  WD=$(dirname $(readlink -f $0))
  TZ=$(cat /etc/timezone)
  cd $WD
  main "$@"
)
