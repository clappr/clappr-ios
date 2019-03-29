import Quick
import Nimble

class SwiftVersionTests: QuickSpec {
    override func spec() {
        describe("Podspec and .swift-version") {
            context("when read swift version") {
                it("matches") {
                    let versionFromPodspec = extractSwiftVersionFromPodspec()
                    let versionFromFile = extractVersionFromFile()
                    expect(versionFromPodspec).to(equal(versionFromFile))
                }
            }
        }
        
        func switfVersionContents() -> String {
            let swiftVersionPath = Bundle.init(for: type(of: self)).path(forResource: ".swift-version", ofType: "")!
            return try! String(contentsOfFile: swiftVersionPath)
        }
        
        func extractVersionFromFile() -> String {
            let contents = switfVersionContents()
            return contents.capturedGroups(withRegex: "(.+)").first!
        }
        
        func podspecContents() -> String {
            let podspecPath = Bundle(for: type(of: self)).path(forResource: "Clappr", ofType: "podspec")!
            return try! String(contentsOfFile: podspecPath)
        }
        
        func extractSwiftVersionFromPodspec() -> String {
            let podspec = podspecContents()
            let podSpecSwiftVersion = matches(for: "s?\\.swift_version*\\s?=\\s?['\"](.+)['\"]", in: podspec).first!
            let version = podSpecSwiftVersion.capturedGroups(withRegex: "['\"](.+)['\"]").first!
            return version
        }
        
        func matches(for regex: String, in text: String) -> [String] {
            do {
                let regex = try NSRegularExpression(pattern: regex)
                let results = regex.matches(in: text,
                                            range: NSRange(text.startIndex..., in: text))
                return results.map {
                    String(text[Range($0.range, in: text)!])
                }
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
                return []
            }
        }
    }
}
