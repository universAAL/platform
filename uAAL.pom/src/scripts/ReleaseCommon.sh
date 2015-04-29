#!/bin/bash
function checkAndDeploy ()
{
	mvn clean install
	if [ $? -ne 0 ] ; then echo "failed install, exit"; exit -1 ; fi
	mvn deploy -DskipTests -Prelease
	if [ $? -ne 0 ] ; then echo "failed deploy, exit"; exit -1 ; fi
}

function updateToNewVersions ()
{
	mvn install -fn -DskipTests
	mvn versions:update-child-modules versions:commit
	mvn udir:dependency-check -Ddirective.fix
	mvn udir:update-roots -DnewVersion=$1
}

function change-version()
{
	mvn udir:change-version -DnewVersion=$1
	updateToNewVersions $1
}

function checkAndChangeVersion()
{
	checkAndDeploy
	mvn udir:change-version -DnewVersion=$1
	updateToNewVersions $1
}

function checkNoSNAPSHOTS()
{
	mvn clean	
	find ../ -name "*.*" -print | xargs grep "SNAPSHOT" 
	read -p "Press [Enter] to continue if checked versions are ok... if not close [ctrl+c]"
}

function gitAll()
{
	git $1
	git submodule foreach git $1
}

function gitCommit(){
	gitAll commit -a -m $1
}