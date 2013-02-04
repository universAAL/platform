
set version=1.3.0

@echo off

echo ---------------
echo Script for creating site and performing site:deploy.
echo This script must be called from the directory support/tags/%version%/uAAL.pom
echo Please add the module section to your uAAL.pom, it should look like this:
echo  ^<modules^>
echo     ^<module^>middleware/pom^</module^>
echo     ^<module^>ontologies/ont.pom^</module^>
echo     ^<module^>uaal_context/pom^</module^>
echo     ^<module^>lddi/lddi.pom^</module^>
echo     ^<module^>uaalsecurity/security.pom^</module^>
echo     ^<module^>rinterop/ri.pom^</module^>
echo     ^<module^>uaal_ui/pom^</module^>
echo     ^<module^>service/srvc.pom^</module^>
echo     ^<module^>support/pom^</module^>
echo   ^</modules^>
echo.
echo If you have done so, please press any key.
echo ---------------
pause

echo ---------------
echo Creating Links ...
echo ---------------

mklink /J middleware "../../../../middleware/tags/%version%"
mklink /J ontologies "../../../../ontologies/tags/%version%"
mklink /J uaal_context "../../../../uaal_context/tags/%version%"
mklink /J lddi "../../../../lddi/tags/%version%"
mklink /J uaalsecurity "../../../../uaalsecurity/tags/%version%"
mklink /J service "../../../../service/tags/%version%"
mklink /J rinterop "../../../../rinterop/tags/%version%"
mklink /J uaal_ui "../../../../uaal_ui/tags/%version%"
mklink /J support "../../../../support/tags/%version%"

echo ---------------
echo Install uAAL.pom
echo ---------------

call mvn install -N


REM goto SkipSite
echo ---------------
echo Create Site for parent poms of all repositories
echo ---------------

cd middleware/pom
call mvn site
cd ../../ontologies/ont.pom
call mvn site
cd ../../uaal_context/pom
call mvn site
cd ../../lddi/lddi.pom
call mvn site
cd ../../uaalsecurity/security.pom
call mvn site
cd ../../service/srvc.pom
call mvn site
cd ../../rinterop/ri.pom
call mvn site
cd ../../uaal_ui/pom
call mvn site
cd ../../support/pom
call mvn site
cd ../../uAAL.pom


echo ---------------
echo Create Site for super pom; you should kill this after the super pom is site'd and call the remaining task (mvn site:deploy) manually.
echo ---------------
pause

REM we cannot call "mvn site" with parameter -N since this would create all the reports (e.g. javadoc is missing)
REM it could be tested to call site only on this artifact (removing the lines above)
call mvn site
REM :SkipSite

echo ---------------
echo Deploy Site
REM echo Stage Site
echo ---------------

call mvn site:deploy
REM call mvn site:stage -DstagingDirectory=c:\test\stage\


echo ---------------
echo .. Done.
echo You may have to edit the main index.html file on depot server to correct the links to modules.
echo ---------------

REM exit /B
