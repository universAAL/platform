#!/bin/bash
function checkAndDeploy{
	mvn clean install
	if [ $? -ne 0 ] ; then echo "failed install, exit"; exit -1 ; fi
	mvn deploy -DskipTests -Prelease
	if [ $? -ne 0 ] ; then echo "failed deploy, exit"; exit -1 ; fi
}

function updateToNewVersions{
	mvn install -fn -DskipTests
	mvn versions:update-child-modules versions:commit
	mvn udir:dependency-check -Ddirective.fix
	mvn udir:update-roots -DnewVersion=$1
}

function update_svn{
	svn cleanup ../
	svn up ../
	if [ $? -ne 0 ] ; then echo "failed SVN update, exit"; exit -1 ; fi
}

function release_phase1{
##PHASE 1, Create release version
### 1: release version
	checkAndDeploy
	mvn udir:tag 
	if [ $? -ne 0 ] ; then echo "failed tag, exit"; exit -1 ; fi

	mvn udir:change-version -DnewVersion=$1
	updateToNewVersions $1

##Check last step is donde correctly
	find ../ -name "*.*" -print | xargs grep "SNAPSHOT"
	read -p "Press [Enter] to continue if checked versions are ok... if not close [ctrl+c]"

	checkAndDeploy

	svn ci ../ -m "Release Version."

	mvn udir:tag -fn
	if [ $? -ne 0 ] ; then echo "failed release tag, exit. Try fixing manually then continue with phase2."; exit -1 ; fi
}

function release_phase2{
##PHASE 2, create new Development 
### 1: new Development version
	NEW_DEV_VERSION = $1
	mvn udir:increase-version
	updateToNewVersions $NEW_DEV_VERSION

	#find ../ -name "*.*" -print | xargs grep $NEW_VERSION
	#read -p "Press [Enter] to continue if checked versions are ok..."

	checkAndDeploy

	svn ci ../ -m "New Development Version."

	#read -p "Press [Enter] to continue if above status is ok..."
}

function full_release{
### 1: release version
### 2: new dev version
	update_svn
	release_phase1 $1
	release_phase2 $2
}

function batch_increase{
	update_svn
	mvn udir:tag 
	if [ $? -ne 0 ] ; then echo "failed tag, exit"; exit -1 ; fi
	release_phase2
}
