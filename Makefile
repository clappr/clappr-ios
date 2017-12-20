BUNDLE=rbenv exec bundle
LANG_VAR=LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
FASTLANE=$(LANG_VAR) $(BUNDLE) exec fastlane

setup:
	brew update
	brew upgrade
	brew cleanup
	brew install rbenv carthage swiftlint
	rbenv install -s
	rbenv exec gem install bundler
	rbenv rehash
	$(BUNDLE) install

test:
	$(FASTLANE) test

release:
	$(FASTLANE) release version:$(version)
