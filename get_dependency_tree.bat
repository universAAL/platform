
@echo off

echo ---------------
echo Script for getting the dependency tree (including transitive dependencies).
echo The result is written in file "tree.txt".
echo
echo Make sure, that uAAL.pom:
echo  - contains a module section (uncomment the module section that is included in uAAL.pom) and
echo  - points to the right modules (call one of the create_repo_links_XX.bat)
echo
echo Please press any key to continue.
echo ---------------
pause

echo ---------------
echo Creating Tree ...
echo ---------------

mvn org.apache.maven.plugins:maven-dependency-plugin:2.8:tree >tree.txt
