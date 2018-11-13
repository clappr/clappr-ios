import Swifter
import Foundation

enum HTTPMethod {
    case POST
    case GET
}

class HTTPStub {

    var server = HttpServer()

    func start() {
        setupInitialStubs()
        do {
            try server.start()
        } catch {
            print("Error while starting server: \(error)")
        }
    }

    func stop() {
        server.stop()
    }

    func setupInitialStubs() {
        server["/:path"] = shareFilesFromDirectory(Bundle(for: type(of: self)).bundlePath)
    }
}
