#!/bin/bash

VERSION=$1
#checkout prereleases
gitAll checkout prerelease_$VERSION
gitAll pull

#Deploy all
checkAndDeploy

#Tag
gitAll tag $VERSION

#update local
gitAll checkout master

echo "manually do:" 
echo "git merge prerelease_$VERSION"
echo "mvn deploy -Prelease"
echo 
echo
read -rsp $'Press any key to continue...\n' -n1 key


#delete prereleases
gitAll branch -d prerelease_$VERSION

#push tags and delete remote prereleases
gitAll push --tags origin :prerelease_$VERSION



