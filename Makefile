WORKSPACE=Example/Clappr.xcworkspace
SDK=iphonesimulator
DESTINATION='platform=iOS Simulator,name=iPhone 5s,OS=8.1' 
FINAL_ARGS=ONLY_ACTIVE_ARCH=NO | xcpretty -c

test: unit acceptance
 
clean:
	xcodebuild clean -workspace $(WORKSPACE) -scheme Clappr $(FINAL_ARGS)

unit:
	xcodebuild test -workspace $(WORKSPACE) -scheme UnitTests -sdk $(SDK) -destination $(DESTINATION) $(FINAL_ARGS)

acceptance:
	xcodebuild test -workspace $(WORKSPACE) -scheme AcceptanceTests -sdk $(SDK) -destination $(DESTINATION) $(FINAL_ARGS)

