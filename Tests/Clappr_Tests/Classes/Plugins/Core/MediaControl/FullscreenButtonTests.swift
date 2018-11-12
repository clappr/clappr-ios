import Quick
import Nimble

@testable import Clappr

class FullscreenButtonTests: QuickSpec {
    override func spec() {
        describe(".FullscreenButton") {
            var fullscreenButton: FullscreenButton!
            var core: Core!
            
            describe("properties") {
                beforeEach {
                    fullscreenButton = FullscreenButton()
                }
                
                describe("pluginName") {
                    it("has a name") {
                        expect(fullscreenButton.pluginName).to(equal("FullscreenButton"))
                    }
                }
                
                describe("panel") {
                    it("is positioned in the center panel") {
                        expect(fullscreenButton.panel).to(equal(MediaControlPanel.bottom))
                    }
                }
                
                describe("position") {
                    it("is aligned in the center") {
                        expect(fullscreenButton.position).to(equal(MediaControlPosition.right))
                    }
                }
                
                describe("#init") {
                    it("is an MediaControlPlugin type") {
                        expect(fullscreenButton).to(beAKindOf(MediaControlPlugin.self))
                    }
                }
                
                context("when a new instance of button is created") {
                    beforeEach {
                        fullscreenButton.button = UIButton()
                    }
                    
                    it("set's a fullscreen button to plugin view") {
                        expect(fullscreenButton.view.subviews).to(contain(fullscreenButton.button))
                    }
                    
                    it("set's acessibilityIdentifier as FullscreenButton") {
                        expect(fullscreenButton.button.accessibilityIdentifier).to(equal("FullscreenButton"))
                    }
                    
                    it("has scaleAspectFit content mode") {
                        expect(fullscreenButton.button.imageView?.contentMode).to(equal(UIViewContentMode.scaleAspectFit))
                    }
                    
                    it("has .fill on contentVerticalAlignment") {
                        expect(fullscreenButton.button.contentVerticalAlignment).to(equal(UIControlContentVerticalAlignment.fill))
                    }
                    
                    it("has .fill on contentHorizontalAlignment") {
                        expect(fullscreenButton.button.contentHorizontalAlignment).to(equal(UIControlContentHorizontalAlignment.fill))
                    }
                }
                
                describe("kFullscreenDisabled") {
                    context("when a new instance of button is created") {
                        context("and kFullscreenDisabled of core.options is true") {
                            it("hides view button") {
                                core = Core(options: [kFullscreenDisabled: true])
                                fullscreenButton = FullscreenButton(context: core)
                                
                                fullscreenButton.button = UIButton()
                                
                                expect(fullscreenButton.view.isHidden).to(beTrue())
                            }
                        }
                        
                        context("and kFullscreenDisabled of core.options is false") {
                            it("shows fullscreen button") {
                                core = Core(options: [kFullscreenDisabled: false])
                                fullscreenButton = FullscreenButton(context: core)
                                
                                fullscreenButton.button = UIButton()
                                
                                expect(fullscreenButton.button.isHidden).to(beFalse())
                            }
                        }
                    }
                }
                
                describe("#render") {
                    beforeEach {
                        fullscreenButton.render()
                    }
                    
                    it("instantiate a new button") {
                        expect(fullscreenButton.button).toNot(beNil())
                    }
    
                    it("sets the constraint edges") {
                        let constraints = fullscreenButton.view.constraints
                        let constraintTop = constraints.first(where: { $0.firstAttribute == .top })
                        let constraintBottom = constraints.first(where: { $0.firstAttribute == .bottom })
                        let constraintLeading = constraints.first(where: { $0.firstAttribute == .leading })
                        let constraintTrailing = constraints.first(where: { $0.firstAttribute == .trailing })
                        expect(constraintTop?.constant).to(equal(0))
                        expect(constraintBottom?.constant).to(equal(0))
                        expect(constraintLeading?.constant).to(equal(0))
                        expect(constraintTrailing?.constant).to(equal(0))
                    }
                }
            }
            
            context("when the player is on fullscreen mode") {
                beforeEach {
                    core = Core()
                    fullscreenButton = FullscreenButton(context: core)
                    fullscreenButton.render()
                    core.trigger(InternalEvent.didEnterFullscreen.rawValue)
                }
                
                context("and user taps on button") {
                    it("trigger userRequestExitFullscreen") {
                        var didTriggerEvent = false
                        core.on(InternalEvent.userRequestExitFullscreen.rawValue) { _ in
                            didTriggerEvent = true
                        }

                        fullscreenButton.button.sendActions(for: .touchUpInside)

                        expect(didTriggerEvent).toEventually(beTrue())
                    }
                }
            }
            
            context("when the player is on embed mode") {
                beforeEach {
                    core = Core()
                    fullscreenButton = FullscreenButton(context: core)
                    fullscreenButton.render()
                    core.trigger(InternalEvent.didExitFullscreen.rawValue)
                }
                
                context("and user taps on button") {
                    it("trigger userRequestEnterInFullscreen") {
                        var didTriggerEvent = false
                        core.on(InternalEvent.userRequestEnterInFullscreen.rawValue) { _ in
                            didTriggerEvent = true
                        }

                        fullscreenButton.button.sendActions(for: .touchUpInside)

                        expect(didTriggerEvent).toEventually(beTrue())
                    }
                }
            }
        }
    }
}
