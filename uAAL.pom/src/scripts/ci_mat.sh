#!/bin/bash

if [ "$TRAVIS_REPO_SLUG" != "universAAL/$MY_REPO" ] || [ "$TRAVIS_PULL_REQUEST" != "false" ] || [ "$TRAVIS_BRANCH" != "master" ]; then
  exit 1
fi

# stop on error
set -e
# show commands
set -x
# causes a pipeline to return the exit status of the last command in the pipe that returned a non-zero return value.
set -o pipefail


publish_site() {
  echo -e "Publishing...\n"

  cd $HOME
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "travis-ci"
  git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/universAAL/${MY_REPO} gh-pages > /dev/null

  cd gh-pages
  #git rm --ignore-unmatch -rf . > /dev/null
  cp -Rf $HOME/site/$XTRAS$MY_REPO/* .
  git add -f . > /dev/null
  git commit -m "Latest site on successful travis build $TRAVIS_BUILD_NUMBER ($MAT) auto-pushed to gh-pages"  > /dev/null
  git push -fq origin gh-pages > /dev/null
  
  # try again if push fails (if another job has pushed changes in parallel)
  if [ $? -ne 0 ]
  then
    echo -e "Trying to publish site again..\n"
    git pull
    git push -fq origin gh-pages > /dev/null
  fi

  echo -e "Published site to gh-pages.\n"
}

do_script() {
  echo -e "do_script"
  free -m
  
  if [[ $MAT == MAT_TEST ]]; then
      mvn clean install -DskipTests -Dorg.ops4j.pax.logging.DefaultServiceLog.level=WARN -e
      mvn cobertura:cobertura -Dcobertura.aggregate=true -Dcobertura.report.format=xml -fae -e
      mvn cobertura:cobertura -Dcobertura.aggregate=true -Dcobertura.report.format=html -DskipTests -fae -e
      #mvn site:site -DskipTests -Dcobertura.skip -Dmaven.javadoc.skip=true -Dpmd.skip=true -Dcpd.skip=true -Dfindbugs.skip=true -Duaal.report=ci-repo -fn -e
      # create index to have a site that can be staged
      mvn project-info-reports:index
      mvn site:stage -DstagingDirectory=$HOME/site/main -fn -e
      find $HOME/site/ -type f -name "*.html" -exec sed -i 's/uAAL.pom/platform/g' {} +
      # after staging: remove everything except cobertura
      find $HOME/site/ -type f | grep -v cobertura | xargs rm
  fi
  
  if [[ $MAT == MAT_REPORT ]]; then
      mvn clean install -DskipTests -Dorg.ops4j.pax.logging.DefaultServiceLog.level=WARN -e
      mvn javadoc:aggregate -fae -e | grep -i "INFO] Build"
      mvn site:site -DskipTests -Dcobertura.skip -Dmaven.javadoc.skip=true -Duaal.report=ci-repo -fn -e
      mvn site:stage -DstagingDirectory=$HOME/site/main -fn -e
      find $HOME/site/ -type f -name "*.html" -exec sed -i 's/uAAL.pom/platform/g' {} +
  fi
  
  if [[ $MAT == MAT_DEPLOY ]]; then
      mvn org.apache.maven.plugins:maven-dependency-plugin:3.0.1:get -Dartifact=org.springframework.osgi:log4j.osgi:1.2.15-SNAPSHOT
      mvn org.apache.maven.plugins:maven-dependency-plugin:3.0.1:get -Dartifact=org.slf4j:com.springsource.slf4j.api:1.5.0
      mvn org.apache.maven.plugins:maven-dependency-plugin:3.0.1:get -Dartifact=org.slf4j:com.springsource.slf4j.log4j:1.5.0
      mvn org.apache.maven.plugins:maven-dependency-plugin:3.0.1:get -Dartifact=org.slf4j:com.springsource.slf4j.org.apache.commons.logging:1.5.0
      mvn clean install -Dorg.ops4j.pax.logging.DefaultServiceLog.level=WARN -e 
  fi
  
#  exit 0
#  echo "---------- 
#  mvn clean install -DskipTests -Dorg.ops4j.pax.logging.DefaultServiceLog.level=WARN -e
#  mvn javadoc:aggregate -fae -e | grep -i "INFO] Build"
#  mvn cobertura:cobertura -Dcobertura.aggregate=true -Dcobertura.report.format=xml -fae -e -Dorg.universAAL.junit.console.output=false 
#  mvn cobertura:cobertura -Dcobertura.aggregate=true -Dcobertura.report.format=html -DskipTests -fae -e -Dorg.universAAL.junit.console.output=false 
#  mvn site:site -DskipTests -Dcobertura.skip -Dmaven.javadoc.skip=true -Duaal.report=ci-repo -fn -e
#  mvn site:stage -DstagingDirectory=$HOME/site/main -fn -e
#  find $HOME/site/ -type f -name "*.html" -exec sed -i 's/uAAL.pom/platform/g' {} +
}

do_success() {
  echo -e "do_success"
  
  if [[ $MAT == MAT_TEST ]]; then
    export OLD_DIR=`pwd`
    publish_site
    cd "$OLD_DIR"
    export GH_TOKEN="deleted"
    export NIGHTLY_PASSWORD="deleted"
    export NIGHTLY_USERNAME="deleted"
    mvn org.universAAL.support:cigraph-maven-plugin:3.4.1-SNAPSHOT:cigraph -Dtoken=$CI_TOKEN -N -Djava.awt.headless=true 
    export CI_TOKEN="deleted"
    bash <(curl -s https://codecov.io/bash)
    mvn org.eluder.coveralls:coveralls-maven-plugin:4.3.0:report -e
  fi
  
  if [[ $MAT == MAT_REPORT ]]; then
    export OLD_DIR=`pwd`
    publish_site
    cd "$OLD_DIR"
    mvn org.universAAL.support:cigraph-maven-plugin:3.4.1-SNAPSHOT:cigraph -Dtoken=$CI_TOKEN -N -Djava.awt.headless=true -DskipSurefire=true
  fi
  
  if [[ $MAT == MAT_DEPLOY ]]; then
    mvn deploy -DskipTests -DaltDeploymentRepository=uaal-nightly::default::http://depot.universaal.org/maven-repo/nightly/ -fn
#    | grep -i "INFO] Build"
  fi
  
  #exit 0
  #export OLD_DIR=`pwd`
  #publish_site
  #cd "$OLD_DIR"
  #export GH_TOKEN="deleted"
  #export NIGHTLY_PASSWORD="deleted"
  #export NIGHTLY_USERNAME="deleted"
  #mvn org.universAAL.support:cigraph-maven-plugin:3.4.1-SNAPSHOT:cigraph -Dtoken=$CI_TOKEN -N -Djava.awt.headless=true 
  #export CI_TOKEN="deleted"
  #bash <(curl -s https://codecov.io/bash)
  #mvn org.eluder.coveralls:coveralls-maven-plugin:4.3.0:report -e
}

echo -e "select $1"
case "$1" in
  script) do_script;;
  success) do_success;;
esac
echo -e "end"


