
@echo off
set version=%1
IF "%version%"=="" (
	ECHO no version defined.
	EXIT
)

echo ---------------
echo Script for creating links to the source repositories in related expert groups.
echo This script must be called from the directory support/tags/%version%/uAAL.pom
echo Please press any key to continue.
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
