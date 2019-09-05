import Quick
import Nimble

@testable import Clappr

class MediaControlViewTests: QuickSpec {
    override func spec() {
        describe("MediaControlView") {
            describe("addSubview") {
                
                beforeEach {
                    didCallAnchorInCenter = false
                }
                
                context("top panel") {
                    it("adds to the topLeft when position is left") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, in: .top, at: .left)
                        
                        expect(mediaControlView.topLeft.subviews).to(contain(view))
                    }
                    
                    it("adds to the topRight when position is right") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, in: .top, at: .right)
                        
                        expect(mediaControlView.topRight.subviews).to(contain(view))
                    }
                    
                    it("adds to the topNone when position is none") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, in: .top, at: .none)
                        
                        expect(mediaControlView.topNone.subviews).to(contain(view))
                    }
                    
                    it("centers the view (adding constraints) in the topPanel when position is center") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIViewMock()
                        
                        mediaControlView.addSubview(view, in: .top, at: .center)
                        
                        expect(mediaControlView.topPanel.subviews).to(contain(view))
                        expect(didCallAnchorInCenter).to(beTrue())
                    }
                }
                
                context("center panel") {
                    it("adds to the centerLeft when position is left") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, in: .center, at: .left)
                        
                        expect(mediaControlView.centerLeft.subviews).to(contain(view))
                    }
                    
                    it("adds to the centerRight when position is right") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, in: .center, at: .right)
                        
                        expect(mediaControlView.centerRight.subviews).to(contain(view))
                    }
                    
                    it("adds to the centerNone when position is none") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, in: .center, at: .none)
                        
                        expect(mediaControlView.centerNone.subviews).to(contain(view))
                    }
                    
                    it("centers the view (adding constraints) in the centerPanel when position is center") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIViewMock()
                        
                        mediaControlView.addSubview(view, in: .center, at: .center)
                        
                        expect(mediaControlView.centerPanel.subviews).to(contain(view))
                        expect(didCallAnchorInCenter).to(beTrue())
                    }
                }
                
                context("bottom panel") {
                    it("adds to the bottomLeft when position is left") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, in: .bottom, at: .left)
                        
                        expect(mediaControlView.bottomLeft.subviews).to(contain(view))
                    }
                    
                    it("adds to the bottomRight when position is right") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, in: .bottom, at: .right)
                        
                        expect(mediaControlView.bottomRight.subviews).to(contain(view))
                    }
                    
                    it("adds to the bottomNone when position is none") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, in: .bottom, at: .none)
                        
                        expect(mediaControlView.bottomNone.subviews).to(contain(view))
                    }
                    
                    it("centers the view (adding constraints) in the bottomPanel when position is center") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIViewMock()
                        
                        mediaControlView.addSubview(view, in: .bottom, at: .center)
                        
                        expect(mediaControlView.bottomPanel.subviews).to(contain(view))
                        expect(didCallAnchorInCenter).to(beTrue())
                    }
                }
                
                context("modal panel") {
                    it("adds to the modalPanel regardless of position") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, in: .modal, at: .left)
                        
                        expect(mediaControlView.modalPanel.subviews).to(contain(view))
                    }
                    
                    it("centers the view (adding constraints) in the modalPanel when position is center") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIViewMock()
                        
                        mediaControlView.addSubview(view, in: .modal, at: .center)
                        
                        expect(mediaControlView.modalPanel.subviews).to(contain(view))
                        expect(didCallAnchorInCenter).to(beTrue())
                    }
                }

                context("padding constraints") {

                    it("bottom starts with value 0") {
                        let mediaControlView: MediaControlView = .fromNib()

                        expect(mediaControlView.bottomPadding?.constant).to(equal(0))
                    }

                    it("top starts with value 0") {
                        let mediaControlView: MediaControlView = .fromNib()

                        expect(mediaControlView.topPadding.constant).to(equal(0))
                    }

                    it("modifies bottom padding with constant") {
                        let mediaControlView: MediaControlView = .fromNib()

                        mediaControlView.bottomPadding?.constant = 10
                        mediaControlView.layoutIfNeeded()

                        expect(mediaControlView.subviews[1].frame.height).to(equal(331))
                    }

                    it("modifies top padding with constant") {
                        let mediaControlView: MediaControlView = .fromNib()

                        mediaControlView.topPadding.constant = 10
                        mediaControlView.layoutIfNeeded()

                        expect(mediaControlView.subviews[1].frame.height).to(equal(331))
                    }

                    it("modifies top and bottom padding with constant") {
                        let mediaControlView: MediaControlView = .fromNib()

                        mediaControlView.topPadding.constant = 10
                        mediaControlView.bottomPadding?.constant = 10
                        mediaControlView.layoutIfNeeded()

                        expect(mediaControlView.subviews[1].frame.height).to(equal(321))
                    }

                    it("modifies bottom padding, and dont change the size of constrast view") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let height = mediaControlView.contrastView.frame.height

                        mediaControlView.bottomPadding?.constant = 10
                        mediaControlView.layoutIfNeeded()

                        expect(mediaControlView.contrastView.frame.height).to(equal(height))
                    }

                    it("modifies top padding, and dont change the size of constrast view") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let height = mediaControlView.contrastView.frame.height

                        mediaControlView.topPadding.constant = 10
                        mediaControlView.layoutIfNeeded()

                        expect(mediaControlView.contrastView.frame.height).to(equal(height))
                    }
                }
            }
        }
    }
}

var didCallAnchorInCenter = false
class UIViewMock: UIView {
    override func anchorInCenter() {
        didCallAnchorInCenter = true
    }
}
