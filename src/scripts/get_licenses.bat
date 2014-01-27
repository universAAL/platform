
@echo off

echo ---------------
echo Script for getting the licenses of all dependencies (including transitive dependencies).
echo The result is written in file "target\generated-sources\license\THIRD-PARTY.txt".
echo.
echo Make sure, that uAAL.pom:
echo  - contains a module section (uncomment the module section that is included in uAAL.pom) and
echo  - points to the right modules (call one of the create_repo_links_XX.bat)
echo  - configuration for license-maven-plugin is not commented out
echo.
echo Please press any key to continue.
echo ---------------
pause

echo ---------------
echo Creating License List ...
echo ---------------

mvn license:aggregate-add-third-party -Dlicense.useMissingFile=true

REM mvn org.kuali.maven.plugins:license-maven-plugin:1.6.3:aggregate-add-third-party -Dlicense.excludedScopes=test
REM mvn license:aggregate-add-third-party -Dlicense.excludedScopes=test -Dlicense.useMissingFile=true
REM mvn license:download-licenses
