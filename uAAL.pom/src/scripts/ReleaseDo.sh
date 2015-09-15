#!/bin/bash
MY_DIR=`dirname $0`

. $MY_DIR/ReleaseCommon.sh

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

#delete prereleases
gitAll branch -d prerelease_$VERSION

#push tags and delete remote prereleases
gitAll push --tags origin :prerelease_$VERSION


