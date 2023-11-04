#!/bin/bash
# Program:
#       This program to build a jekyII project.
# Maintainer:
#       Hotshot824
# History:
# 2023/05/227	Hotshot824	First release

WD=$(dirname $(readlink -f $0))
TZ=$(cat /etc/timezone)

if [[ "$(docker images -q jekyll/jekyll 2> /dev/null)" == "" ]]; 
then
    docker pull jekyll/jekyll
fi

# export JEKYLL_VERSION=3.8
docker run \
  -v $WD:/srv/jekyll:z \
  -e "TZ=${TZ}" \
  -p 4000:4000 \
  --name jekyll \
  -it jekyll/jekyll \
  jekyll serve 2> /dev/null || 
  docker start jekyll && docker attach jekyll;