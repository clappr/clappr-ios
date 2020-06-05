import Quick
import Nimble

@testable import Clappr

class UIFocusEnvironmentExtTests: QuickSpec {
    override func spec() {
        describe(".UIFocusEnvironmentExtTests") {
            describe("#isFocusable") {
                context("when an element can become focused") {
                    it("returns false on is focusable property") {
                        let button = UIButton()

                        expect(button.isFocusable).to(beTrue())
                    }
                }

                context("when an element has can become focused false") {
                    it("returns false on is focusable property") {
                        let button = CustomButton()

                        button.customCanBecomeFocused = false

                        expect(button.isFocusable).to(beFalse())
                    }
                }

                context("when an element has alpha equal to 0.0") {
                    it("returns false on is focusable property") {
                        let button = UIButton()

                        button.alpha = 0.0

                        expect(button.isFocusable).to(beFalse())
                    }
                }

                context("when an element is hidden") {
                    it("returns false on is focusable property") {
                        let button = CustomButton()

                        button.isHidden = true

                        expect(button.isFocusable).to(beFalse())
                    }
                }

                context("when an element has user interaction disable") {
                    it("returns false on is focusable property") {
                        let button = CustomButton()

                        button.isUserInteractionEnabled = false

                        expect(button.isFocusable).to(beFalse())
                    }
                }
            }
        }
    }
}

class CustomButton: UIButton {
    var customCanBecomeFocused = true

    override var canBecomeFocused: Bool { customCanBecomeFocused }
}
