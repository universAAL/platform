#!/bin/bash
MY_DIR=`dirname $0`

. $MY_DIR/ReleaseCommon.sh

#Change versions
checkAndChangeVersion $1
checkNoSNAPSHOTS

gitCommit "Release $1 version."

#create branches
gitAll branch prerelease_$1

#WARNING: NO DEPLOY YET of Release version
change-version $2
quickCheckAndDeploy

gitCommit "New development version."

#push masters
gitAll push origin master

#push prereleases
gitAll push origin prerelease_$1

#checkout prereleases
gitAll checkout prerelease_$1
