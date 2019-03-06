import Foundation

open class UIObject: BaseObject {
    @objc open var view: UIView = UIView()
    @objc open func render() {}
}
