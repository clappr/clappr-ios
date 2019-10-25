fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### test
```
fastlane test
```
Runs all the tests
### lint
```
fastlane lint
```
Runs swiftlint producing an html report
### version_bump
```
fastlane version_bump
```
Bump version in Podspec and Info.plist
### bump
```
fastlane bump
```
Bump version in all necessary files
### release_snapshot
```
fastlane release_snapshot
```
Release a new snapshot
### release
```
fastlane release
```
Release a new version of Clappr
### release_from_ci
```
fastlane release_from_ci
```
Release a new version of Clappr from CI

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
