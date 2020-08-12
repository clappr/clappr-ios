BUNDLE=rbenv exec bundle
LANG_VAR=LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
FASTLANE=$(LANG_VAR) $(BUNDLE) exec fastlane

help: ## Show this list of commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

setup: ## Install dependencies requied to start development
	brew update
	-brew upgrade
	brew cleanup
# 	brew install rbenv carthage swiftlint
# 	rbenv install -s
# 	rbenv exec gem install bundler
# 	rbenv rehash
# 	$(BUNDLE) install

wipe: ## Clean the Xcode temp files and kills simulators
	killall "Simulator" || true
	rm -rf ~/Library/Developer/Xcode/{DerivedData,Archives,Products}
	osascript -e 'tell application "iOS Simulator" to quit'
	osascript -e 'tell application "Simulator" to quit'
	xcrun simctl shutdown all

test: ## Run clappr-ios tests
	$(FASTLANE) test

release_from_ci: ## Release clappr-ios to cocoa pods from CI
	$(FASTLANE) release_from_ci

release: ## Release clappr-ios to cocoa pods
	$(FASTLANE) release version:$(version)

release_snapshot:
	$(FASTLANE) release_snapshot version:$(version)

lint: ## Run swiftlint
	$(FASTLANE) lint

