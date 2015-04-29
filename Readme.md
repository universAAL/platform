#[universAAL](http://www.universaal.org) platform#

##Continous integration##
http://depot.universaal.org/hudson/?

##Building from source##
1.Prerequisites:
  * [Java Development Kit](http://www.oracle.com/technetwork/java/javase/downloads/index.html) 1.5+
  * [Maven](http://maven.apache.org/) 2.2.0 +

2.clone this repository:

```
git clone git@github.com:universAAL/platform.git
```

3.initialise and update submodules:

```
git submodule update --init
```

4.go to uAAL.pom and install:

```
cd platform/uAAL.pom
mvn install
```
###Tips###
If you wish to build a stable version, then do this after step 2:
```
git checkout <version>
```

If you don't have GitHub account, or you don't have SSH access enabled, then do this instead of step 2:
```
git clone https://github.com/universAAL/platform
git merge remotes/origin/https_access
```
(if you also wish to build a stable version do the version checkout before the merging)