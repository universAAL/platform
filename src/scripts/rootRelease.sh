#!/bin/bash
#from top level

#RELEASE_SH="pwd" #for test
#RELEASE_SH="batch_increase"
RELEASE_SH="full_release $1 $2"

MY_DIR=`dirname $0`

. $MY_DIR/release.sh

function execute_dir {
	cd $1
	eval $RELEASE_SH
	if [ $? -ne 0 ] ; then exit -1 ; fi
	cd -
}

svn st middleware/trunk/ ontologies/trunk/ uaal_context/trunk/ uaalsecurity/trunk/ rinterop/trunk/ uaal_ui/trunk/ lddi/trunk/
read -p "Press [Enter] to continue if above status is ok..."

execute_dir middleware/trunk/pom

execute_dir ontologies/trunk/ont.pom

execute_dir uaal_context/trunk/pom

execute_dir uaalsecurity/trunk/security.pom

execute_dir rinterop/trunk/ri.pom

execute_dir uaal_ui/trunk/ui.pom

execute_dir lddi/trunk/lddi.pom

execute_dir support/trunk/pom

