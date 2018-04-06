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
  git rm --ignore-unmatch -rf . > /dev/null
  cp -Rf $HOME/site/$XTRAS$MY_REPO/* .
  git add -f . > /dev/null
  git commit -m "Latest site on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages"  > /dev/null
  git push -fq origin gh-pages > /dev/null

  echo -e "Published site to gh-pages.\n"
}

do_script() {
  echo -e "do_script"
  free -m
#  echo "---------- 
  mvn clean install -DskipTests -Dorg.ops4j.pax.logging.DefaultServiceLog.level=WARN -e
#  | grep -i "INFO] Build"
#  ((((mvn javadoc:javadoc -fae; echo $? >&3) | grep -i "INFO] Build" >&4) 3>&1) | (read xs; exit $xs)) 4>&1
# - ((((mvn surefire-report:report -Dsurefire-report.aggregate=true -fae; echo $? >&3) | grep -i "INFO] Build" >&4) 3>&1) | (read xs; exit $xs)) 4>&1
  mvn javadoc:aggregate -fae -e | grep -i "INFO] Build"
  mvn cobertura:cobertura -Dcobertura.aggregate=true -Dcobertura.report.format=xml -fae -e -Dorg.universAAL.junit.console.output=false 
#  | grep -i "INFO] Build"
  mvn cobertura:cobertura -Dcobertura.aggregate=true -Dcobertura.report.format=html -DskipTests -fae -e -Dorg.universAAL.junit.console.output=false 
#  | grep -i "INFO] Build"
#  mvn surefire-report:report -Dsurefire-report.aggregate=true -fae -e
#  | grep -i "INFO] Build"
  mvn site:site -DskipTests -Dcobertura.skip -Dmaven.javadoc.skip=true -Duaal.report=ci-repo -fn -e
#  | grep -i "INFO] Build"
  mvn site:stage -DstagingDirectory=$HOME/site/main -fn -e
#  | grep -i "INFO] Build"
  find $HOME/site/ -type f -name "*.html" -exec sed -i 's/uAAL.pom/platform/g' {} +
}

do_success() {
  echo -e "do_success"
  travis_wait mvn deploy -DskipTests -DaltDeploymentRepository=uaal-nightly::default::http://depot.universaal.org/maven-repo/nightly/ -fn | grep -i "INFO] Build"
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
}

echo -e "select $1"
case "$1" in
  script) do_script;;
  success) do_success;;
esac
echo -e "end"


