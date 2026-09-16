//
//  UIApplication+Ext.swift
//  LiveEvents
//

import UIKit

extension UIApplication {
    /// The view controller currently on top of the key window, following presented controllers.
    /// Google Sign-In presents its sheet from it.
    var topViewController: UIViewController? {
        let root = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
        var top = root
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
