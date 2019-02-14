import Quick
import Nimble
import OHHTTPStubs

@testable import Clappr

class UIImageViewTests: QuickSpec {
    override func spec() {
        describe("#UIImageViewTests") {
            describe("get image from url") {
                beforeEach {
                    OHHTTPStubs.removeAllStubs()
                }

                context("when the response is 200") {
                    beforeEach {
                        stub(condition: isExtension("png") && isHost("test200")) { _ in
                            let image = UIImage(named: "poster", in: Bundle(for: UIImageViewTests.self), compatibleWith: nil)!
                            let data = UIImagePNGRepresentation(image)
                            return OHHTTPStubsResponse(data: data!, statusCode: 200, headers: ["Content-Type":"image/jpeg"])
                        }
                    }

                    it("sets image") {
                        let url = URL(string: "https://test200/poster.png")
                        let imageView = UIImageView()

                        imageView.setImage(from: url!)

                        expect(imageView.image).toEventuallyNot(beNil())
                    }
                }

                context("when the response is different of 200") {
                    beforeEach {
                        stub(condition: isExtension("png") && isHost("test400")) { _ in
                            return OHHTTPStubsResponse(data: Data(), statusCode: 400, headers: [:])
                        }
                    }

                    it("doesn't set image") {
                        let url = URL(string: "https://test400/poster.png")
                        let imageView = UIImageView()

                        imageView.setImage(from: url!)

                        expect(imageView.image).toEventually(beNil())
                    }
                }
            }
        }
    }
}
