#!/bin/bash

function run_unit_tests {
  xcodebuild clean test -project $1 -scheme $2 -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO -destination "$3" | xcpretty -s
  if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    exit 1
  fi
}

function run_lint {
  pod lib lint
  if [[ $? -ne 0 ]]; then
    exit 1
  fi
}

echo "Running Unit Tests..."
run_unit_tests Clappr.xcodeproj Clappr-Example "platform=iOS Simulator,name=iPhone 6s Plus,OS=10.0"
echo ""
echo "Running Lint..."
run_lint
