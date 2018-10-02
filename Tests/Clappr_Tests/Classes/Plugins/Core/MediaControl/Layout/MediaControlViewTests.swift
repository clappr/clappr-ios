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
                        
                        mediaControlView.addSubview(view, panel: .top, position: .left)
                        
                        expect(mediaControlView.topLeft.subviews).to(contain(view))
                    }
                    
                    it("adds to the topRight when position is right") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, panel: .top, position: .right)
                        
                        expect(mediaControlView.topRight.subviews).to(contain(view))
                    }
                    
                    it("adds to the topNone when position is none") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, panel: .top, position: .none)
                        
                        expect(mediaControlView.topNone.subviews).to(contain(view))
                    }
                    
                    it("centers the view (adding constraints) in the topPanel when position is center") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIViewMock()
                        
                        mediaControlView.addSubview(view, panel: .top, position: .center)
                        
                        expect(mediaControlView.topPanel.subviews).to(contain(view))
                        expect(didCallAnchorInCenter).to(beTrue())
                    }
                }
                
                context("center panel") {
                    it("adds to the centerLeft when position is left") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, panel: .center, position: .left)
                        
                        expect(mediaControlView.centerLeft.subviews).to(contain(view))
                    }
                    
                    it("adds to the centerRight when position is right") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, panel: .center, position: .right)
                        
                        expect(mediaControlView.centerRight.subviews).to(contain(view))
                    }
                    
                    it("adds to the centerNone when position is none") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, panel: .center, position: .none)
                        
                        expect(mediaControlView.centerNone.subviews).to(contain(view))
                    }
                    
                    it("centers the view (adding constraints) in the centerPanel when position is center") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIViewMock()
                        
                        mediaControlView.addSubview(view, panel: .center, position: .center)
                        
                        expect(mediaControlView.centerPanel.subviews).to(contain(view))
                        expect(didCallAnchorInCenter).to(beTrue())
                    }
                }
                
                context("bottom panel") {
                    it("adds to the bottomLeft when position is left") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, panel: .bottom, position: .left)
                        
                        expect(mediaControlView.bottomLeft.subviews).to(contain(view))
                    }
                    
                    it("adds to the bottomRight when position is right") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, panel: .bottom, position: .right)
                        
                        expect(mediaControlView.bottomRight.subviews).to(contain(view))
                    }
                    
                    it("adds to the bottomNone when position is none") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, panel: .bottom, position: .none)
                        
                        expect(mediaControlView.bottomNone.subviews).to(contain(view))
                    }
                    
                    it("centers the view (adding constraints) in the bottomPanel when position is center") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIViewMock()
                        
                        mediaControlView.addSubview(view, panel: .bottom, position: .center)
                        
                        expect(mediaControlView.bottomPanel.subviews).to(contain(view))
                        expect(didCallAnchorInCenter).to(beTrue())
                    }
                }
                
                context("modal panel") {
                    it("adds to the modalPanel regardless of position") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIView()
                        
                        mediaControlView.addSubview(view, panel: .modal, position: .left)
                        
                        expect(mediaControlView.modalPanel.subviews).to(contain(view))
                    }
                    
                    it("centers the view (adding constraints) in the modalPanel when position is center") {
                        let mediaControlView: MediaControlView = .fromNib()
                        let view = UIViewMock()
                        
                        mediaControlView.addSubview(view, panel: .modal, position: .center)
                        
                        expect(mediaControlView.modalPanel.subviews).to(contain(view))
                        expect(didCallAnchorInCenter).to(beTrue())
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
