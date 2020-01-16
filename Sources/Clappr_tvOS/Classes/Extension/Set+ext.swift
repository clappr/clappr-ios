import Foundation

extension Set where Element == UIPress {
    func containsAny(pressTypes: [UIPress.PressType]) -> Bool {
        return self.contains { pressTypes.contains($0.type) }
    }
}
