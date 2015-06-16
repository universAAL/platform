
@echo off

echo ---------------
echo Script for creating links to the source repositories in related expert groups.
echo This script must be called from the directory support/trunk/uAAL.pom
echo Please press any key to continue.
echo ---------------
pause

echo ---------------
echo Creating Links ...
echo ---------------

mklink /J middleware "../../../middleware/trunk"
mklink /J ontologies "../../../ontologies/trunk"
mklink /J uaal_context "../../../uaal_context/trunk"
mklink /J lddi "../../../lddi/trunk"
mklink /J uaalsecurity "../../../uaalsecurity/trunk"
mklink /J service "../../../service/trunk"
mklink /J rinterop "../../../rinterop/trunk"
mklink /J uaal_ui "../../../uaal_ui/trunk"
mklink /J support "../../../support/trunk"
