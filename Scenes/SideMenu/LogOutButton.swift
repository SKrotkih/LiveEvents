import SwiftUI

/// Log out button View Structure
///  fields:
///  title - caption of the button
///  action - binding with client filed
///  runAction - action which will be executed while press on the button
struct LogOutButton: View, Themeable {
    @Environment(\.colorScheme) var colorScheme

    let title: String
    @Binding var action: HomeViewActions
    let runAction: HomeViewActions

    var body: some View {
        Button(action: {
            action = runAction
        }, label: {
            Text(title)
                .padding()
                .foregroundColor(logOutButtonColor)
        })
        .style(appStyle: .noStyle)
        .frame(width: 130.0, height: 20.0)
    }
}
