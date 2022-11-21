//
//  UIStoryboard+Ext.swift
//  LiveEvents
//

import UIKit

extension UIStoryboard {

    convenience init(_ storyboard: AppRouter.StroyboadType) {
        self.init(name: storyboard.filename, bundle: nil)
    }

    /// Instantiates and returns the view controller with the specified identifier.
    ///
    /// - Parameter identifier: uniquely identifies equals to Class name
    /// - Returns: The view controller corresponding to the specified identifier string. If no view controller is associated with the string, this method throws an exception.
    public func instantiateViewController<T>(_ identifier: T.Type) -> T where T: UIViewController {
        let className = String(describing: identifier)
        guard let vc =  self.instantiateViewController(withIdentifier: className) as? T else {
            fatalError("Cannot find controller with identifier \(className)")
        }
        return vc
    }

    func segueToRootViewController<T>(_ configure: (T) -> Void) where T: UIViewController {
        let id = String(describing: T.self)
        if let viewController = self.instantiateViewController(withIdentifier: id) as? T {
            configure(viewController)
            setUpRootViewController(viewController)
        } else {
            assertionFailure("Failed to open \(id) viewcontroller")
        }
    }

    private func setUpRootViewController(_ viewController: UIViewController?) {
    }

    func segueToModalViewController<T>(_ configure: (T, Any?) -> Void, optional: Any? = nil) where T: UIViewController {
    }

    func sequePushViewController<T>(_ configure: (T) -> Void) where T: UIViewController {
    }
}

extension UIStoryboard {
    @nonobjc class var main: UIStoryboard {
        return UIStoryboard(name: AppRouter.StroyboadType.main.rawValue, bundle: nil)
    }
}
