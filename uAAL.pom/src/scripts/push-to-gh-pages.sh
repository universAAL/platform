#!/bin/bash

if [ "$TRAVIS_REPO_SLUG" == "universAAL/platform" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "master" ]; then

  echo -e "Publishing...\n"
  set -x

  cp -R "target/site" $HOME/site
    
  cd $HOME
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "travis-ci"
  git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/universAAL/platform gh-pages > /dev/null

  cd gh-pages
  git rm --ignore-unmatch -rf . > /dev/null
  cp -Rf $HOME/site/* .
  git add -f . > /dev/null
  git commit -m "Latest site on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages"  > /dev/null
  git push -fq origin gh-pages > /dev/null

  echo -e "Published site to gh-pages.\n"
  
fi
