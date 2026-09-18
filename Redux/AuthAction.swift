import UIKit
import SwiftGoogleSignIn

enum AuthAction {
    case configure
    case viewController(UIViewController)
    case signedIn(userSession: UserSession)
    case signInError(AuthError)
    case requestPermissions
    case logOut
    case loggedOut
    case openUrl(URL)
    case openUrlWithError(message: String)
}
