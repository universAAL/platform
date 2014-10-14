#!/bin/bash
#from top level

#RELEASE_SH="pwd" #for test
#RELEASE_SH="batch_increase"
RELEASE_SH="full_release $1 $2"

MY_DIR=`dirname $0`

. $MY_DIR/release.sh

function execute_dir ()
{
	cd $1
	eval $RELEASE_SH
	if [ $? -ne 0 ] ; then exit -1 ; fi
	cd -
}

function pre_release ()
{
	cd $1
	dry_release $2 $3
	cd -
}

svn st middleware/trunk/ ontologies/trunk/ uaal_context/trunk/ uaalsecurity/trunk/ rinterop/trunk/ uaal_ui/trunk/ lddi/trunk/
read -p "Press [Enter] to continue if above status is ok..."

cd support/trunk/uAAL.pom
mvn udir:change-version -DnewVersion=$1
mvn clean install
mvn udir:change-version -DnewVersion=$2
mvn clean install
svn revert pom.xml
cd -

pre_release support/trunk/itests-suite $1 $2

pre_release support/trunk/maven-plugin $1 $2

execute_dir support/trunk/uAAL.pom

execute_dir middleware/trunk/pom

execute_dir ontologies/trunk/ont.pom

#temporaly
execute_dir support/trunk/utilities/uAAL.utils

execute_dir uaal_context/trunk/pom

execute_dir uaalsecurity/trunk/security.pom

execute_dir rinterop/trunk/ri.pom

execute_dir uaal_ui/trunk/ui.pom

execute_dir lddi/trunk/lddi.pom

execute_dir support/trunk/pom


#only for releases (no semi-releases ie: releases with whole version)
cd support/trunk
	svn copy http://forge.universaal.org/svn/support/trunk/resources/ http://forge.universaal.org/svn/support/tags/$1/resources/ -m "release of resources"
cd -
