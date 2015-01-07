test:
	xctool test -workspace Example/Clappr.xcworkspace -scheme Clappr -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO

ntest:
	xcodebuild clean test -workspace Example/Clappr.xcworkspace -scheme Clappr -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 5s,OS=8.1' ONLY_ACTIVE_ARCH=NO | xcpretty -c
