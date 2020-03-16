import OHHTTPStubs

class OHTTPStubsHelper {
    class func removeStub(with descriptor: OHHTTPStubsDescriptor?) {
        guard let descriptor = descriptor else { return }

        print("Removing stub named -> \"\(descriptor.name ?? "NoName")\" with result: \(OHHTTPStubs.removeStub(descriptor))")
    }
}
